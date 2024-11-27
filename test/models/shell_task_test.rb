require 'test_helper'

class ShellTaskTest < ActiveSupport::TestCase
  teardown do
    FileUtils.rm_rf(ShellTask::TASKS_DIR)
  end

  test 'running a shell_task' do
    shell_task = ShellTask.run!(description: 'hello-test', script: 'echo Hello')
    shell_task.wait
    sleep 0.2 # apparently the file isn't flushed yet at this point if we don't sleep
    assert_equal "Hello\n", shell_task.standard_output
    assert_equal 0, shell_task.exit_code
  end
end
