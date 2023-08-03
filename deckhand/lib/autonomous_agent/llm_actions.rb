module AutonomousAgent::LlmActions
  def prompt(text, **kwargs)
    run_callbacks :prompt do
      response = Deckhand::Lm.prompt(text, **kwargs)
      Deckhand::Lm::PromptResponse.new(response, prompt: text, options: kwargs)
    end
  end
end
