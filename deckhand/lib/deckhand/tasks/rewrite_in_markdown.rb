module Deckhand::Tasks
  class RewriteInMarkdown < Task
    def run
      prompt("Structure the following observations into a descriptive text in github flavored markdown:\n\n#{question}\n\n```markdown\nResult\n====\n", system: "Yo
        u are a programmer writing messages on a Github repository.")["message"]["content"].strip.delete_suffix("```").strip
    end
  end
  end