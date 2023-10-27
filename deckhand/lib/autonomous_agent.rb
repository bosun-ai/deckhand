class AutonomousAgent
  include ActiveSupport::Callbacks
  define_callbacks :run, :prompt, :call_function

  class << self
    def get_pos_arguments
      @pos_arguments ||= superclass.respond_to?(:get_pos_arguments) ? superclass.get_pos_arguments.dup : []
    end

    def get_kwargs
      @arguments ||= superclass.respond_to?(:get_kwargs) ? superclass.get_kwargs.dup : {}
    end

    def arguments(*args, **kwargs)
      pos_arguments = get_pos_arguments
      arguments = get_kwargs

      kwargs[:parent] ||= arguments[:parent]

      @pos_arguments = args + pos_arguments
      @arguments.merge!(kwargs)

      args.each do |arg|
        attr_accessor arg
      end

      kwargs.each do |arg, _default|
        attr_accessor arg
      end
    end

    def run(*args, **kwargs)
      new(*args, **kwargs).run
    end
  end

  include AutonomousAgent::LlmActions

  module RunAgent
    def run(*args, **kwargs)
      klass = args.first
      return klass.run(*args[1..], **kwargs.merge(parent: self)) if klass.is_a?(Class) && klass < AutonomousAgent

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
      arg_name = self.class.get_pos_arguments[i]
      if arg_name.nil?
        raise "Too many arguments passed to #{self.class.name}: expected #{self.class.get_pos_arguments.inspect} but got #{args.inspect}.}"
      end

      instance_variable_set("@#{arg_name}", arg)
    end

    self.class.get_kwargs.each do |arg, default|
      value = kwargs.fetch(arg, default)
      instance_variable_set("@#{arg}", value)
    end
  end

  def arguments
    self.class.get_pos_arguments.index_with do |arg|
      instance_variable_get("@#{arg}")
    end.merge(
      self.class.get_kwargs.keys.index_with do |arg|
        instance_variable_get("@#{arg}")
      end
    )
  end

  def run(*_args, **_kwargs)
    raise NotImplementedError, "You forgot to implement the run method on #{self.class.name}."
  end

  def call_function(_prompt_result, **_kwargs)
    raise NotImplementedError, "You forgot to implement the call_function method on #{self.class.name}."
  end
end
