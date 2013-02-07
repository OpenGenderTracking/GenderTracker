libdir = File.expand_path(File.join(File.dirname(__FILE__), '../src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'
require 'eventmachine'

@@config = YAML.load_file('config.yaml')

# get the file containing the globalvoices data
feed_path = File.expand_path(File.join(File.dirname(__FILE__),
  "../", @@config["collections"]["globalvoices"]["path"],
  @@config["collections"]["globalvoices"]["filename"]
  )
)
puts feed_path
feed = File.open(feed_path, 'r').read

# Load global voices articles
gb = Parsers::GlobalVoicesLocalFeed.new(feed, "globalvoices")
gb.process

# token up all global voices articles.
gvarticles = Dir.glob(File.join(File.dirname(__FILE__), "../data/globalvoices/*.json"))
count = gvarticles.size - 1

decomposer = Decomposer::Tokens.new
gvarticles.each do |f|
  article = Article.new(File.expand_path(File.join(File.dirname(__FILE__), "../", f)))
  decomposer.process(article)
end