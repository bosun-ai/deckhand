$stdout.sync = true
# Purpose: A class for managing processes spawned by Deckhand
module Deckhand
  class Process
    attr_reader :pid

    # spawn a process asynchronously, retuninrg a Deckhand::Process that
    # can be used to await the process and read its output.
    # args: the arguments to pass to Process.spawn
    # out: a path to a file to write the process's output to
    # done: a callback to call when the process is finished
    def self.spawn(*args, out: nil, err: nil, &done)
      p = Deckhand::Process.new
      p.spawn(*args, out:, err:, &done)
    end

    def spawn(*args, out: nil, err: nil, &callback)
      Rails.logger.info "Spawning process: #{args.inspect} to #{out}"
      input_read, @input_write = IO.pipe
      output_read, output_write = IO.pipe
      err_read, err_write = IO.pipe
      @out = out
      @err = err
      @output_tail_thread = tail(output_read, out, :out, &callback)
      @err_tail_thread = tail(err_read, err, :err, &callback)
      @run_thread = Thread.new do
        @pid = ::Process.spawn(*args, in: input_read, out: output_write, err: err_write)
        ::Process.wait(@pid)
        @status = ::Process.last_status&.exitstatus
      rescue Errno::ECHILD
        Rails.logger.debug 'Warning: ECHILD'
      ensure
        [
          input_read, @input_write
        ].compact.each(&:close)
      end
      self
    end

    def alive?
      !@status
    rescue StandardError
      false
    end

    def wait
      @run_thread.join
      @output_tail_thread&.join
      @err_tail_thread&.join
      @status
    end

    private

    def tail(out_read, out_path, channel = :out, &callback)
      Thread.new do
        file = File.open(out_path, 'w') if out_path
        stopping = false
        loop do
          buffer = out_read.read_nonblock(1024 * 16)
          file&.write(buffer)
          Rails.application.executor.wrap do
            callback.call(Hash[channel, buffer])
          end
        rescue IO::WaitReadable
          break if stopping

          IO.select([out_read], [], [], 0.2)
          stopping = !alive? # we read one more time after the process is done
        rescue StandardError => e
          Rails.logger.error "Stopping #{channel} tail due to error: #{e.message}"
          break
        end
      rescue StandardError => e
        Rails.logger.debug "Stopping #{channel} tail due to error: #{e.message}"
      ensure
        @run_thread.join
        file&.close
        out_read.close
        Rails.application.executor.wrap do
          callback.call(
            {
              status: @status || -1,
              channel:
            }
          )
        end
      end
    end
  end
end
