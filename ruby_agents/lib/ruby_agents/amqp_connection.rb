class AmqpConnection
  include Singleton
  attr_reader :connection

  def initialize
    @connection = Bunny.new(ENV['RABBITMQ_URL'])
    @connection.start
  end

  def channel
    @channel ||= ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i, timeout: 5) { create_channel }
  end

  def publish_on_queue(queue_name, *msg)
    channel.with do |ch|
      ch.queue(queue_name, durable: true).publish(msg.to_json)
    end
  end
end
