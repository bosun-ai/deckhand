module Task::Runnable
  extend ActiveSupport::Concern

  TASKS_DIR = Rails.root.join("tmp", "tasks")
  STANDARD_TIMEOUT = 3 * 60 # seconds

  def run
    FileUtils.mkdir_p(task_dir)
    File.write(script_path, script)
    FileUtils.chmod("+x", script_path)

    @runner = Async do
      input_read, input_write = Async::IO.pipe
      update! started_at: Time.now
      status = Async::Process::Child.new(%Q{bash -c "set -e; #{script_path}"},
        out: standard_output_path,
        in: input_read.io,
        err: error_output_path
      ).wait
    ensure
      begin
        [
          input_read, input_write
        ].each(&:close)
      ensure
        update! finished_at: Time.now, exit_code: status
        on_done if respond_to? :on_done
      end
    end
  end
  
  def await
    if @runner
      @runner.wait
    else
      raise "Task was not run from this object"
    end
  end

  def standard_output
    File.read(standard_output_path)
  end

  def error_output
    File.read(error_output_path)
  end

  def tail
    Async do
      output_read, output_write = Async::IO.pipe
      tail = Async::Process::Child.new("tail", "-f", standard_output_path, out: output_write.io)
    end
  end

  def task_dir
    File.join(TASKS_DIR, id.to_s)
  end

  def script_path
    File.join(task_dir, "script")
  end

  def standard_output_path
    File.join(task_dir, "out")
  end

  def error_output_path
    File.join(task_dir, "err")
  end
  private
end