module AutonomousAgent
  class Response
    attr_accessor :full_response

    def initialize(full_response)
      @full_response = full_response
    end
  end
end
