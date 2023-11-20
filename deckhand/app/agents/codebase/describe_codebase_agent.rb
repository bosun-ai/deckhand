class Codebase::DescribeCodebaseAgent < ApplicationAgent
  def run
    result = run(RewriteInMarkdownAgent, context.summarize_knowledge).output

    context.codebase.update! description: result
    result
  end
end  