class SimpleFormattedQuestionAgent < ApplicationAgent
  arguments :question, example: nil, format: "JSON"

  def prompt_text
    <<~PROMPT_TEXT
      Please answer the following question:

      #{question}

      Please format your answer as a #{format} document structured exactly like the following example:

      `````
      #{example}
      `````

      Formatted answer:
      ``````
    PROMPT_TEXT
  end

  def system_text
    <<~SYSTEM_TEXT
      You are an application that reformats answers into #{format} documents. Your answers are always syntactically
      correct and have no extra information and follow the example exactly.
    SYSTEM_TEXT
  end

  def run
    answer = prompt(prompt_text.strip, system: system_text).full_response
    answer.split("``````").first.strip
  end
end
