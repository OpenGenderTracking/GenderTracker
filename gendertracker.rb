libdir = File.expand_path(File.join(File.dirname(__FILE__), '/src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'
require 'eventmachine'

@@config = YAML.load_file('config.yaml')

# d = Decomposer::Tokens.new("article1.json")

# d.process
# d.save

# gb = Parsers::GlobalVoicesLocalFeed.new
# gb.process

# process all global voices articles.

gvarticles = Dir.glob("data/globalvoices/*.json")
counter = gvarticles.length

def callback(counter)
  return proc {
    if counter == 0
      EM.stop
    end
  }
end

EM.run do
  puts "Starting"
  
  gvarticles.each do |f|

    counter = counter - 1
    EM.defer(proc {
      article = Article.new(File.join(File.dirname(__FILE__), f))
      article.decompose(Decomposer::Tokens)
    }, callback(counter))
  end
  
  puts "Done"
end
