class DescribeCodebaseAgent < ApplicationAgent
  def run
    result = run(RewriteInMarkdownAgent, "Describing project", context.summarize_knowledge).output

    codebase.update! description: describe_project_in_markdown
  end
end  