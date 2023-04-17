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

### Knowledge database

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


#### Examples of facts

There is a `rails` file in the `bin` directory.

The class `ApplicationController` is defined in  `app/controllers/application_controller.rb`.

The method `authorize` is defined on line 30 in the `ApplicationController` class defined in `app/controllers/application_controller.rb`.

The method `authorize` defined on line 30 in the `ApplicationController` class defined in `app/controllers/application_controller.rb` calls a method called `super` on line 31.

#### Knowledge graph

```cypher
(File {location: 'app/controllers/application_controller.rb'}) - [on_line(10)] - (Class { id: '<uuid>', name: 'ApplicationController'})
```

```cypher
(Method {name: 'authorize'}) - [on_line(30)] - (Class { id: '<uuid>'})
```

#### Example query

To write a test for an endpoint on a rails application, we need to build a prompt that includes information about all relevant code. So following the command "implement an integration test for this endpoint" it will query:

- the code under test
- any code it references
- any side effects that affect the code or its result
- any code it could reference that might be relevant

Some of these queries will be recursive if necessary.

#### Building the database

For each file, we'll have to parse through the file, finding all definitions of relevance. For each definition entries in the knowledge database will be made that summarise the associated body or values, record external references and other properties, and placing them within the graph.

Because files often don't fit into the prompt context, we have feed in the files piecemeal, keeping context outside of the prompt, or cutting out irrelevant information from the prompt.

(sidenote: at some point a system will probably be able to write a parser that removes irrelevant information from files in arbitrary programming languages)

### Counterpoint

Instead of building a knowledge base a priori, we could also gather knowledge on demand. This is more how Github Copilot seems to do it, where they only have context about recent files that you've opened.

For the system to autonomously implement a unit test, it would:

  - generate search terms
  - browse through the codebase
  - browse through the internet
  - determine if things are relevant

It would loop through this a couple time to build a lingo and a set of relevant knowledge. When the knowledge is complete enough, it could make attempts at implementing the test. Run it, figure out what's wrong and then attempt to fix the code.

Both the database solution and this solution have the same problem. How to determine what's relevant? And how would the structuring of the database improve the prompt generation over just asking the model if code is relevant?

The database should assist the model in keeping more context on hand than is available in the current prompt. Instead of generating a structured graph database that just has everything in it, we could just have the language model only build the facts and the graph based on what it deems to be relevant to the problem at hand.

Example prompt:

  - To generate a test I need to fully understand the method I am testing. To understand it I need to know the answers to the following questions:
    - What code triggers the execution of this method, and what is its intention?
    - What code is triggered by the execution of this method?
    - What values are within the scope of this method and how is the scope affected?
    - What effects are the final results of the method / what do we want it to do?
  - To generate the test I need to know understand the context I am testing in. To understand that I need to know:
    - What facilities are there for setting up the test environment?
    - What helpers are available to assert the method has succesfully performed its intended behaviour?

For each step of gathering knowledge, the system will perform search queries, both in the codebase and online.

I think it will be more effective to perform codebase search queries in a graph database than it would be in the raw codebase, just because we can more easily isolate relevant facts.