require 'async/io/stream'
require 'deckhand/process'

module ShellTask::Runnable
  extend ActiveSupport::Concern

  TASKS_DIR = if Rails.env.production?
                '/data/shell_tasks'
              else
                Rails.root.join('tmp/shell_tasks')
              end
  STANDARD_TIMEOUT = 3 * 60 # seconds

  def run(lines_mode: true, &callback)
    FileUtils.mkdir_p(shell_task_dir)
    File.write(script_path, script)
    FileUtils.chmod('+x', script_path)
    FileUtils.touch standard_output_path
    FileUtils.touch error_output_path

    @err = ''
    @out = ''
    @lines_mode = lines_mode
    @callback = callback

    @done_status = Concurrent::Event.new

    update! started_at: Time.now
    # TODO: instead of writing out and err to separate files only, also
    # write them to a combined file. This will allow us to tail the
    # combined file and show the output in the UI.
    @process = Deckhand::Process.spawn(
      %(bash -c "set -e; cd #{shell_task_dir}; #{script_path}"),
      out: standard_output_path,
      err: error_output_path
    ) do |message|
      if out = message[:out]
        on_out(out)
      elsif err = message[:err]
        on_err(err)
        # TODO: why are we checking the message channel here?
      elsif (status = message[:status]) && message[:channel] == :out
        update! finished_at: Time.now, exit_code: status
        on_done(status)
      elsif (status = message[:status]) && message[:channel] == :err
        update! finished_at: Time.now, exit_code: status
        on_done(status)
      else
        raise "Unknown message: #{message.inspect}"
      end
    end
  end

  def standard_output
    File.read(standard_output_path) if File.exist? standard_output_path
  end

  def error_output
    File.read(error_output_path) if File.exist? error_output_path
  end

  def on_err(err)
    if @lines_mode
      on_err_lines_mode(err)
    else
      @callback.call({ err: })
    end
  end

  def on_err_lines_mode(err)
    @err += err
    lines = err.split("\n")
    @err = if err[-1] == "\n"
             ''
           else
             lines.pop
           end
    lines.each do |line|
      @callback.call({ line: })
    end
  end

  def on_out(out)
    if @lines_mode
      on_out_lines_mode(out)
    else
      @callback.call({ out: })
    end
  end

  def on_out_lines_mode(out)
    @out += out
    lines = out.split("\n")
    @out = if out[-1] == "\n"
             ''
           else
             lines.pop
           end
    lines.each do |line|
      @callback.call({ line: })
    end
  end

  def on_done(status)
    lines = [@out, @err].reject(&:blank?)
    lines.each do |line|
      @callback.call({ line: })
    end
    @callback.call({ status: })

    @done_status.set
  end

  def wait
    @done_status.wait(STANDARD_TIMEOUT)
    @process.wait
  end

  def shell_task_dir
    File.join(TASKS_DIR, id.to_s)
  end

  def script_path
    File.join(shell_task_dir, 'script')
  end

  def standard_output_path
    File.join(shell_task_dir, 'out')
  end

  def error_output_path
    File.join(shell_task_dir, 'err')
  end
end
