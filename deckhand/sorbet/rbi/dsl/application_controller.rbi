# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `ApplicationController`.
# Please instead update this file by running `bin/tapioca dsl ApplicationController`.

class ApplicationController
  include GeneratedUrlHelpersModule
  include GeneratedPathHelpersModule

  sig { returns(HelperProxy) }
  def helpers; end

  module HelperMethods
    include ::Turbo::DriveHelper
    include ::Turbo::FramesHelper
    include ::Turbo::IncludesHelper
    include ::Turbo::StreamsHelper
    include ::ActionView::Helpers::CaptureHelper
    include ::ActionView::Helpers::OutputSafetyHelper
    include ::ActionView::Helpers::TagHelper
    include ::Turbo::Streams::ActionHelper
    include ::ActionText::ContentHelper
    include ::ActionText::TagHelper
    include ::ViteRails::TagHelpers
    include ::ActionController::Base::HelperMethods
    include ::ApplicationHelper
    include ::AgentRunsHelper
    include ::AutonomousAssignmentsHelper
    include ::CodebasesHelper
    include ::GithubAppHelper
    include ::MainDeckHelper
    include ::ShellTasksHelper
  end

  class HelperProxy < ::ActionView::Base
    include HelperMethods
  end
end
