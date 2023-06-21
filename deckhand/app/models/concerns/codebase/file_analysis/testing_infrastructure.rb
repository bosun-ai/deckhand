class Codebase::FileAnalysis::TestingInfrastructure < Struct.new(:codebase, keyword_init: true)
  def self.run(codebase)
    new(codebase: codebase)
      .analyze_codebase()
  end

  # Strategy:
  # We have access to a code assistant that we can ask questions about general facts known on the internet and it will
  # apply basic reasoning to answer those questions. We call this assistant the LLM. We ask a question from our code
  # in the following way: `LLM.prompt("What is the capital of France?")`. The LLM will then respond with a string.
  #
  # We want the LLM to generate a set of bash scripts:
  #
  # 1. One script that will run all the tests in the codebase.
  # 2. One script that will run all the tests in a single file.
  # 3. One script that will run a single test in a single file.
  #
  # For each of those scripts we want to receive a coverage report at the end of the run.
  def analyze_codebase
    # First we need to find out if the codebase has any test framework at all.
    question = "Does the codebase have any tests?"
    analysis = Deckhand::Tasks::InvestigateWithTools.new.run(question)
    JSON.parse(Deckhand::Tasks::ReformatAnswer.new.run(question, analysis, "json", example: { "has_tests": true }.to_json))
  end
end