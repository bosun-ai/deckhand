class Deckhand::Tasks::ReformatAnswer
  def run(question, answer, format, example: nil)
    format_prompt = %Q{When asked the question:

#{question}

You responded with:

#{answer}

Please reformat your answer as a #{format} document. For example:

#{example}

Reformatted answer:
}
    system = "You are an application that reformats answers into #{format} documents. Your answers are always syntactically correct and have no extra information."
    prompt(format_prompt, system: system)["message"]["content"]
  end
end