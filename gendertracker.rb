libdir = File.expand_path(File.join(File.dirname(__FILE__), '/src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'

@@config = YAML.load_file('config.yaml')

# d = Decomposer::Tokens.new("article1.json")

# d.process
# d.save

gb = Parsers::GlobalVoicesLocalFeed.new
gb.process