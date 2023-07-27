module AutonomousAgent::LlmActions
  def prompt(text, **kwargs)
    response = Deckhand::Lm.prompt(text, **kwargs)
    Deckhand::Lm::PromptResponse.new(response)
  end
end
