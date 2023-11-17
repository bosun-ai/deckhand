class TryResolveTheoryAgent < ApplicationAgent
  arguments :question, :theory

  def prompt_text
    <<~PROMPT_TEXT
      # Resolving a theory
      We are trying to answer the following question:
        
      #{question.indent(2)}
        
      #{context_prompt}  
        
      To bring us closer to answer the question, we have the following theory:

      #{theory.indent(2)}

      ## Task

      If the theory is a suggestion on where to look for information and that information is and the required information
      is not yet present in the context, state what information is needed and where it should be found and
      start your answer with "Missing: ".

      If the theory is a suggestion on where to look for information and that information is present in the context, formulate
      the resolution to the theory, start your answer with "Information: ".

      If the theory contains a possible answer to the question, but there is not yet enough information in the context to decide
      if the theory is correct, state what information is needed and start your answer with "Missing: ".

      If the theory contains a possible answer to the question, and there is enough information in the context to decide
      if the theory is correct, state what the answer to the question would be if it the theory is correct and start your answer
      with "Conclusion: ".

      If the theory contains a possible answer to the question, and there is enough information in the context to decide
      if the theory is incorrect, state what the answer to the question would be if it the theory is incorrect and start your answer
      with "Incorrect: ".

      Be sure that the theory is repeated in your answer.
    PROMPT_TEXT
  end

  def run
    resolution = prompt(prompt_text).full_response.strip

    if resolution =~ /Conclusion:/
      {
        "answer" => resolution.split("Conclusion:", 2).last.strip
      }
    elsif resolution =~ /Information:/
      {
        "information" => resolution.split("Information:", 2).last.strip
      }
    elsif resolution =~ /Missing:/
      {
        "need_information" => resolution.split("Missing:", 2).last.strip
      }
    elsif resolution =~ /Incorrect:/
      {
        "incorrect" => resolution.split("Incorrect:", 2).last.strip
      }
    else
      raise "Invalid resolution: #{resolution}"
    end
  end
end
