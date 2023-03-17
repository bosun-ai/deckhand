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

### Example 1: Improving test coverage

To improve test coverage on a project the system should go through the following steps:

  - Establish current test coverage
  - Find public function with lowest test coverage and smallest amount of dependencies
  - Generate a test for the function
  - Run the test
  - Improve the test
  - Run the test again
  - Repeat from step 2

  