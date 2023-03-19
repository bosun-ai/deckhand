require "test_helper"

class TaskTest < ActiveSupport::TestCase
  teardown do
    FileUtils.rm_rf(Task::TASKS_DIR)
  end

  test "running a task" do
    Sync do
      task = Task.run!(description: 'hello-test', script: "echo Hello")
      task.await
      assert_equal "Hello\n", task.standard_output
      assert_equal 0, task.exit_code
    end
  end

  test "running a process" do
    Sync do
      output_read, output_write = Async::IO.pipe
      input_read, input_write = Async::IO.pipe
      status = nil
      result = nil
      child = nil

      runner = Async do
        child = Async::Process::Child.new(
          "cat",
          out: output_write.io,
          in: input_read.io)
      ensure
        output_write.close
      end

      Async do
        input_write.write "Hello"
      ensure
        input_write.close
      end

      Sync do
        result = output_read.read
        status = child.wait
      ensure
        input_read.close
        output_read.close
        input_write.close
        output_write.close
      end

      assert status.success?
      assert_equal result, "Hello"
    end
  end
end
