class AutonomousAgent
  # ppor man's cross cutting methods
  [:run, :run_agent, :prompt, :call_function].each do |callback|
    define_method("around_#{callback}") do |*args, **kwargs, &block|
      block.call(*args, **kwargs)
    end
  end

  class << self
    def get_pos_arguments
      @pos_arguments ||= begin
        superclass.respond_to?(:get_pos_arguments) ? superclass.get_pos_arguments.dup : []
      end
    end

    def get_kwargs
      @arguments ||= begin
        superclass.respond_to?(:get_kwargs) ? superclass.get_kwargs.dup : {}
      end
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
      # HACK: this is a bit of a silly hack, maybe we should just remove it
      # The idea of this hack is that we can run agents with the `run`
      # method.
      klass = args.first
      if klass.is_a?(Class) && klass < AutonomousAgent
        return run_agent(klass, *args[1..], **kwargs)
      end
      # End of hack

      around_run(*args, **kwargs) do |*args, **kwargs|
        super(*args, **kwargs)
      end
    end
  end

  module FunctionCallingAgent
    def call_function(prompt_result, **kwargs)
      around_call_function(prompt_result, **kwargs) do |*args, **kwargs|
        super(*args, **kwargs)
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

    # to support deserialization from AgentRun we also want to support getting the pos arguments from an arguments hash
    self.class.get_pos_arguments.each do |arg_name|
      if kwargs.has_key?(arg_name)
        instance_variable_set("@#{arg_name}", kwargs[arg_name])
      end
    end

    self.class.get_kwargs.each do |arg, default|
      value = kwargs.fetch(arg, default)
      instance_variable_set("@#{arg}", value)
    end
  end

  def arguments
    self.class.get_pos_arguments.map do |arg|
      [arg, instance_variable_get("@#{arg}")]
    end.to_h.merge(
      self.class.get_kwargs.keys.map do |arg|
        [arg, instance_variable_get("@#{arg}")]
      end.to_h
    )
  end

  def run(*args, **kwargs)
    raise NotImplementedError.new("You forgot to implement the run method on #{self.class.name}.")
  end

  def run_agent(agent_class, *args, **kwargs)
    around_run_agent(*args, **kwargs) do |*args, **kwargs|
      agent_class.run(*args, **kwargs.merge(parent: self))
    end
  end

  def call_function(prompt_result, **kwargs)
    raise NotImplementedError.new("You forgot to implement the call_function method on #{self.class.name}.")
  end
end
