require 'rspec'
require 'java'
require 'jruby-opennlp'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
@@config = YAML.load_file(File.join(File.dirname(__FILE__), "fixtures","config.yaml"))