class Codebase < ApplicationRecord
  before_validation :ensure_name_slug, unless: -> { name_slug.present? }
  validates :name, presence: { on: :create, message: "can't be blank" }
  validates :url, presence: { on: :create, message: "can't be blank" }

  has_many :github_access_tokens, dependent: :destroy
  has_many :services, class_name: 'CodebaseAgentService', dependent: :destroy

  after_create :create_repository

  after_save :update_project_description, if: :saved_change_to_context?
  after_save :describe_project_in_github_issue, if: :saved_change_to_description?

  def github_repo_name
    url.split('/').last(2).join('/').split(':').last.gsub(/\.git$/, '')
  end

  def agent_runs
    AgentRun.root.for_codebase(self)
  end

  def current_agent_run
    agent_run = AgentRun.for_codebase(self).last
    agent_run if agent_run && !agent_run.finished?
  end

  def agent_context(assignment)
    ApplicationAgent::Context.new(assignment, codebase: self, history: context&.dig('history') || [])
  end

  def run_agent(agent, assignment, *_args, **)
    AgentJob.perform_later(agent, context: agent_context(assignment).as_json, **)
  end

  CODEBASE_DIR = if Rails.env.production?
                   '/data/code'
                 else
                   Rails.root.join('tmp/code')
                 end

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

  def path(file=nil)
    File.join([CODEBASE_DIR, "#{id}-#{name_slug}", file].compact)
  end

  def files_graph_name
    "codebase:#{id}:files"
  end

  def github_client
    return unless github_app_installation_id

    @github_client ||= GithubApp.client(github_app_installation_id)
  end

  def github_repo
    return unless (client = github_client)

    @github_repo ||= client.repository(name)
  end

  def git_url
    if (repo = github_repo)
      repo_uri = URI.parse(repo.clone_url)
      repo_uri.user = 'x-access-token'
      repo_uri.password = github_client.access_token
      repo_uri.to_s
    else
      url
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
      if (status = message[:status])
        check_out_finished!(status)
      end
    end
  end

  def default_branch
    github_repo&.default_branch || 'main'
  end

  # TODO: instead of just checking out a new branch, we should clone the whole repo and create the new branch there
  # so we don't run into conflicts when doing multiple shell_tasks at the same time for the same repo.
  def new_branch(branch_name, &block)
    ShellTask.run!(description: "Creating branch #{branch_name} for #{name}",
                   script: "cd #{path} && git checkout -f -B #{branch_name} #{default_branch}") do |message|
      if (status = message[:status]) && block
        block.call(status)
      end
    end
  end

  def commit(message)
    system(%(git config --global user.email "139715209+bosun-deckhand[bot]@users.noreply.github.com"))
    system(%(git config --global user.name "bosun-deckhand[bot]"))
    system(%(cd #{path} && git remote set-url origin "#{git_url}" && git add . && git commit -m '#{message}'))
  end

  def git_push(branch_name, &block)
    ShellTask.run!(description: "Pushing for #{name}",
                   script: "cd #{path} && git push --set-upstream origin #{branch_name}") do |message|
      if (status = message[:status]) && block
        block.call(status)
      end
    end
  end

  def perform_later(action)
    CodebaseJob.perform_later(self, action)
  end

  def check_out_finished!(status)
    return if checked_out

    self.checked_out = status == 0
    save!

    Rails.logger.info "Checked out #{name} with status #{status}"

    return unless checked_out

    create_services!

    perform_later :create_main_github_issue

    perform_later :discover_basic_facts

    perform_later :discover_testing_infrastructure
  end

  def create_services!
    CodebaseAgentService.agents.each do |agent|
      CodebaseAgentService.find_or_create_by!(codebase: self, name: agent.name)
    end
  end

  def discover_undocumented_files
    run_agent(::FileAnalysis::UndocumentedFilesAgent, "Finding undocumented files")
  end

  def describe_project_in_github_issue
    return unless github_client

    html = github_client.markdown(description, mode: 'gfm', context: name)
    add_main_issue_comment(html)

    perform_later :discover_undocumented_files
  end

  def update_project_description
    run_agent(DescribeCodebaseAgent, "Describing project")
  end

  def create_main_github_issue
    return unless github_client

    issue = github_client.create_issue(github_repo_name, 'Bosun AI Agents', 'This issue is created to control Bosun AI Agents.')
    update!(github_app_issue_id: issue.number)
  end

  def add_main_issue_comment(comment)
    return unless github_client && github_app_issue_id

    github_client.add_comment(github_repo_name, github_app_issue_id, comment)
  end

  def main_issue_url
    return unless github_client && github_app_issue_id

    github_client.issue(github_repo_name, github_app_issue_id).html_url
  end

  def process_event(event)
    issue_id = event.dig(:issue, :number).to_s

    Rails.logger.info "Received event: #{issue_id.inspect}"

    return unless issue_id == github_app_issue_id

    process_main_issue_event(event)
  end

  def process_main_issue_event(event)
    Rails.logger.info "Received main issue event: #{event.dig(:comment, :user, :login).inspect}"
    return unless event.dig(:comment, :user, :login) == 'bosun-deckhand[bot]'

    services.enabled.each do |service|
      service.process_event(event)
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
    # Codebase::FileAnalysis::FilesystemFacts.run(self)
  end

  def discover_testing_infrastructure
    run_agent(::FileAnalysis::DiscoverTestingInfrastructureAgent, "Discovering testing infrastructure")
  end
end
