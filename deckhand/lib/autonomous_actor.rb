class AutonomousActor
  include ActiveSupport::Callbacks
  define_callbacks :run

  class << self
    def arguments(*args, **kwargs)
      @pos_arguments = args || []
      @arguments = kwargs || {}
      @arguments[:parent] = nil

      @pos_arguments.each do |arg|
        attr_accessor arg
      end

      @arguments.each do |arg, default|
        attr_accessor arg
      end
    end

    def run(*args, **kwargs)
      new(*args, **kwargs).run()
    end
  end

  include AutonomousActor::LlmActions

  module RunActor
    def run(*args, **kwargs)
      klass = args.first
      if klass.is_a?(Class) && klass < AutonomousActor
        return klass.run(*args[1..], **kwargs.merge(parent: self))
      end
      run_callbacks :run do
        super
      end
    end
  end

  def self.inherited(subclass)
    subclass.prepend(RunActor)
  end

  def initialize(*args, **kwargs)
    args.each_with_index do |arg, i|
      arg_name = self.class.instance_variable_get(:@pos_arguments)[i]
      instance_variable_set("@#{arg_name}", arg)
    end

    self.class.instance_variable_get(:@arguments).each do |arg, default|
      value = kwargs.fetch(arg, default)
      instance_variable_set("@#{arg}", value)
    end
  end
end
