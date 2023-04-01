require 'async/io/stream'

module Task::Runnable
  extend ActiveSupport::Concern

  TASKS_DIR = Rails.root.join("tmp", "tasks")
  STANDARD_TIMEOUT = 3 * 60 # seconds

  def run
    FileUtils.mkdir_p(task_dir)
    File.write(script_path, script)
    FileUtils.chmod("+x", script_path)
    FileUtils.touch standard_output_path

    update! started_at: Time.now
    # TODO instead of writing out and err to separate files only, also
    # write them to a combined file. This will allow us to tail the
    # combined file and show the output in the UI.
    @process = Deckhand::Process.spawn(
      %Q{bash -c "set -e; cd #{task_dir}; #{script_path}"},
      out: standard_output_path,
    ) do |status|
        update! finished_at: Time.now, exit_code: status
        on_done if respond_to? :on_done
      end
    end
  end

  def standard_output
    File.read(standard_output_path)
  end

  def error_output
    File.read(error_output_path)
  end

  def tail(&callback)
    @process.tail(&callback)
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