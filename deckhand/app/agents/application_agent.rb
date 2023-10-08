class ApplicationAgent < AutonomousAgent
  # TODO: allow lambdas for default argument values
  arguments context: nil, tools: [AnalyzeFileTool, ListFilesTool]

  attr_accessor :agent_run

  set_callback :run, :around do |object, block|
    DeckhandTracer.in_span("#{self.class.name}#run") do
      result = nil

      attrs = {
        name: self.class.name,
        arguments: object.arguments.to_json(except: %i[context parent]),
        context: context.to_json,
        parent: object.parent&.agent_run
      }
      agent_run = AgentRun.create!(**attrs)
      current_span = OpenTelemetry::Trace.current_span
      current_span.add_attributes(attrs.except(:parent).stringify_keys)

      object.agent_run = agent_run
      object.context.agent_run = agent_run

      if agent_run.parent
        agent_run.parent.events.create!(event_hash: { type: 'run_agent', content: object.agent_run.id })
      end

      result = block.call
    rescue StandardError => e
      current_span = OpenTelemetry::Trace.current_span
      current_span.record_exception(e)
      current_span.status = OpenTelemetry::Trace::Status.error(e.to_s)
      object.agent_run.update!(error: e) if object.agent_run
      puts "Caught agent error (AgentRun##{object.agent_run.id}) while running #{self.class.name}:\n#{e.message}\n\n#{e.backtrace.join("\n")}"
    ensure
      if object.agent_run
        object.agent_run.update!(output: result&.to_json, context: context.to_json, finished_at: Time.now)
      end
      result
    end
  end

  set_callback :prompt, :around do |object, block|
    # binding.irb
    result = nil

    result = block.call
    if object.agent_run
      object.agent_run.events.create!(
        event_hash: {
          type: 'prompt',
          content: { prompt: result.prompt, response: result.full_response }.to_json
        }
      )
    end
  ensure
    result
  end

  def call_function(prompt_response, **_kwargs)
    tool = tools.find { |t| t.name == prompt_response.function_call_name }
    raise ApplicationTool::Error.new("No tool found with name #{prompt_response.function_call_name}") unless tool
    args = prompt_response.function_call_args
    raise ApplicationTool::Error.new("Got invalid function call args object: #{prompt_response.function_call_args.inspect}") unless args.is_a?(Hash)
    begin
      tool.run(**args, context:)
    rescue => e
      err = ApplicationTool::Error.new("Failed to run tool #{tool} with arguments: #{args}: #{e.message}")
      err.set_backtrace(e.backtrace)
      raise err 
    end
  end

  def context_prompt
    return '' if context.blank?

    <<~CONTEXT_PROMPT
      You are given the following context to the question:
      #{'  '}
      #{context.summarize_knowledge.indent(2)}
    CONTEXT_PROMPT
  end

  def summarize_tools(tools)
    tools.map { |t| "  * #{t.name}: #{t.description}\n#{t.usage.indent(2)}" }.join("\n")
  end

  def render(template_name, locals: {})
    template = read_template_file(template_name.to_s)
    template.render!(locals.with_indifferent_access, { strict_variables: true, strict_filters: true })
  end

  private

  def read_template_file(template_name)
    template = Liquid::Template.new

    dir_name = self.class.name.underscore.chomp('_agent')
    dir = Rails.root / 'app' / 'agents' / 'templates' / dir_name
    file_system = Liquid::LocalFileSystem.new(dir)
    template.registers[:file_system] = file_system

    file_path = dir / (template_name.to_s + '.liquid')
    raise "Could not find agent template file: #{file_path}" unless file_path.exist?

    template.parse(file_path.read, error_mode: :strict)
  end
end
