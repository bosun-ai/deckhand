require 'async/io/stream'
require 'deckhand/process'

module Task::Runnable
  extend ActiveSupport::Concern

  TASKS_DIR = Rails.root.join("tmp", "tasks")
  STANDARD_TIMEOUT = 3 * 60 # seconds

  def run(lines_mode: true, &callback)
    FileUtils.mkdir_p(task_dir)
    File.write(script_path, script)
    FileUtils.chmod("+x", script_path)
    FileUtils.touch standard_output_path

    @buffer = ""
    @lines_mode = lines_mode
    @callback = callback

    update! started_at: Time.now
    # TODO instead of writing out and err to separate files only, also
    # write them to a combined file. This will allow us to tail the
    # combined file and show the output in the UI.
    @process = Deckhand::Process.spawn(
      %Q{bash -c "set -e; cd #{task_dir}; #{script_path}"},
      out: standard_output_path,
    ) do |message|
      if buffer = message[:buffer]
        on_buffer(buffer)
      elsif status = message[:status]
        update! finished_at: Time.now, exit_code: status
        on_done(status)
      end
    end
  end

  def standard_output
    File.read(standard_output_path)
  end

  def error_output
    File.read(error_output_path)
  end

  def on_buffer(buffer)
    if @lines_mode
      on_buffer_lines_mode(buffer)
    else
      @callback.call({ buffer: buffer })
    end
  end

  def on_buffer_lines_mode(buffer)
    @buffer += buffer
    lines = buffer.split("\n")
    if buffer[-1] == "\n"
      @buffer = ""
    else
      @buffer = lines.pop
    end
    lines.each do |line|
      @callback.call({ line: line })
    end
  end

  def on_done(status)
    if !@buffer.empty?
      @callback.call({ line: @buffer })
    end
    @callback.call({ status: status })
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