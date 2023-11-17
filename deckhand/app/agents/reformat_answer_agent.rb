class ReformatAnswerAgent < ApplicationAgent
  arguments :question, :answer, :format, example: nil

  def format_prompt
    <<~PROMPT_TEXT
      When asked the question:

      #{question.indent(2)}

      You responded with:

      #{answer.indent(2)}

      Please reformat your answer as a "#{format}" document. For example:

      #{example.indent(2)}

      Make sure you include all the fields mentioned in the example.
    PROMPT_TEXT
  end

  def system_text
    <<~SYSTEM_TEXT
      You are an application that reformats answers into #{format} documents. Your answers are always syntactically
       correct and have no extra information.
    SYSTEM_TEXT
  end

  def run
    prompt(format_prompt, system: system_text).full_response
  end
end
