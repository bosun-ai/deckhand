module PromptHelpers
  def parse_json_array(json)
    result = parse_json(json)
    if result.is_a? Array
      result
    elsif result.is_a? Hash
      result.values.flatten
    else
      [result]
    end
  end

  def context_prompt
    return '' if context.blank?

    <<~CONTEXT_PROMPT
      You are given the following context to the question:
      #{'  '}
      #{context.summarize_knowledge.indent(2)}
    CONTEXT_PROMPT
  end

  def return_json_array(subject)
    "Please respond in JSON format with the array of theories as the root element. List each theory as a single string, with no further information or structure."
  end

  def summarize_tools(tools)
    tools.map { |t| "  * #{t.name}: #{t.description}\n#{t.usage.indent(2)}" }.join("\n")
  end
end