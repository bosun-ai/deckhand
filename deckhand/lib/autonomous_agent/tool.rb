class AutonomousAgent::Tool
  include ActiveSupport::Callbacks
  define_callbacks :run

  module RunTool
    def run(*args, **kwargs)
      run_callbacks :run do
        super
      end
    end
  end

  def self.inherited(subclass)
    subclass.prepend(RunTool)
  end
end