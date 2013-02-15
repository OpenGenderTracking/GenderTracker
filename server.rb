libdir = File.expand_path(File.join(File.dirname(__FILE__), '/src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'loader'

config = Confstruct::Configuration.new(
  YAML.load_file(
    File.expand_path(
      File.join(File.dirname(__FILE__), 'config.yaml')
    )
  )
)

# allocate a logger object, we will initialize it per job.
logger = nil

# create a new decomposer. Note we create it once and then just use its
# processing method.
decomposer = Decomposer::Tokens.new

# find all metrics available for processing, minus the default.
# note we initialize them once and then use their processing method.
metrics = Metrics.constants - ["Default"]
metrics = metrics.collect { |metric| 
  "Metrics::#{metric}".constantize.new(config)
}

# Create pub and sub connections to redis.
@pub = Redis.new(:host => config.redis.host, :port => config.redis.port)
@sub = Redis.new(:host => config.redis.host, :port => config.redis.port)

@sub.subscribe('process_article', 'new_job') do |on|
  on.message do |channel, message|

    case channel
      
    # Handle a new job request.
    when 'new_job'
      puts "new job requested"
      
      # Create a new job id and send it back to the client.
      # All processing requests should now come with this id.
      # This isn't a guarantee of anything at this point, but we may
      # start associating files with their job_ids (as well as additional)
      # information.
      job_request_id = message
      job_id = UUID.generate()
      @pub.publish job_request_id, job_id

      logger = Logger.new("logs/#{Time.now.strftime('%Y%m%d-%H%M')}" + 
        job_id + 
        ".log")
      logger.level = Logger.const_get(ENV['LOGLEVEL'] ? 
        ENV['LOGLEVEL'].upcase : 
        config.logging.level.upcase)

    # Handle a Process an article requestion
    # decompose it and run all available metrics.
    # TODO when we have more intricate decompositions
    # we will need to generalize that as well.
    when 'process_article'

      message = JSON.parse(message)
      job_id = message["job_id"]
      
      # did we get a file path to the article or the full body of it?
      article_path = message["path"]
      article_body = message["article"]
      
      begin
        logger.debug "#{job_id}: processing #{article_path}"
        if (article_path)
          article = Article.new({ :path => article_path })
        elsif (article_body)
          article = Article.new({ :article => article_body })
        end
          
        logger.debug "decomposing"
        decomposer.process(article)
        
        metrics.each do |metric|
          logger.debug "metric: #{metric.get_name}"
          metric.process(article)
        end

        article.save

      # Generic catch all for now. We probably need to do a better job error
      # handling this.
      rescue Exception => e

        logger.error "Error: #{e.message}"

      # always make sure we increment apporopriate counters, regardless of
      # whether our processing succeeded here.
      ensure
        @pub.incr job_id
        if (article_path)
          @pub.publish "process_article_done", { :path => article_path, :job_id => job_id }.to_json()
        elsif (article_body)
          @pub.publish "process_article_done", { :article => article_body, :job_id => job_id }.to_json()
        end
      end
    end
  end
end