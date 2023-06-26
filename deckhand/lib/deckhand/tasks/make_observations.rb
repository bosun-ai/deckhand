module Deckhand::Tasks
  class MakeObservations < Task

    def run
      prompt_text = %Q{# Solving a problem with tools
While formulating an answer to the following question:

#{question.indent(2)}

We postulate the following theory:

#{theory.indent(2)}

We have the following tools to our disposal:

#{summarize_tools(tools).indent(2)}

We have established the following observations:

#{observations.map {|o| "  - #{o}"}.join("\n")}

Based on this theory the following observations will get us closer to an answer:
    -}
      prompt(prompt_text)
    end
  end
end