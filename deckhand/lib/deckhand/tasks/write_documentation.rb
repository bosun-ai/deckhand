module Deckhand::Tasks
  class WriteDocumentation < Task
    def run
      instruction_prompt = <<~PROMPT
        Given the following context:\n\n#{context.summarize_knowledge}\n

        What style should I use to document my code?

      PROMPT

      instruction_system = <<~SYSTEM
        You are an expert programming teacher who is adamant about following the industry's most popular best practice.
        You are instructing another expert programmer who is new to this project. You do not give examples. You are
        concise.
      SYSTEM

      instruction = prompt(instruction_prompt, system: instruction_system, max_tokens: 256)["message"]["content"].strip

      documenter_prompt = <<~PROMPT
        Given the following context:\n\n#{context.summarize_knowledge}\n\n#{instruction}

        
        This is the code that should be documented:\n\n```#{question}```\n\n
      PROMPT

      documenter_system = <<~SYSTEM
        You are a programmer at Google tasked with writing documentation. Answer by repeating the code with the
         documentation inserted at the correct locations. Follow the instructions carefully.
      SYSTEM

      result = prompt(
        documenter_prompt,
        system: documenter_system,
        max_tokens: 8000,
        mode: :very_large,
      )["message"]["content"].strip.split(/```.*\n/,2).last.strip.delete_suffix("```").strip

      result
    end
  end
end