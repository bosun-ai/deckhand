module AutonomousAgent::LlmActions
  def prompt(text, **kwargs)
    result = nil
    run_callbacks :prompt do
      result = Deckhand::Lm.prompt(text, **kwargs)
    end
    if result.is_function_call?
      AutonomousAgent::Response.new(call_function(result, **kwargs))
    else
      result
    end
  end
end
