libdir = File.expand_path(File.join(File.dirname(__FILE__), '/src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'
require 'eventmachine'
require 'redis'

@@config = YAML.load_file('config.yaml')

decomposer = Decomposer::Tokens.new

# find all metrics available for processing, minus the default.
metrics = Metrics.constants - ["Default"]
metrics = metrics.collect { |metric| 
  "Metrics::#{metric}".constantize.new
}

EM.run do
  @pub = EventedRedis.connect
  @sub = EventedRedis.connect

  @sub.subscribe "process_article" do |type, channel, message|
    
    if (type === "message")
      puts "processing #{message}"
      article = Article.new(message)
      puts "decomposing"
      decomposer.process(article)

      puts "computing metrics"
      metrics.each do |metric|
        puts "metric: #{metric.get_name}"
        metric.process(article)
      end

      article.save
      @pub.publish "done", message
    end
  end

  @sub.subscribe "done" do |type, channel, message|
    if (type === "message")
      puts "done with #{message}"
    end
  end
end