class CodebaseJob < ApplicationJob
  queue_as :default

  def perform(codebase, method, *args, **kwargs)
    codebase.send(method, *args, **kwargs)
  end
end
