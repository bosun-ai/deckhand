# Bosun Deckhand

Bosun deckhand is a system that applies tasks on a software repository.

## Running

Make a .env with these values:
```
OPENAI_ACCESS_TOKEN=<snip>
GITHUB_APP_IDENTIFIER=361955
GITHUB_APP_KEY=<SNIP>
REDIS_URL=<snip>
```

Then

```
  bundle
  ps aux |grep redis
  # kill all redis
  kill <redispid>
  ./bin/dev
```

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

.#### Building the database

For each file, we'll have to parse through the file, finding all definitions of relevance. For each definition entries in the knowledge database will be made that summarise the associated body or values, record external references and other properties, and placing them within the graph.

Because files often don't fit into the prompt context, we have feed in the files piecemeal, keeping context outside of the prompt, or cutting out irrelevant information from the prompt.

(sidenote: at some point a system will probably be able to write a parser that removes irrelevant information from files in arbitrary programming languages)

#### Counterpoint

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

### Automatic reasoning

To discover information and establish useful facts about the codebase we need an automatic reasoning system that can
gather information, formulate theories and consider their correctness.

Because validating a theory usually involves formulating and validating more theories, the reasoning process will be
a tree, a DAG or maybe even a full graph. The graph will grow as information is gathered, new theories are generated,
validated or refuted. Since it is a graph, it can be traversed in several ways: naively in either depth first or breadth
first, or more sophisticated in a way where different branches are weighted by a machine learning system and the most
promising (or most cheap?) options are explored first.

If we go breadth first we might waste a lot of time expanding the search space indefinitely. If we go depth first we
might spend a lot of effort trying to establish something that takes too much effort to establish. An easy way to
avoid this would be to always order options by some metric decided by the LLM. For example ask the LLM to reorder the
list of options by chance of likelihood of truth, or the expected amount of work.

#### Architecture

We split up the different tasks in the reasoning system in their own modules. Each task has an input and an output
object that's specific to that task. In addition they receive a context object from whatever system invoked them. The
context object needs to be carefully designed so it can be made useful to any task.

##### Context

A context establishes a history of what has happened before the current point. In that way it is like an event log that
has multiple types of events added to it. A task could ask of it all events, or maybe only events of a certain type.

The context could have associated helper functions that formulate the context in a way that is suitable for LLM
prompting.

Besides controlling and accessing the log of historic events, a context might also be rolled up into a parent context
when a chain of reasoning is wrapped up. At first I thought this might be a function that's implemented by the context
but now that I've typed this out I think it makes more sense if this is something that's done by the task that is
wrapping up.

#### Information types

As the system is reasoning different types of information are generated:

    observations, theories, facts (conclusions), tool outputs

#### Execution

There is a simple process for working towards a conclusion to any theory, but there are many branches within that
process.


### Data gathering steps

Information gathering steps:

1. General techniques / technologies used
2. External dependencies
3. Gather information about codebase structure
4. Modules and public members

#### General techniques and technologies

In this step we want to discover what programming language is used, wether the codebase is a library, a network service,
 a website, a commandline tool, a system service, a component or plugin, a desktop application, a hardware driver or
  operating system.

In that category we also want to determine what tooling is used for dependency management, compilation, testing, 
deployment and running.

For example a project written in Ruby could be packaged as a Gem and/or have dependencies be managed using bundler.
There are hints about what tooling is used strewn about the repository. For example the presence of a `Gemspec` or
`Gemfile` and `Gemfile.lock` files. The presence of a `config.ru` or a `bin` or `exe` directory. There might also be
a `Dockerfile`. Often there's a `README.md` or other documentation files explaining how to perform common tasks in the
project.

#### External dependencies

Once the tooling is established it should in most cases be possible to discover all external dependencies. Either using
very well defined dependency files like a `Gemfile`, `package.json` or `Cargo.toml` or less well defined like Python's
`requirements.txt` or C++'s `CMake` or even less defined like preparations listed in documentation or based on the steps
defined in a `Dockerfile` or `Makefile`. Some programming languages like Go and I think Deno even have their external
dependencies at the top of every codefile, though I believe both have switched away from that now. 

Once the dependencies are enumerated information about what resources they expose to the project should be memorized.
Usually dependencies expose modules with public members, but some dependencies add other things like testing or 
deployment infrastructure. Some dependencies form a framework in which the codebase is embedded, and they could dictate
where the entrypoints and endpoints are located.

#### Codebase structure

During this step it should be established how code is organized in the project. Where the entrypoints are, where the
endpoints are defined, where the tests are. What files expose certain functionalities, like models, views, controllers.
What directories organize the codebase by those functionalities, or by solution domains.

#### Modules and public members

For each code file it should be determined what names are exposed to other files within the project, or to users of the
project. The result of this step should be a dependency graph, that could be traversed from the leaves inward during 
whole codebase analysis or transformation steps. Or outward from a node in a targeted operation.

### Premature optimizations

Various techniques could be applied to improve the performance in several ways. Unless there's some bottleneck that
prevents feasibility these techniques are probably not worth exploring until clear value has been demonstrated and there
is a demonstrated need for them.

#### Self-controlled / Alternative LLM's

There's LLM's we could run ourselves such as LLama2 and finetuned variants. Unless one of them very decidedly out
performs GPT4 in quality or there is an extreme cost benefit we don't need to bother with running our own LLM or even
switching to another one.

#### Finetuning LLM's

There exists increasingly sophisticated tooling that could be used for finetuning high quality pretrained LLM's like 
LLama2 or fancy extra cheap LLM's like Microsoft's (announced but not yet released) Phi. We could for example train
a model to be very good at translating between certain language pairs, or to have intimate knowledge of the problem
domain of a certain codebase, after which accuracy is increased for the model, and cost is reduced.