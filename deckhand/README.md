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

## Architecture

Deckhand spawns tasks, which are running in Ruby threads or processes. Each
task manages input and output of a command, listens to the pubsub for new inputs to write to the proces, and writes notifications of output to the pubsub.

### Knowledge

Deckhand builds up knowledge about the codebases it is working on. For example to build the initial knowledge about the app Deckhand might go through the following process:

  1. List the contents of the root directory
  2. Prompt a language model for guidance on how to discover
     what technologies are used for this application and where the
     entrypoints are likely to be found.
  3. Store the information about the entrypoints in the knowledge database.
  4. Recursively go through each directory of the codebase, building up
     knowledge about each file.
  
So this knowledge has to be indexed somehow, and there are two indexes that
seem relevant: graph and vector.

With a knowledge graph, all relationships are rigid, we could establish a definite relationship between two facts. For example references of a type or function that are defined in another file, or at another location.

With a vector similarity index, we would create embeddings of the topics of the knowledge, or even the entire content of the fact, and then insert those embeddings into the index for later retrieval. The advantage is that it is basically unlimited and very powerful. The downside is that you can never be fully sure an embedding can be reliably used to retrieve the object.

I think we should start with a vector index, and then decide if it's reliable enough, if it's not then we'll have to put more thought into involving a graph database.

Redis-stack is easy to deploy and offers both a graph and a vector index, and can be used to store the data itself, so that seems a nice solution for the short term.