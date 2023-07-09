Proof of concept
=============

The work on answering arbitrary questions is getting a bit out of hand. To really show the value of the project there
should be an initial proof of concept that shows both the business value of Deckhand, but also the promise that the
value can really be achieved by an LLM based system that is powerful enough.

## Examples of value

The original idea that sparked this project was the mind numbingly simple but repetitive task of converting a
medium sized application from Vue 2 to Vue 3. The guide on how to do this fits comfortably in a GPT4 context and might
even be in its training set already.

Other examples of value: converting a Ruby project to Python to follow the talent market preference. Converting a .Net
project into .Net Core so it does not fall outside support. Same for Java 7 to Java 8.

## Minimum demonstration of ability

### Vue 2 -> 3

Follow the guide, converting the code one block at a time. Would probably be easy to do for something like an Angular
conversion as well. We could adapt the guide to something more suitable for an LLM to follow manually.

Final result is just a merge request that you can check out and see if your app runs.

## Ruby -> Python

Probably too complicated for an 1 weekend demo, something like GPT Migrate could do this, but it's really rudimentary 
 and leaves out all the difficult aspects of this problem at the moment. This is what the `SplitStepInvestigate` task
 is supposed to accomplish but it's getting out of hand with the complexity.

## .Net to .Net Core, Java 7 -> Java 8

This might be achievable, the list of incompatabilities is probably not so large. Especially Java would be achievable
because it runs on Linux, so we could just start a Docker container with Java 7, compile it, then do the port, upgrade
to 8 and then compile that with a Java 8 Docker container. For the demo we can just assume that if it compiles it works.


