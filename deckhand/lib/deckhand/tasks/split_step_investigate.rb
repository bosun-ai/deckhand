module Deckhand::Tasks
  class SplitStepInvestigate < Task

    def choose_theory(theories)
      theories.shift
    end

    def sort_theories(theories)
      theories
    end

    def run
      # To come to a correct answer we want to make observations, formulate theories, and use tools to get more information.

      # 1. We have a question and some information about the context of the question.
      # 2. We gather more information about the context of the question by using tools and making observations.
      GatherInformation.run(question, context: context, tools: tools)
      # 3. We formulate theories based on the question and the observations.
      theories = FormulateTheories.run(question, context: context, tools: tools)

      answer = nil

      while answer.nil? && theories.any?
        # 4. We choose a theory to investigate.
        theory = choose_theory(theories)

        conclusion = nil
        while conclusion.nil?
          # 5. We try to immediately prove the theory based on the current information.
          resolution = TryResolveTheory.run({ main_question: question, theory: theory}, context: context, tools: tools)

          if resolution.answer
            # 5a. If we can formulate an answer based on the information then we validate the answer by proposing invalidation criteria.
            refutation = TryRefuteTheory.run({ main_question: question, theory: theory, resolution: resolution.answer}, context: context, tools: tools)

            if refutation.correct
              conclusion = resolution.answer
            elsif refutation.incorrect
              conclusion = false
              # TODO try refuting the incorrectness assertion?
            end

            # 5b. If we can't immediately answer or all our answers are invalid continue to 6.
          elsif resolution.need_information
            # Add gather informatino to task stack
            GatherInformation.run(resolution.need_information, context: context, tools: tools)
          elsif resolution.incorrect
            conclusion = false
            # Discard theory
            # TODO try refuting the incorrectness assertion
          end
        end

        if conclusion
          answer = conclusion
        else
          theories = sort_theories(theories)
        end
      end

      # 5c. If we formulate an answer that could not be invalidated we return it.

      # 6. To investigate the theory we generate a list of questions that need to be answered to prove or disprove the theory.

      # 7. For each question we repeat the process starting at 1.

      answer
    end
  end
end
