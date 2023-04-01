class Deckhand::Process
  attr_reader :pid

  # spawn a process asynchronously, retuninrg a Deckhand::Process that
  # can be used to await the process and read its output. 
  def self.spawn(*args, out: nil, &done)
    input_read, @input_write = IO.pipe.new
    @out = out
    @pid = Process.spawn(*args, in: input_read, out: out, err: out)
    Thread.new do
      @status = Process.wait(@pid)
    ensure
      begin
        [
          input_read, @input_write, @tail_read
        ].compact.each(&:close)
      ensure
        done.call(@status) if done
      end
    end
  end

  def tail(&callback)
    @tail_read, output_write = IO.pipe.new
    @tail_pid = Process.spawn("tail", "-f", @out, out: output_write)

    Thread.new do
      tail_lines.each do |line|
        callback[line]
      end
    ensure
      Rails.logger.debug "Tail thread on #{@out} finished"
      begin
        [
          @tail_read, output_write
        ].each(&:close)
      ensure
        @tail_pid.kill if @tail_pid.alive?
      end
    end
  end

  private

  def self.tail_lines
    buffer = ""
    while @pid.alive? && @tail_pid.alive? && !@tail_read.closed?
      begin
        buffer << @tail_read.read_nonblock(1024*16)
        lines = buffer.lines
        if !buffer.include?("\n") || buffer[-1] != "\n"
          buffer = lines.pop
        end
        lines.each do |line|
          yield line
        end
      rescue IO::WaitReadable
        IO.select([@tail_read])
        retry
      rescue IO::EOFError
        break
      end
    end
    yield buffer
  end
end