class AutonomousAgent
  include ActiveSupport::Callbacks
  define_callbacks :run

  class << self
    def arguments(*args, **kwargs)
      @@pos_arguments ||= []
      @@arguments ||= { }

      kwargs[:parent] ||= @@arguments[:parent]

      @@pos_arguments = args + @@pos_arguments
      @@arguments.merge!(kwargs)

      args.each do |arg|
        attr_accessor arg
      end

      kwargs.each do |arg, default|
        attr_accessor arg
      end
    end

    def run(*args, **kwargs)
      new(*args, **kwargs).run()
    end
  end

  include AutonomousAgent::LlmActions

  module RunAgent
    def run(*args, **kwargs)
      klass = args.first
      if klass.is_a?(Class) && klass < AutonomousAgent
        return klass.run(*args[1..], **kwargs.merge(parent: self))
      end
      run_callbacks :run do
        super
      end
    end
  end

  def self.inherited(subclass)
    subclass.prepend(RunAgent)
  end

  def initialize(*args, **kwargs)
    args.each_with_index do |arg, i|
      arg_name = self.class.class_variable_get(:@@pos_arguments)[i]
      instance_variable_set("@#{arg_name}", arg)
    end

    self.class.class_variable_get(:@@arguments).each do |arg, default|
      value = kwargs.fetch(arg, default)
      instance_variable_set("@#{arg}", value)
    end
  end
end
