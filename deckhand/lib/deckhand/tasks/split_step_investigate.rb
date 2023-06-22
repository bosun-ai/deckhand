module Deckhand::Tasks
class SplitStepInvestigate
  include Deckhand::Lm

  attr_accessor :history, :tools, :question

  def initialize(question, history: [], tools: all_tools)
    @question = question
    @tools = tools
    @history = history
  end

  def run
    # To come to a correct answer we want to make observations, formulate theories, and use tools to get more information.

    # 1. We have a question and some information about the context of the question.
    # 2. We gather more information about the context of the question by using tools and making observations.
    MakeObservations.new(question: question, history: history, tools: tools).run
    # 3. We formulate theories based on the question and the observations.
    # 4. We choose a theory to investigate.
    # 5. We try to immediately prove the theory based on the current information.
    # 5a. If we can formulate an answer based on the information then we validate the answer by proposing invalidation criteria.
    # 5b. If we can't immediately answer or all our answers are invalid continue to 6.
    # 5c. If we formulate an answer that could not be invalidated we return it.
    # 6. To investigate the theory we generate a list of questions that need to be answered to prove or disprove the theory.
    # 7. For each question we repeat the process starting at 1.
  end
end
end
