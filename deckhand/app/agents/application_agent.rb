class ApplicationAgent < AutonomousAgent
  arguments context: ApplicationAgent::Context.new("Answering questions"), tools: Deckhand::Lm.all_tools

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
    context.agent_run = agent_run

    result = block.call
  rescue => e
    puts "Caught error while running #{self.class.name}:\n#{e.message}\n\n#{e.backtrace.join("\n")}"
  ensure
    object.agent_run.update!(output: result&.to_json, context: context.to_json, finished_at: Time.now)
    result
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
end
