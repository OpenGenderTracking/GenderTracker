libdir = File.expand_path(File.join(File.dirname(__FILE__), '../src/'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'json'
require 'loader'
require 'ruby-debug'
require 'eventmachine'

@@config = YAML.load_file('config.yaml')

# load up all articles
gvarticles = Dir.glob(File.join(File.dirname(__FILE__), "../data/globalvoices/*.json"))
count = gvarticles.size - 1

EM.run do
  pronouner = Metrics::Pronouns.new
  byliner   = Metrics::BylineGender.new

  def process_article(f, pronouner, byliner)
    return proc {
      article = Article.new(File.expand_path(File.join(File.dirname(__FILE__), "../", f)))
      pronouner.process(article)
      byliner.process(article)
      article.save
    }
  end

  def callback(count)
    return proc {
      if (count === 0)
        EM.stop
      end
    }
  end

  gvarticles.each do |f|

    EM.defer(
      process_article(f, pronouner, byliner),
      callback(count -= 1)
    )

  end
end