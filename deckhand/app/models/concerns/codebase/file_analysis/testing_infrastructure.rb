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
    root_context = Deckhand::Context.new("Analyzing the codebase")

    # First we have to establish a basic context of the codebase.
    root_context.add_observation("The codebase is named #{codebase.name}")
    root_context.add_observation("The codebase is located at #{codebase.path}")

    # Second we need to find out if the codebase has any test framework at all.
    question = "If the codebase has tests, what test framework is used?"

    answer = Deckhand::Tasks::SplitStepInvestigate.run(question, context: root_context.deep_dup)

    root_context.add_observation(answer)

    has_tests = JSON.parse(Deckhand::Tasks::ReformatAnswer.run("Does the codebase have tests?", answer, "json", example: { "has_tests": true }.to_json))["has_tests"]

    if !has_tests
      puts answer
      puts "The codebase does not have tests. Context: #{root_context.summarize_knowledge}"
      return root_context
    end

    # Third we need to find out if the codebase has a test runner.

    question = "If the codebase supports running the tests and generating a coverage report, what command should be used to do so?"

    answer = Deckhand::Tasks::SplitStepInvestigate.run(question, context: root_context.deep_dup)

    root_context.add_observation(answer)

    has_test_coverage = JSON.parse(Deckhand::Tasks::ReformatAnswer.run("Does the codebase have test coverage?", answer, "json", example: { "has_test_coverage": true }.to_json))["has_test_coverage"]

    if !has_test_coverage
      puts answer
      puts "The codebase does not have test coverage. Context: #{root_context.summarize_knowledge}"
      return root_context
    end

    puts "The codebase has test coverage. Context: #{root_context.summarize_knowledge}"

    root_context

    # analysis = Deckhand::Tasks::InvestigateWithTools.new.run(question)
    # JSON.parse(Deckhand::Tasks::ReformatAnswer.new.run(question, analysis, "json", example: { "has_tests": true }.to_json))

  end
end