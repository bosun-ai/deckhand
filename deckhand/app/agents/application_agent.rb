class ApplicationAgent < AutonomousAgent
  arguments context: Deckhand::Context.new("Answering questions"), tools: Deckhand::Lm.all_tools
  
  set_callback :run, :before do |object|
    puts "Going to run! #{object.class}"
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
