class RewriteInMarkdownAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      Structure the following observations into a descriptive text in github flavored markdown:
      
        #{question.indent(2)}
        
      ```markdown
      Result
      ====
    PROMPT_TEXT
  end

  def system_text
    <<~SYSTEM_TEXT
      You are a programmer writing messages on a Github repository.
    SYSTEM_TEXT
  end

  def run
    puts "Running #{self.class.name}... with question: #{question}"
    prompt(prompt_text, system: system_text).full_response.strip.delete_suffix("```").strip
  end
end