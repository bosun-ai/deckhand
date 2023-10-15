# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `async` gem.
# Please instead update this file by running `bin/tapioca gem async`.

# source://async//lib/async/version.rb#6
module Async; end

# A list of children tasks.
#
# source://async//lib/async/node.rb#14
class Async::Children < ::Async::List
  # @return [Children] a new instance of Children
  #
  # source://async//lib/async/node.rb#15
  def initialize; end

  # Whether all children are considered finished. Ignores transient children.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#27
  def finished?; end

  # Whether the children is empty, preserved for compatibility.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#32
  def nil?; end

  # Some children may be marked as transient. Transient children do not prevent the parent from finishing.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#22
  def transients?; end

  private

  # source://async//lib/async/node.rb#38
  def added(node); end

  # source://async//lib/async/node.rb#46
  def removed(node); end
end

# A convenient wrapper around the internal monotonic clock.
#
# source://async//lib/async/clock.rb#9
class Async::Clock
  # Create a new clock with the initial total time.
  #
  # @return [Clock] a new instance of Clock
  #
  # source://async//lib/async/clock.rb#34
  def initialize(total = T.unsafe(nil)); end

  # Start measuring a duration.
  #
  # source://async//lib/async/clock.rb#40
  def start!; end

  # Stop measuring a duration and append the duration to the current total.
  #
  # source://async//lib/async/clock.rb#45
  def stop!; end

  # The total elapsed time including any current duration.
  #
  # source://async//lib/async/clock.rb#55
  def total; end

  class << self
    # Measure the execution of a block of code.
    #
    # source://async//lib/async/clock.rb#18
    def measure; end

    # Get the current elapsed monotonic time.
    #
    # source://async//lib/async/clock.rb#11
    def now; end

    # Start measuring elapsed time from now.
    #
    # source://async//lib/async/clock.rb#28
    def start; end
  end
end

# A synchronization primitive, which allows fibers to wait until a particular condition is (edge) triggered.
#
# source://async//lib/async/condition.rb#13
class Async::Condition
  # @return [Condition] a new instance of Condition
  #
  # source://async//lib/async/condition.rb#14
  def initialize; end

  # Is any fiber waiting on this notification?
  #
  # @return [Boolean]
  #
  # source://async//lib/async/condition.rb#44
  def empty?; end

  # Signal to a given task that it should resume operations.
  #
  # source://async//lib/async/condition.rb#50
  def signal(value = T.unsafe(nil)); end

  # Queue up the current fiber and wait on yielding the task.
  #
  # source://async//lib/async/condition.rb#36
  def wait; end

  protected

  # source://async//lib/async/condition.rb#64
  def exchange; end
end

# source://async//lib/async/condition.rb#18
class Async::Condition::FiberNode < ::Async::List::Node
  # @return [FiberNode] a new instance of FiberNode
  #
  # source://async//lib/async/condition.rb#19
  def initialize(fiber); end

  # @return [Boolean]
  #
  # source://async//lib/async/condition.rb#27
  def alive?; end

  # source://async//lib/async/condition.rb#23
  def transfer(*arguments); end
end

# A general doublely linked list. This is used internally by {Async::Barrier} and {Async::Condition} to manage child tasks.
#
# source://async//lib/async/list.rb#8
class Async::List
  # Initialize a new, empty, list.
  #
  # @return [List] a new instance of List
  #
  # source://async//lib/async/list.rb#10
  def initialize; end

  # A callback that is invoked when an item is added to the list.
  #
  # source://async//lib/async/list.rb#48
  def added(node); end

  # Append a node to the end of the list.
  #
  # source://async//lib/async/list.rb#54
  def append(node); end

  # Iterate over each node in the linked list. It is generally safe to remove the current node, any previous node or any future node during iteration.
  #
  # source://async//lib/async/list.rb#173
  def each(&block); end

  # @return [Boolean]
  #
  # source://async//lib/async/list.rb#136
  def empty?; end

  # source://async//lib/async/list.rb#194
  def first; end

  # Points at the end of the list.
  #
  # source://async//lib/async/list.rb#40
  def head; end

  # Points at the end of the list.
  #
  # source://async//lib/async/list.rb#40
  def head=(_arg0); end

  # Determine whether the given node is included in the list.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/list.rb#185
  def include?(needle); end

  # Print a short summary of the list.
  #
  # source://async//lib/async/list.rb#17
  def inspect; end

  # source://async//lib/async/list.rb#211
  def last; end

  # source://async//lib/async/list.rb#67
  def prepend(node); end

  # Remove the node. If it was already removed, this will raise an error.
  #
  # You should be careful to only remove nodes that are part of this list.
  #
  # source://async//lib/async/list.rb#115
  def remove(node); end

  # Remove the node if it is in a list.
  #
  # You should be careful to only remove nodes that are part of this list.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/list.rb#101
  def remove?(node); end

  # A callback that is invoked when an item is removed from the list.
  #
  # source://async//lib/async/list.rb#91
  def removed(node); end

  # source://async//lib/async/list.rb#227
  def shift; end

  # Returns the value of attribute size.
  #
  # source://async//lib/async/list.rb#45
  def size; end

  # Add the node, yield, and the remove the node.
  #
  # source://async//lib/async/list.rb#83
  def stack(node, &block); end

  # Points at the start of the list.
  #
  # source://async//lib/async/list.rb#43
  def tail; end

  # Points at the start of the list.
  #
  # source://async//lib/async/list.rb#43
  def tail=(_arg0); end

  # Fast, safe, unbounded accumulation of children.
  #
  # source://async//lib/async/list.rb#24
  def to_a; end

  # Print a short summary of the list.
  #
  # source://async//lib/async/list.rb#17
  def to_s; end

  private

  # source://async//lib/async/list.rb#124
  def remove!(node); end
end

# source://async//lib/async/list.rb#241
class Async::List::Iterator < ::Async::List::Node
  # @return [Iterator] a new instance of Iterator
  #
  # source://async//lib/async/list.rb#242
  def initialize(list); end

  # source://async//lib/async/list.rb#285
  def each; end

  # source://async//lib/async/list.rb#270
  def move_current; end

  # source://async//lib/async/list.rb#260
  def move_next; end

  # source://async//lib/async/list.rb#252
  def remove!; end

  class << self
    # source://async//lib/async/list.rb#295
    def each(list, &block); end
  end
end

# A linked list Node.
#
# source://async//lib/async/list.rb#234
class Async::List::Node
  # Returns the value of attribute head.
  #
  # source://async//lib/async/list.rb#235
  def head; end

  # Sets the attribute head
  #
  # @param value the value to set the attribute head to.
  #
  # source://async//lib/async/list.rb#235
  def head=(_arg0); end

  def inspect; end

  # Returns the value of attribute tail.
  #
  # source://async//lib/async/list.rb#236
  def tail; end

  # Sets the attribute tail
  #
  # @param value the value to set the attribute tail to.
  #
  # source://async//lib/async/list.rb#236
  def tail=(_arg0); end
end

# A node in a tree, used for implementing the task hierarchy.
#
# source://async//lib/async/node.rb#56
class Async::Node
  # Create a new node in the tree.
  #
  # @return [Node] a new instance of Node
  #
  # source://async//lib/async/node.rb#59
  def initialize(parent = T.unsafe(nil), annotation: T.unsafe(nil), transient: T.unsafe(nil)); end

  # source://async//lib/async/node.rb#112
  def annotate(annotation); end

  # A useful identifier for the current node.
  #
  # source://async//lib/async/node.rb#126
  def annotation; end

  # source://async//lib/async/node.rb#142
  def backtrace(*arguments); end

  # Returns the value of attribute children.
  #
  # source://async//lib/async/node.rb#91
  def children; end

  # Whether this node has any children.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#98
  def children?; end

  # If the node has a parent, and is {finished?}, then remove this node from
  # the parent.
  #
  # source://async//lib/async/node.rb#195
  def consume; end

  # source://async//lib/async/node.rb#130
  def description; end

  # Whether the node can be consumed (deleted) safely. By default, checks if the children set is empty.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#189
  def finished?; end

  # @private
  #
  # source://async//lib/async/node.rb#82
  def head; end

  # @private
  #
  # source://async//lib/async/node.rb#82
  def head=(_arg0); end

  # source://async//lib/async/node.rb#146
  def inspect; end

  # Returns the value of attribute parent.
  #
  # source://async//lib/async/node.rb#88
  def parent; end

  # Change the parent of this node.
  #
  # source://async//lib/async/node.rb#156
  def parent=(parent); end

  # source://async//lib/async/node.rb#266
  def print_hierarchy(out = T.unsafe(nil), backtrace: T.unsafe(nil)); end

  # source://async//lib/async/node.rb#77
  def root; end

  # Attempt to stop the current node immediately, including all non-transient children. Invokes {#stop_children} to stop all children.
  #
  # source://async//lib/async/node.rb#250
  def stop(later = T.unsafe(nil)); end

  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#262
  def stopped?; end

  # @private
  #
  # source://async//lib/async/node.rb#85
  def tail; end

  # @private
  #
  # source://async//lib/async/node.rb#85
  def tail=(_arg0); end

  # Immediately terminate all children tasks, including transient tasks. Internally invokes `stop(false)` on all children. This should be considered a last ditch effort and is used when closing the scheduler.
  #
  # source://async//lib/async/node.rb#235
  def terminate; end

  # source://async//lib/async/node.rb#146
  def to_s; end

  # Represents whether a node is transient. Transient nodes are not considered
  # when determining if a node is finished. This is useful for tasks which are
  # internal to an object rather than explicit user concurrency. For example,
  # a child task which is pruning a connection pool is transient, because it
  # is not directly related to the parent task, and should not prevent the
  # parent task from finishing.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/node.rb#108
  def transient?; end

  # Traverse the task tree.
  #
  # source://async//lib/async/node.rb#220
  def traverse(&block); end

  protected

  # source://async//lib/async/node.rb#175
  def add_child(child); end

  # source://async//lib/async/node.rb#181
  def remove_child(child); end

  # source://async//lib/async/node.rb#171
  def set_parent(parent); end

  # @yield [_self, level]
  # @yieldparam _self [Async::Node] the object that the method was called on
  #
  # source://async//lib/async/node.rb#226
  def traverse_recurse(level = T.unsafe(nil), &block); end

  private

  # source://async//lib/async/node.rb#278
  def print_backtrace(out, indent, node); end

  # Attempt to stop all non-transient children.
  #
  # source://async//lib/async/node.rb#256
  def stop_children(later = T.unsafe(nil)); end
end

# A wrapper around the the scheduler which binds it to the current thread automatically.
#
# source://async//lib/async/reactor.rb#12
class Async::Reactor < ::Async::Scheduler
  # @return [Reactor] a new instance of Reactor
  #
  # source://async//lib/async/reactor.rb#18
  def initialize(*_arg0, **_arg1, &_arg2); end

  # source://async//lib/async/reactor.rb#24
  def scheduler_close; end

  def sleep(*_arg0); end

  class << self
    # @deprecated Replaced by {Kernel::Async}.
    #
    # source://async//lib/async/reactor.rb#14
    def run(*_arg0, **_arg1, &_arg2); end
  end
end

# Handles scheduling of fibers. Implements the fiber scheduler interface.
#
# source://async//lib/async/scheduler.rb#19
class Async::Scheduler < ::Async::Node
  # @return [Scheduler] a new instance of Scheduler
  #
  # source://async//lib/async/scheduler.rb#32
  def initialize(parent = T.unsafe(nil), selector: T.unsafe(nil)); end

  # source://async//lib/async/scheduler.rb#161
  def address_resolve(hostname); end

  # Start an asynchronous task within the specified reactor. The task will be
  # executed until the first blocking call, at which point it will yield and
  # and this method will return.
  #
  # This is the main entry point for scheduling asynchronus tasks.
  #
  # @deprecated With no replacement.
  #
  # source://async//lib/async/scheduler.rb#303
  def async(*arguments, **options, &block); end

  # Invoked when a fiber tries to perform a blocking operation which cannot continue. A corresponding call {unblock} must be performed to allow this fiber to continue.
  #
  # source://async//lib/async/scheduler.rb#118
  def block(blocker, timeout); end

  # source://async//lib/async/scheduler.rb#53
  def close; end

  # @return [Boolean]
  #
  # source://async//lib/async/scheduler.rb#77
  def closed?; end

  # source://async//lib/async/scheduler.rb#321
  def fiber(*_arg0, **_arg1, &_arg2); end

  # Interrupt the event loop and cause it to exit.
  #
  # source://async//lib/async/scheduler.rb#87
  def interrupt; end

  # source://async//lib/async/scheduler.rb#190
  def io_read(io, buffer, length, offset = T.unsafe(nil)); end

  # source://async//lib/async/scheduler.rb#169
  def io_wait(io, events, timeout = T.unsafe(nil)); end

  # source://async//lib/async/scheduler.rb#152
  def kernel_sleep(duration = T.unsafe(nil)); end

  # Wait for the specified process ID to exit.
  #
  # source://async//lib/async/scheduler.rb#206
  def process_wait(pid, flags); end

  # Schedule a fiber (or equivalent object) to be resumed on the next loop through the reactor.
  #
  # source://async//lib/async/scheduler.rb#104
  def push(fiber); end

  # source://async//lib/async/scheduler.rb#108
  def raise(*arguments); end

  # source://async//lib/async/scheduler.rb#112
  def resume(fiber, *arguments); end

  # Run the reactor until all tasks are finished. Proxies arguments to {#async} immediately before entering the loop, if a block is provided.
  #
  # source://async//lib/async/scheduler.rb#273
  def run(*_arg0, **_arg1, &_arg2); end

  # Run one iteration of the event loop.
  # Does not handle interrupts.
  #
  # source://async//lib/async/scheduler.rb#214
  def run_once(timeout = T.unsafe(nil)); end

  # source://async//lib/async/scheduler.rb#43
  def scheduler_close; end

  # source://async//lib/async/scheduler.rb#341
  def timeout_after(duration, exception, message, &block); end

  # source://async//lib/async/scheduler.rb#81
  def to_s; end

  # Transfer from the calling fiber to the event loop.
  #
  # source://async//lib/async/scheduler.rb#93
  def transfer; end

  # source://async//lib/async/scheduler.rb#141
  def unblock(blocker, fiber); end

  # Invoke the block, but after the specified timeout, raise {TimeoutError} in any currenly blocking operation. If the block runs to completion before the timeout occurs or there are no non-blocking operations after the timeout expires, the code will complete without any exception.
  #
  # source://async//lib/async/scheduler.rb#327
  def with_timeout(duration, exception = T.unsafe(nil), message = T.unsafe(nil), &block); end

  # Yield the current fiber and resume it on the next iteration of the event loop.
  #
  # source://async//lib/async/scheduler.rb#98
  def yield; end

  private

  # Checks and clears the interrupted state of the scheduler.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/scheduler.rb#259
  def interrupted?; end

  # Run one iteration of the event loop.
  #
  # When terminating the event loop, we already know we are finished. So we don't need to check the task tree. This is a logical requirement because `run_once` ignores transient tasks. For example, a single top level transient task is not enough to keep the reactor running, but during termination we must still process it in order to terminate child tasks.
  #
  # source://async//lib/async/scheduler.rb#231
  def run_once!(timeout = T.unsafe(nil)); end

  class << self
    # Whether the fiber scheduler is supported.
    #
    # @return [Boolean]
    #
    # source://async//lib/async/scheduler.rb#28
    def supported?; end
  end
end

# source://async//lib/async/scheduler.rb#20
class Async::Scheduler::ClosedError < ::RuntimeError
  # @return [ClosedError] a new instance of ClosedError
  #
  # source://async//lib/async/scheduler.rb#21
  def initialize(message = T.unsafe(nil)); end
end

# Raised when a task is explicitly stopped.
#
# source://async//lib/async/task.rb#16
class Async::Stop < ::Exception; end

# source://async//lib/async/task.rb#17
class Async::Stop::Later
  # @return [Later] a new instance of Later
  #
  # source://async//lib/async/task.rb#18
  def initialize(task); end

  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#22
  def alive?; end

  # source://async//lib/async/task.rb#26
  def transfer; end
end

# source://async//lib/async/task.rb#41
class Async::Task < ::Async::Node
  # Create a new task.
  #
  # @return [Task] a new instance of Task
  #
  # source://async//lib/async/task.rb#56
  def initialize(parent = T.unsafe(nil), finished: T.unsafe(nil), **options, &block); end

  # Whether the internal fiber is alive, i.e. it
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#118
  def alive?; end

  # source://async//lib/async/task.rb#79
  def annotate(annotation, &block); end

  # source://async//lib/async/task.rb#87
  def annotation; end

  # Run an asynchronous task as a child of the current task.
  #
  # @raise [FinishedError]
  #
  # source://async//lib/async/task.rb#168
  def async(*arguments, **options, &block); end

  # source://async//lib/async/task.rb#75
  def backtrace(*arguments); end

  # The task has completed execution and generated a result.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#145
  def complete?; end

  # The task has completed execution and generated a result.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#145
  def completed?; end

  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#254
  def current?; end

  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#135
  def failed?; end

  # @attr fiber [Fiber] The fiber which is being used for the execution of this task.
  #
  # source://async//lib/async/task.rb#115
  def fiber; end

  # Whether we can remove this node from the reactor graph.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#124
  def finished?; end

  # source://async//lib/async/task.rb#71
  def reactor; end

  # Access the result of the task without waiting. May be nil if the task is not completed. Does not raise exceptions.
  #
  # source://async//lib/async/task.rb#201
  def result; end

  # Begin the execution of the task.
  #
  # source://async//lib/async/task.rb#155
  def run(*arguments); end

  # Whether the task is running.
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#131
  def running?; end

  # @deprecated Prefer {Kernel#sleep} except when compatibility with `stable-v1` is required.
  #
  # source://async//lib/async/task.rb#100
  def sleep(duration = T.unsafe(nil)); end

  # @attr status [Symbol] The status of the execution of the fiber, one of `:initialized`, `:running`, `:complete`, `:stopped` or `:failed`.
  #
  # source://async//lib/async/task.rb#152
  def status; end

  # Stop the task and all of its children.
  #
  # If `later` is false, it means that `stop` has been invoked directly. When `later` is true, it means that `stop` is invoked by `stop_children` or some other indirect mechanism. In that case, if we encounter the "current" fiber, we can't stop it right away, as it's currently performing `#stop`. Stopping it immediately would interrupt the current stop traversal, so we need to schedule the stop to occur later.
  #
  # source://async//lib/async/task.rb#208
  def stop(later = T.unsafe(nil)); end

  # The task has been stopped
  #
  # @return [Boolean]
  #
  # source://async//lib/async/task.rb#140
  def stopped?; end

  # source://async//lib/async/task.rb#95
  def to_s; end

  # Retrieve the current result of the task. Will cause the caller to wait until result is available. If the result was an exception, raise that exception.
  #
  # Conceptually speaking, waiting on a task should return a result, and if it throws an exception, this is certainly an exceptional case that should represent a failure in your program, not an expected outcome. In other words, you should not design your programs to expect exceptions from `#wait` as a normal flow control, and prefer to catch known exceptions within the task itself and return a result that captures the intention of the failure, e.g. a `TimeoutError` might simply return `nil` or `false` to indicate that the operation did not generate a valid result (as a timeout was an expected outcome of the internal operation in this case).
  #
  # source://async//lib/async/task.rb#184
  def wait; end

  # Execute the given block of code, raising the specified exception if it exceeds the given duration during a non-blocking operation.
  #
  # source://async//lib/async/task.rb#105
  def with_timeout(duration, exception = T.unsafe(nil), message = T.unsafe(nil), &block); end

  # Yield back to the reactor and allow other fibers to execute.
  #
  # source://async//lib/async/task.rb#110
  def yield; end

  private

  # State transition into the completed state.
  #
  # source://async//lib/async/task.rb#277
  def completed!(result); end

  # This is a very tricky aspect of tasks to get right. I've modelled it after `Thread` but it's slightly different in that the exception can propagate back up through the reactor. If the user writes code which raises an exception, that exception should always be visible, i.e. cause a failure. If it's not visible, such code fails silently and can be very difficult to debug.
  #
  # source://async//lib/async/task.rb#283
  def failed!(exception = T.unsafe(nil), propagate = T.unsafe(nil)); end

  # Finish the current task, moving any children to the parent.
  #
  # source://async//lib/async/task.rb#261
  def finish!; end

  # source://async//lib/async/task.rb#325
  def schedule(&block); end

  # Set the current fiber's `:async_task` to this task.
  #
  # source://async//lib/async/task.rb#348
  def set!; end

  # source://async//lib/async/task.rb#319
  def stop!; end

  # source://async//lib/async/task.rb#299
  def stopped!; end

  class << self
    # Lookup the {Task} for the current fiber. Raise `RuntimeError` if none is available.
    # @raises[RuntimeError] If task was not {set!} for the current fiber.
    #
    # source://async//lib/async/task.rb#244
    def current; end

    # Check if there is a task defined for the current fiber.
    #
    # @return [Boolean]
    #
    # source://async//lib/async/task.rb#250
    def current?; end

    # @deprecated With no replacement.
    #
    # source://async//lib/async/task.rb#49
    def yield; end
  end
end

# source://async//lib/async/task.rb#42
class Async::Task::FinishedError < ::RuntimeError
  # @return [FinishedError] a new instance of FinishedError
  #
  # source://async//lib/async/task.rb#43
  def initialize(message = T.unsafe(nil)); end
end

# Raised if a timeout occurs on a specific Fiber. Handled gracefully by `Task`.
#
# source://async//lib/async/task.rb#34
class Async::TimeoutError < ::StandardError
  # @return [TimeoutError] a new instance of TimeoutError
  #
  # source://async//lib/async/task.rb#35
  def initialize(message = T.unsafe(nil)); end
end

# source://async//lib/async/version.rb#7
Async::VERSION = T.let(T.unsafe(nil), String)

# Represents an asynchronous IO within a reactor.
#
# @deprecated With no replacement. Prefer native interfaces.
#
# source://async//lib/async/wrapper.rb#10
class Async::Wrapper
  # @return [Wrapper] a new instance of Wrapper
  #
  # source://async//lib/async/wrapper.rb#17
  def initialize(io, reactor = T.unsafe(nil)); end

  # Close the io and monitor.
  #
  # source://async//lib/async/wrapper.rb#55
  def close; end

  # @return [Boolean]
  #
  # source://async//lib/async/wrapper.rb#59
  def closed?; end

  # source://async//lib/async/wrapper.rb#26
  def dup; end

  # The underlying native `io`.
  #
  # source://async//lib/async/wrapper.rb#31
  def io; end

  # Returns the value of attribute reactor.
  #
  # source://async//lib/async/wrapper.rb#24
  def reactor; end

  # Sets the attribute reactor
  #
  # @param value the value to set the attribute reactor to.
  #
  # source://async//lib/async/wrapper.rb#24
  def reactor=(_arg0); end

  # Wait fo the io to become either readable or writable.
  #
  # source://async//lib/async/wrapper.rb#50
  def wait_any(timeout = T.unsafe(nil)); end

  # Wait for the io to become writable.
  #
  # source://async//lib/async/wrapper.rb#39
  def wait_priority(timeout = T.unsafe(nil)); end

  # Wait for the io to become readable.
  #
  # source://async//lib/async/wrapper.rb#34
  def wait_readable(timeout = T.unsafe(nil)); end

  # Wait for the io to become writable.
  #
  # source://async//lib/async/wrapper.rb#44
  def wait_writable(timeout = T.unsafe(nil)); end
end

# An exception that occurs when the asynchronous operation was cancelled.
#
# source://async//lib/async/wrapper.rb#12
class Async::Wrapper::Cancelled < ::StandardError; end

# Extensions to all Ruby objects.
#
# source://async//lib/kernel/async.rb#8
module Kernel
  # Run the given block of code in a task, asynchronously, creating a reactor if necessary.
  #
  # The preferred method to invoke asynchronous behavior at the top level.
  #
  # - When invoked within an existing reactor task, it will run the given block
  # asynchronously. Will return the task once it has been scheduled.
  # - When invoked at the top level, will create and run a reactor, and invoke
  # the block as an asynchronous task. Will block until the reactor finishes
  # running.
  #
  # source://async//lib/kernel/async.rb#24
  def Async(*_arg0, **_arg1, &_arg2); end

  # Run the given block of code synchronously, but within a reactor if not already in one.
  #
  # source://async//lib/kernel/sync.rb#18
  def Sync(&block); end
end
