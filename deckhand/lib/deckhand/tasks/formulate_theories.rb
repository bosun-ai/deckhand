module Deckhand::Tasks::FormulateTheories
  def self.run(question, theory, observations, tools: all_tools)
    prompt_text = %Q{# Solving a problem with tools
  While formulating an answer to the following question:

    #{question}

  We postulate the following theory:

    #{theory}

  We have the following tools to our disposal:

  #{summarize_tools(tools)}

  We have established the following observations:

  #{observations.map {|o| "  - #{o}"}.join("\n")}

  Based on this theory the following observations will get us closer to an answer:
  -}
    prompt(prompt_text)
  end
end