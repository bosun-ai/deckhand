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
    p
  end

  def spawn(*args, out: nil, &done)
    input_read, @input_write = IO.pipe
    @done_read, @done_write = IO.pipe
    @out = out
    @run_thread = Thread.new do
      @pid = ::Process.spawn(*args, in: input_read, out: out, err: out)
      @status = ::Process.waitpid(@pid)
    rescue Errno::ECHILD
      puts "Warning: ECHILD"
      @status = 1 # nothing was spawned I think?
    ensure
      begin
        [
          input_read, @input_write
        ].compact.each(&:close)
      ensure
        @done_write.write("done")
        @done_write.close
        done.call(@status) if done
      end
    end
  end

  # tail the output of the process, calling the callback with each line
  # the callback will be called on a separate thread
  def tail(&callback)
    @tail_read, output_write = IO.pipe

    @tail_thread = Thread.new do
      puts "waiting for file to exist"
      while !File.exist?(@out)
        sleep 0.1
      end
      puts "started tail"
      @tail_pid = ::Process.spawn("tail", "-n +0", "-f", @out, out: output_write)
      tail_lines do |line|
        callback[line]
      end
      puts "finished tail"
    ensure
      puts "Tail thread on #{@out} finished"
      Rails.logger.debug "Tail thread on #{@out} finished"
      begin
        [
          @tail_read, output_write
        ].each(&:close)
      ensure
        ::Process.kill("SIGKILL", @tail_pid) if tail_alive?
      end
    end
  end

  def alive?
    @pid && @done_read.read_nonblock(1)
  rescue => e
    puts "done_read failed with: #{e.inspect}"
    false
  end

  def tail_alive?
    @tail_pid && !!::Process.waitpid(@tail_pid, ::Process::WNOHANG)
  rescue Errno::ECHILD
    false
  end

  def wait
    @run_thread.join
    @tail_thread.join if @tail_thread
    @status
  end


  def tail_lines
    puts "starting tail_lines"
    buffer = ""
    stopping = false
    # TODO: maybe only check tail_read closed?
    while !@tail_read.closed? && !stopping
      begin
        next_result = @tail_read.read_nonblock(1024*16)
        puts "got #{next_result.inspect} from read_nonblock"
        buffer += next_result
        lines = buffer.lines
        if !buffer.include?("\n") || buffer[-1] != "\n"
          buffer = lines.pop || ""
        else
          buffer.clear
        end
        lines.each do |line|
          line.chomp!
          yield line
          puts "yielded #{line.inspect}"
        end
      rescue IO::WaitReadable
        begin
          ready, _, _ = IO.select([@tail_read, @done_read])
          if ready.include? @done_read
            puts "process has stopped"
            stopping = true
            # wait for last buffer to be written into tail_read
            more_ready, _, _ = IO.select([@tail_read], [], [], 5) if !ready.include? @tail_read
            ready += more_ready if more_ready
          end
          if ready.include? @tail_read
            retry
          end
        rescue => e
          puts "In select got error: #{e}, buffer is: #{buffer.inspect}}"
          yield buffer unless buffer.empty?
          @tail_read.close
          return
        end
      rescue EOFError, Errno::EBADF, IOError => e
        puts "Got error: #{e}, buffer is: #{buffer.inspect}}"
        yield buffer unless buffer.empty?
        @tail_read.close
        return
      end
    end
    yield buffer unless buffer.empty?
  end
end