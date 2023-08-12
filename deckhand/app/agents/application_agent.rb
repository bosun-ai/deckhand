class ApplicationAgent < AutonomousAgent
  # TODO allow lambdas for default argument values
  arguments context: nil, tools: [AnalyzeFileTool, ListFilesTool]

  attr_accessor :agent_run
  
  set_callback :run, :around do |object, block|
    result = nil

    agent_run = AgentRun.create!(
      name: self.class.name,
      arguments: object.arguments.to_json(except: [:context, :parent]),
      context: context.to_json,
      parent: object.parent&.agent_run
    )

    object.agent_run = agent_run
    object.context.agent_run = agent_run

    if agent_run.parent
      agent_run.parent.events.create!(event_hash: { type: "run_agent", content: object.agent_run.id })
    end

    result = block.call
  rescue => e
    puts "Caught error while running #{self.class.name}:\n#{e.message}\n\n#{e.backtrace.join("\n")}"
  ensure
    object.agent_run.update!(output: result&.to_json, context: context.to_json, finished_at: Time.now)
    result
  end

  set_callback :prompt, :around do |object, block|
    # binding.irb
    result = nil

    result = block.call
    object.agent_run.events.create!(event_hash: { type: "prompt", content: { prompt: result.prompt, response: result.full_response}.to_json})
  ensure
    result
  end

  def call_function(prompt_response, **kwargs)
    tool = tools.find {|t| t.name == prompt_response.function_call_name }
    raise ToolError.new("No tool found with name #{prompt_response.function_call_name}") unless tool
    tool.run(prompt_response.function_call_args, context: context)
  end

  def context_prompt
    return "" if context.blank?
    <<~CONTEXT_PROMPT
      You are given the following context to the question:
        
      #{context.summarize_knowledge.indent(2)}
    CONTEXT_PROMPT
  end

  def summarize_tools(tools)
    tools.map { |t| "  * #{t.name}: #{t.description}\n#{t.usage.indent(2)}" }.join("\n")
  end

  def render(**kwargs)
    template_name, parameters = kwargs.first
    template = read_template_file(template_name)
    puts "Passing in parameters: #{parameters.inspect}"
    template.render!(parameters.with_indifferent_access, { strict_variables: true, strict_filters: true })
  end

  private

  def read_template_file(template_name)
    dir_name = self.class.name.underscore.chomp('_agent')
    dir = Rails.root / 'app' / 'agents' / 'templates' / dir_name
    file_path = dir / (template_name.to_s + ".liquid")
    if file_path.exist?
      Liquid::Template.parse(file_path.read, error_mode: :strict)
    else
      raise "Could not find agent template file: #{file_path}"
    end
  end
end
