class Codebase < ApplicationRecord
  after_create :create_repository

  before_validation :ensure_name_slug, unless: -> { name_slug.present? }
  validates_presence_of :name, on: :create, message: "can't be blank"
  validates_presence_of :url, on: :create, message: "can't be blank"

  has_many :autonomous_assignments, dependent: :destroy

  CODEBASE_DIR = if Rails.env.production?
    "/data/code"
  else
    Rails.root.join("tmp", "code")
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

  def merge_request(title:, body:, branch_name:, &block)
    github_client.create_pull_request(name, default_branch, branch_name, title, body)
  end

  def create_repository
    Task.run!(description: "Creating repository for #{name}", script: "git clone #{git_url} #{path}") do |message|
      if status = message[:status]
        check_out_finished!(status)
      end
    end
  end

  def default_branch
    github_repo&.default_branch || "main"
  end

  # TODO instead of just checking out a new branch, we should clone the whole repo and create the new branch there
  # so we don't run into conflicts when doing multiple tasks at the same time for the same repo.
  def new_branch(branch_name, &block)
    Task.run!(description: "Creating branch #{branch_name} for #{name}", script: "cd #{path} && git checkout -b #{branch_name} #{default_branch}") do |message|
      if status = message[:status]
        block.call(status) if block
      end
    end
  end

  def git_push(&block)
    Task.run!(description: "Pushing for #{name}", script: "cd #{path} && git config push.autoSetupRemote true ; git push") do |message|
      if status = message[:status]
        block.call(status) if block
      end
    end
  end

  def check_out_finished!(status)
    update!(checked_out: status.success?)
    create_main_github_issue

    Thread.new do
      discover_basic_facts
    end

    Thread.new do
      discover_testing_infrastructure
      describe_project_in_github_issue
    end
  end

  def discover_undocumented_files
    files = AutonomousAssignment.run(Codebase::FileAnalysis::UndocumentedFiles, self)
    if !files.blank?
      markdown = %Q{## Undocumented files\n\nFound these undocumented files:\n\n#{files.map { |f| "* #{f}" }.join("\n")}
\n\nIf you would like for Bosun Deckhand to add documentation to these files, please react with a :+1: to this comment.}
      html = github_client.markdown(markdown, mode: "gfm", context: name)
      add_main_issue_comment(html)
    end
  end

  def describe_project_in_github_issue
    markdown = Deckhand::Tasks::RewriteInMarkdown.run(context)
    html = github_client.markdown(markdown, mode: "gfm", context: name)
    add_main_issue_comment(html)
  end

  def create_main_github_issue
    if github_client
      issue = github_client.create_issue(name, "Bosun AI autonomous tasks", "This issue is used to track autonomous tasks for this repository.")
      update!(github_app_issue_id: issue.id)
    end
  end

  def add_main_issue_comment(comment)
    if github_client && github_app_issue_id
      github_client.add_comment(name, github_app_issue_id, comment)
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
    AutonomousAssignment.run(Codebase::FileAnalysis::TestingInfrastructure, self)
  end
end
