class TryRefuteTheoryAgent < ApplicationAgent
  arguments :question, :theory, :answer

  attr_accessor :resolution, :correct

  def prompt_text
    <<~PROMPT_TEXT
      # Refuting a theory
      We are trying to answer the following question:
      #{'  '}
      #{question.indent(2)}
      #{'  '}
      #{context_prompt}#{'  '}
      #{'  '}
      To bring us closer to answer the question, we have the following theory:

      #{theory.indent(2)}

      And we have come up with the following answer:

      #{answer.indent(2)}

      ## Task

      If you can refute the answer, state why it is incorrect. Begin your answer with "Incorrect: ". If you can't refute the
      answer, state why it is correct. Begin your answer with "Correct: ".

      ## Answer
    PROMPT_TEXT
  end

  def run
    resolution = prompt(prompt_text).full_response.strip
    if resolution =~ /Correct:/
      self.correct = true
      self.resolution = resolution.split('Correct:', 2).last.strip
    elsif resolution =~ /Incorrect:/
      self.correct = false
      self.resolution = resolution.split('Incorrect:', 2).last.strip
    else
      raise "Invalid resolution: #{resolution}"
    end

    {
      resolution: resolution,
      correct: correct
    }
  end
end
