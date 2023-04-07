require "test_helper"

class TaskTest < ActiveSupport::TestCase
  teardown do
    FileUtils.rm_rf(Task::TASKS_DIR)
  end

  test "running a task" do
    task = Task.run!(description: 'hello-test', script: "echo Hello")
    task.wait
    assert_equal "Hello\n", task.standard_output
    assert_equal 0, task.exit_code
  end
end
