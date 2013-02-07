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

# EM.run do
  
  pronouner = Metrics::Pronouns.new
  byliner   = Metrics::BylineGender.new


  def callback(count)
    return proc {
      if (count === 0)
        EM.stop
      end
    }
  end

  gvarticles.each do |f|

    puts f
    puts count if count % 1000 === 0
    article = Article.new(File.expand_path(File.join(File.dirname(__FILE__), "../", f)))
    
    pronouner.process(article)
    byliner.process(article)
    
    article.save

#   callback(count -= 1)
  end
# end