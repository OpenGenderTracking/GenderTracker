require 'feedzirra'
require 'sanitize'

module Parsers
  class GlobalVoicesLocalFeed < Parsers::Default

    def initialize
      @collection ="globalvoices"
    end
    def fetch
      feed_path = File.expand_path(File.join(File.dirname(__FILE__),
        "../../", @@config["collections"][@collection]["path"],
        @@config["collections"][@collection]["filename"]
        )
      )
      feed = File.open(feed_path, 'r').read
      feed = Feedzirra::Feed.parse(feed)

      feed.entries.each do |entry|
        self.parse(entry)
      end
    end

    def generate_id(article)
      article["url"].split("p=")[1]
    end

    def parse(entry)
      
      article = {}
      puts "processing #{entry.title}"

      # TODO: need to strip this guy of stuff...
      article["url"] = entry.entry_id
      article["id"] = self.generate_id(article)
      article["body"] = Sanitize.clean(entry.content)
      article["original_body"] = entry.content
      article["title"] = entry.title
      article["byline"] = entry.author
      article["pub_date"] = entry.published

      self.save(article)
      
    end

  end
end