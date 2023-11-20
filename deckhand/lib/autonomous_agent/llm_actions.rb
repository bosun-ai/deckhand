module AutonomousAgent::LlmActions
  def prompt(text, **kwargs)
    result = nil

    result = around_prompt(text, **kwargs) do |text, **kwargs|
      Deckhand::Lm.prompt(text, **kwargs)
    end

    if result.is_function_call?
      AutonomousAgent::Response.new(call_function(result, **kwargs))
    else
      result
    end
  end
end
