class CodebaseAgent < ApplicationAgent
  arguments event: nil, service: nil

  def run
    raise "You forgot to implement the run method in #{self.class.name}"
  end
end
