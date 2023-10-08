class GptMigrate::GptMigrateAgent < ApplicationAgent
  arguments :target_language

  def run
    # GPT migrate starts off with a source_lang, a target_lang, and a source_entry and the code checked out
    # somewhere in the filesystem. It then runs the following steps:
    
    # 1. It creates a docker environment

    # 2. Migration 
    # it recursively migrates source files, starting from the entrypoint and working its way through the
    # dependency graph. It splits dependencies based on wether they're internal or external.
    # It goes depth first on the internal dependencies, and in the base case it actually performs
    # the migration of the file, passing along the external dependencies to the migration function and
    # keeps track of the generated file for the parent file.

    # 3. Testing
    # First it validates it can run the application by repeatedly trying to start the application, and
    # if it fails it runs a debug_error function that attempts to correct problems in the environment.
    # Then it loops over all the files and generates tests for them.
    # Then for each generated file it validates the tests by running them against the original project.
    # As long as they fail they are corrected.
    # Then it runs the tests against the generated project in a loop, breaking when the test suite passes.
    # Every iteration that it does not pass it runs a debug_error function that attempts to correct problems in the 
    # codebase.
  end
end