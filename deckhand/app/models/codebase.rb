class Codebase < ApplicationRecord
  after_create :create_repository

  before_validation :ensure_name_slug, unless: -> { name_slug.present? }
  validates_presence_of :name, on: :create, message: "can't be blank"
  validates_presence_of :url, on: :create, message: "can't be blank"

  CODEBASE_DIR = Rails.root.join("tmp", "code")

  def ensure_name_slug
    self.name_slug = name.parameterize if name
  end

  def path
    File.join(CODEBASE_DIR, name_slug)
  end

  def create_repository
    Task.run!(description: "Creating repository for #{name}", script: "git clone #{url} #{path}") do |message|
      if status = message[:status]
        update!(checked_out: status.success?)
      end
    end
  end

  def discover_basic_facts
    
  end
end
