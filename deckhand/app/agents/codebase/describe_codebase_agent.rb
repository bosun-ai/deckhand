class Codebase::DescribeCodebaseAgent < ApplicationAgent
  def run
    result = run(RewriteInMarkdownAgent, "Describing project").output

    codebase.update! description: describe_project_in_markdown
  end
end  