require 'feedzirra'
require 'sanitize'

module Parsers
  class GlobalVoicesLocalFeed < Parsers::Default

    def fetch
      feed = Feedzirra::Feed.parse(@data)

      feed.entries.each do |entry|
        self.parse(entry)
      end
    end

    def generate_id(article)
      
      url_id = nil

      if (article["url"])
        url_id = article["url"].split("p=")[1]
      end

      if (url_id.nil?)
        return super(article)
      else
        return url_id
      end
    end

    def parse(entry)
      
      article = {}

      article["url"] = entry.entry_id
      article["id"] = self.generate_id(article)
      
      # remove html content tags.
      article["body"] = Sanitize.clean(entry.content)
      article["original_body"] = entry.content
      article["title"] = entry.title
      article["byline"] = entry.author
      article["pub_date"] = entry.published

      self.save(article)
      
    end

  end
end