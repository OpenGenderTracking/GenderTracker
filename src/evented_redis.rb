require 'eventmachine'

class EventedRedis < EM::Connection
  def self.connect
    host = (ENV['REDIS_HOST'] || @@config["redis"]["host"] || 'localhost')
    port = (ENV['REDIS_PORT'] || @@config["redis"]["port"] || 6379).to_i
    EM.connect host, port, self
  end
 
  def post_init
    @blocks = {}
  end
  
  def subscribe(*channels, &blk)
    channels.each { |c| @blocks[c.to_s] = blk }
    call_command('subscribe', *channels)
  end
  
  def publish(channel, msg)
    call_command('publish', channel, msg)
  end
  
  def unsubscribe
    call_command('unsubscribe')
  end
  
  def receive_data(data)
    buffer = StringIO.new(data)
    begin
      parts = read_response(buffer)
      if parts.is_a?(Array)
        ret = @blocks[parts[1]].call(parts)
        close_connection if ret === false
      end
    end while !buffer.eof?
  end
  
  private
  def read_response(buffer)
    type = buffer.read(1)
    case type
    when ':'
      buffer.gets.to_i
    when '*'
      size = buffer.gets.to_i
      parts = size.times.map { read_object(buffer) }
    else
      raise "unsupported response type"
    end
  end
  
  def read_object(data)
    type = data.read(1)
    case type
    when ':' # integer
      data.gets.to_i
    when '$'
      size = data.gets
      str = data.read(size.to_i)
      data.read(2) # crlf
      str
    else
      raise "read for object of type #{type} not implemented"
    end
  end
  
  # only support multi-bulk
  def call_command(*args)
    command = "*#{args.size}\r\n"
    args.each { |a|
      command << "$#{a.to_s.size}\r\n"
      command << a.to_s
      command << "\r\n"
    }
    send_data command
  end
end