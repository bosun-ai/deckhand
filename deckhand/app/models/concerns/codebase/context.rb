class Codebase::Context < ApplicationAgent::Context 
  attr_accessor :codebase

  def initialize(codebase)
    self.codebase = codebase
    parsed_context = JSON.parse(codebase.attributes["context"] || '{}')
    assignment = parsed_context["assignment"] || "Maintain the #{codebase.name} project codebase"
    history = parsed_context["history"] || []
    super(assignment, history: history)
  end
end