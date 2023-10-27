class RewriteInMarkdownAgent < ApplicationAgent
  arguments :question

  def prompt_text
    <<~PROMPT_TEXT
      Structure the following observations into a descriptive text in GFM:

        #{question.indent(2)}
      #{'  '}
      ```markdown
      Result
      ====
    PROMPT_TEXT
  end

  def system_text
    <<~SYSTEM_TEXT
      You are a programmer writing messages on a Github repository. Github uses a special type of markdown called
      Github flavored markdown. Write your answer in Github Flavored Markdown (GFM). Do not write anything except for the
      requested answer.
    SYSTEM_TEXT
  end

  def run
    prompt(prompt_text, system: system_text).full_response.strip.delete_suffix('```').strip
  end
end
