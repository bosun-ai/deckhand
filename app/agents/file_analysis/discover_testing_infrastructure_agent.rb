class FileAnalysis::DiscoverTestingInfrastructureAgent < ApplicationAgent
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
  def run
    codebase = context.codebase

    # First we have to establish a basic context of the codebase.
    context.add_observation("The codebase is named #{codebase.name}")
    context.add_observation('The codebase is checked out locally and tools can use paths relative to the root of the codebase like `./README.md`.')

    question = 'What languages and frameworks are used in the codebase?'

    answer = run(SplitStepInvestigateAgent, question, context: context.deep_dup).output
    context.add_observation("Question: #{question} Answer: #{answer}")

    question = "What is the purpose of the project?"
    answer = run(SplitStepInvestigateAgent, question, context: context.deep_dup).output
    context.add_observation("Question: #{question} Answer: #{answer}")

    # Second we need to find out if the codebase has any test framework at all.
    question = 'If the codebase has tests, what test framework is used?'

    answer = run(SplitStepInvestigateAgent, question, context: context.deep_dup).output || "No"

    context.add_observation("Question: #{question} Answer: #{answer}")

    tests_response = run(
        ReformatAnswerAgent,
        "Does the codebase have tests?",
        answer,
        "json",
        example: { "has_tests": true }.to_json,
        context: context.deep_dup
      ).output

    has_tests = false
    begin
      # sometimes it is surrounded with markdown codeblock quotes and the json prefix, so try to remove that:
      tests_response = tests_response.gsub(/^```(json)?/, "").gsub(/```$/, "")
      has_tests = parse_json(tests_response)["has_tests"]
    rescue => e
      raise "Could not extract 'has_tests' from object: #{tests_response.inspect}"
    end

    if !has_tests
      codebase.update! context: context
      return context
    end

    # Third we need to find out if the codebase has a test runner.

    question = 'If the codebase supports running the tests and generating a coverage report, what command should be used to do so?'

    answer = run(SplitStepInvestigateAgent, question, context: context.deep_dup).output || "No"

    context.add_observation("Question: #{question} Answer: #{answer}")

    has_test_coverage = parse_json(run(
      ReformatAnswerAgent,
      "Does the codebase have test coverage?",
      answer,
      "json",
      example: { "has_test_coverage": true }.to_json,
      context: context.deep_dup
    ).output)["has_test_coverage"]

    if !has_test_coverage
      codebase.update! context: context
      return context
    end

    codebase.update! context: context

    
    # analysis = Deckhand::Tasks::InvestigateWithTools.new.run(question)
    # parse_json(Deckhand::Tasks::ReformatAnswer.new.run(question, analysis, "json", example: { "has_tests": true }.to_json))

  end
end
