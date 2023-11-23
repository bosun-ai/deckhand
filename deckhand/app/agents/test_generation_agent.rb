# The ReactTestWriter writes tests for React frontends.
class TestGenerationAgent < CodebaseAgent
  def system_prompt
    # TODO: this should be a markdown file
  end

  # TODO: this part of the prompt was intended to be used in a chat conversation:
  # If the user responds with an error message, respond with the contents of the new test file in which the error has
  # been corrected.
  # To make this a thing we should make it possible to give chat histories to the prompt method

  def run
    puts "TestGenerationAgent: #{event.inspect}, #{service.inspect}"
    {
      "event" => event.to_json,
      "service" => service.to_json
    }
  end
end
