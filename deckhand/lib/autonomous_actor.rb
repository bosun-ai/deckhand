class AutonomousActor
  class << self
    def arguments(*args, **kwargs)
      @pos_arguments = args || []
      @arguments = kwargs || {}

      @pos_arguments.each do |arg|
        attr_accessor arg
      end

      @arguments.each do |arg, default|
        attr_accessor arg
      end
    end
  end

  include AutonomousActor::LlmActions

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
