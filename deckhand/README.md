# Bosun Deckhand

Bosun deckhand is a system that applies tasks on a software repository.

### Tasks:

  - Control git repositories
  - Install dependencies
  - Run tools
  - Apply source patches

### In support of these tasks it has the following features:

  - Keep track of tasks
  - Keep logs of actions
  - Store facts for later recollection

## Flow

The deckhand will take instructions and construct task planning through a language model.

The user starts this process by first adding a codebase through a git url. The
system clones the repository, and then does analysis on it to discover what sort
of project it is and installs any tooling needed for operating the project.

The user is then presented with a list of possible operations deckhand could perform on the codebase, such as improving the test coverage.

The user selects improve the test coverage. 

### Example 1: Improving test coverage

To improve test coverage on a project the system should go through the following steps:

  1. Establish current test coverage
  2. Find public function with lowest test coverage and smallest amount of dependencies
  3. Generate a test for the function
  4. Run the test
  5. Improve the test
  6. Run the test again
  7. Repeat from step 2

