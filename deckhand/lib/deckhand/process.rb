# Purpose: A class for managing processes spawned by Deckhand
class Deckhand::Process
  attr_reader :pid

  # spawn a process asynchronously, retuninrg a Deckhand::Process that
  # can be used to await the process and read its output. 
  # args: the arguments to pass to Process.spawn
  # out: a path to a file to write the process's output to
  # done: a callback to call when the process is finished
  def self.spawn(*args, out: nil, &done)
    p = Deckhand::Process.new()
    p.spawn(*args, out: out, &done)
  end

  def spawn(*args, out: nil, &callback)
    Rails.logger.info "Spawning process: #{args.inspect} to #{out}"
    input_read, @input_write = IO.pipe
    output_read, output_write = IO.pipe
    @out = out
    @tail_thread = tail(output_read, out, &callback)
    @run_thread = Thread.new do
      @pid = ::Process.spawn(*args, in: input_read, out: output_write)
      @status = ::Process.waitpid(@pid)
    rescue Errno::ECHILD
      puts "Warning: ECHILD"
      @status = 1 # nothing was spawned I think?
    ensure
      begin
        [
          input_read, @input_write
        ].compact.each(&:close)
      end
    end
    self
  end

  def alive?
    !@status
  rescue => e
    false
  end

  def wait
    @run_thread.join
    @tail_thread.join if @tail_thread
    @status
  end

  private

  def tail(out_read, out_path, &callback)
    Thread.new do
      file = File.open(out_path, "w")
      stopping = false
      loop do
        begin
          buffer = out_read.read_nonblock(1024*16)
          file.write(buffer)
          callback.call({ buffer: buffer })
        rescue IO::WaitReadable
          break if stopping
          IO.select([out_read], [], [], 0.2)
          stopping = !alive? # we read one more time after the process is done
        rescue => e
          Rails.logger.error "Stopping tail due to error: #{e.message}"
          break
        end
      end
    ensure
      file.close
      callback.call(
        {
          status: @status
        }
      )
    end
  end
end