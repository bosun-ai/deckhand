class Codebase < ApplicationRecord
  after_create :create_repository

  before_validation :ensure_name_slug, unless: -> { name_slug.present? }
  validates_presence_of :name, on: :create, message: "can't be blank"
  validates_presence_of :url, on: :create, message: "can't be blank"

  has_many :github_access_tokens, dependent: :destroy

  def context
    deserialized = attributes["context"] ? JSON.parse(attributes["context"]) : {}
  rescue JSON::ParserError
    {}
  end

  def agent_context(assignment)
    ApplicationAgent::Context.new(assignment, codebase: self, history: context["history"] || [])
  end

  def run_agent(agent, assignment, *args, **kwargs)
    agent.run(*args, context: agent_context(assignment), **kwargs)
  end

  CODEBASE_DIR = if Rails.env.production?
      "/data/code"
    else
      Rails.root.join("tmp", "code")
    end

  ADD_DOCUMENTATION_HEADER = "## Undocumented files"

  def self.create_from_github_installation_id!(installation_id)
    client = GithubApp.client(installation_id)
    repositories = client.list_app_installation_repositories.repositories.map do |repo|
      repo_uri = URI.parse(repo.clone_url)
      repo_uri.user = client.access_token
      Codebase.find_or_create_by!(name: repo.full_name, url: repo.ssh_url, github_app_installation_id: installation_id)
    end
  end

  def ensure_name_slug
    self.name_slug = name.parameterize if name
  end

  def path
    File.join(CODEBASE_DIR, "#{id}-#{name_slug}")
  end

  def files_graph_name
    "codebase:#{id}:files"
  end

  def github_client
    if github_app_installation_id
      @github_client ||= GithubApp.client(github_app_installation_id)
    end
  end

  def github_repo
    if client = github_client
      @github_repo ||= client.repository(name)
    end
  end

  def git_url
    if repo = github_repo
      repo_uri = URI.parse(repo.clone_url)
      repo_uri.user = "x-access-token"
      repo_uri.password = github_client.access_token
      repo_uri.to_s
    else
      self.url
    end
  end

  def merge_request(title:, body:, branch_name:)
    github_client.create_pull_request(name, default_branch, branch_name, title, body)
  end

  def dispatch_create_repository
    perform_later :create_repository
  end

  def create_repository
    ShellTask.run!(description: "Creating repository for #{name}", script: "git clone #{git_url} #{path}") do |message|
      if status = message[:status]
        check_out_finished!(status)
      end
    end
  end

  def default_branch
    github_repo&.default_branch || "main"
  end

  # TODO instead of just checking out a new branch, we should clone the whole repo and create the new branch there
  # so we don't run into conflicts when doing multiple shell_tasks at the same time for the same repo.
  def new_branch(branch_name, &block)
    ShellTask.run!(description: "Creating branch #{branch_name} for #{name}", script: "cd #{path} && git checkout -b #{branch_name} #{default_branch}") do |message|
      if status = message[:status]
        block.call(status) if block
      end
    end
  end

  def commit(message)
    system(%Q{git config --global user.email "139715209+bosun-deckhand[bot]@users.noreply.github.com"})
    system(%Q{git config --global user.name "bosun-deckhand[bot]"})
    system(%Q{cd #{path} && git remote set-url origin "#{git_url}" && git add . && git commit -m '#{message}'})
  end

  def git_push(branch_name, &block)
    ShellTask.run!(description: "Pushing for #{name}", script: "cd #{path} && git push --set-upstream origin #{branch_name}") do |message|
      if status = message[:status]
        block.call(status) if block
      end
    end
  end

  def perform_later(action)
    CodebaseJob.perform_later(self, action)
  end

  def check_out_finished!(status)
    success = status == 0
    update!(checked_out: success)

    Rails.logger.info "Checked out #{name} with status #{status}"

    return unless success

    perform_later :create_main_github_issue

    perform_later :discover_basic_facts

    perform_later :discover_testing_infrastructure
  end

  def discover_undocumented_files
    files = run_agent(::FileAnalysis::UndocumentedFilesAgent, "Finding undocumented files")
    if !files.blank?
      markdown = %Q{#{ADD_DOCUMENTATION_HEADER}\n\nFound these undocumented files:\n\n#{files.map { |f| "* #{f}" }.join("\n")}
\n\nIf you would like for Bosun Deckhand to add documentation to these files, check the box below:\n\n- [ ] Add documentation to these files\n\n}
      # html = github_client.markdown(markdown, mode: "gfm", context: name)
      # add_main_issue_comment(html)
      add_main_issue_comment(markdown)
    end
  end

  def describe_project_in_github_issue
    markdown = run_agent(RewriteInMarkdownAgent, "Describing project", agent_context("Project").summarize_knowledge)
    html = github_client.markdown(markdown, mode: "gfm", context: name)
    add_main_issue_comment(html)
  end

  def create_main_github_issue
    if github_client
      issue = github_client.create_issue(name, "Bosun AI autonomous shell_tasks", "This issue is used to track autonomous shell_tasks for this repository.")
      update!(github_app_issue_id: issue.number)
    end
  end

  def add_main_issue_comment(comment)
    if github_client && github_app_issue_id
      github_client.add_comment(name, github_app_issue_id, comment)
    end
  end

  def main_issue_url
    if github_client && github_app_issue_id
      github_client.issue(name, github_app_issue_id).url
    end
  end

  def process_event(event)
    issue_id = event.dig(:issue, :number).to_s

    Rails.logger.info "Received event: #{issue_id.inspect}"

    if issue_id == github_app_issue_id
      process_main_issue_event(event)
    end
  end

  def process_main_issue_event(event)
    Rails.logger.info "Received main issue event: #{event.dig(:comment, :user, :login).inspect}"
    if event.dig(:comment, :user, :login) == "bosun-deckhand[bot]"
      process_bot_action_event(event)
    end
  end

  def process_bot_action_event(event)
    comment = event.dig(:comment, :body)

    puts "Received process_bot_action_event: #{comment.inspect}"
    if comment.strip.start_with?(ADD_DOCUMENTATION_HEADER)
      files = comment.split("*")[1..-2].map(&:strip)
      add_documentation_to_undocumented_files(files)
    end
  end

  # discover basic facts is going to establish a list of basic facts about the codebase
  # that we can use to make decisions about how to analyze it.
  #
  # For example, we can use this to determine if the codebase is a Rails app, or a
  # Node app, or a Python app, etc.
  # Also what tools are used, what frameworks are used, etc.
  #
  # Specifically we need the following information:
  # - What languages and frameworks are used?
  # - For each file extension we encounter, what language is the file written in?
  # - What commands and tools can be used to execute and test the codebase?
  # - Where are entrypoints defined, where are tests defined, and where are endpoints defined?
  # - Where are dependencies defined? What external services are required?
  # - What operating system dependencies are required?
  def discover_basic_facts
    Codebase::FileAnalysis::FilesystemFacts.run(self)
  end

  def discover_testing_infrastructure
    context = run_agent(::FileAnalysis::DiscoverTestingInfrastructureAgent, "Discovering testing infrastructure")
    update!(context: context.to_json)

    perform_later :describe_project_in_github_issue
  end

  def add_documentation_to_undocumented_files(files)
    Codebase::Maintenance::AddDocumentation.run(self, files: files)
  end
end
