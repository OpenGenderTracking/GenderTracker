libdir = File.expand_path(File.join(File.dirname(__FILE__), '../src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'
require 'eventmachine'

@@config = YAML.load_file('config.yaml')

# load up all articles
gvarticles = Dir.glob(File.join(File.dirname(__FILE__), "../data/globalvoices7/articles/*.json"))
count = gvarticles.size - 1


output = File.open("global_voices_all.csv", "wb")
output.write("id,pubdate,gender_by_pronoun,gender_by_byline\n")

cache = {}

gvarticles.each do |a|
  file = File.open(a, "r")
  body = file.read
  article = JSON.parse(body)

  if (article["byline"])

    line = article["id"] + "," + 
           article["pub_date"] + "," +
           article["metrics"]["pronouns"]["result"] + "," +
           article["metrics"]["byline_gender"]["result"] + 
           "\n"
    
    if (!cache[line]) 
      output.write(line)
      cache[line] = 1
    end
  end
end

output.flush
output.close
