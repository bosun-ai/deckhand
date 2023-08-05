class AutonomousAgent
  include ActiveSupport::Callbacks
  define_callbacks :run, :prompt, :call_function

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

  module FunctionCallingAgent
    def call_function(prompt_result, **kwargs)
      run_callbacks :call_function do
        super
      end
    end
  end

  def self.inherited(subclass)
    subclass.prepend(RunAgent)
    subclass.prepend(FunctionCallingAgent)
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

  def arguments
    self.class.class_variable_get(:@@pos_arguments).map do |arg|
      [arg, instance_variable_get("@#{arg}")]
    end.to_h.merge(
      self.class.class_variable_get(:@@arguments).keys.map do |arg|
        [arg, instance_variable_get("@#{arg}")]
      end.to_h
    )
  end

  def run(*args, **kwargs)
    raise NotImplementedError.new("You forgot to implement the run method on #{self.class.name}.")
  end

  def call_function(prompt_result, **kwargs)
    raise NotImplementedError.new("You forgot to implement the call_function method on #{self.class.name}.")
  end
end
