require 'uuid'

module Parsers
  class Default

    def initialize(data, collection)
      @collection = collection
      @data = data
    end

    # return the id of your document or a new id.
    # overwrite if you want to use an attribute from your source
    def generate_id(article)
      (UUID.new).generate
    end

    def fetch
      # fetch the data from wherever it is.
      # fetch can get the single item or many
    end

    def parse
      # modify your document into an article form.
      # parse should be called PER ITEM.
    end

    def process
      self.fetch
    end

    def save(article)
      id = self.generate_id(article)
      begin
      full_path = File.expand_path(
        File.join(
          File.dirname(__FILE__), "../../", 
          @config.collection[@collection].output, 
          self.generate_id(article) + ".json"
        ) 
      )
      rescue
        debugger
      end

      new_article = JSON.pretty_generate(article)
      file = File.open(full_path, 'w')
      file.write(new_article)
      file.close
    end
  end
end