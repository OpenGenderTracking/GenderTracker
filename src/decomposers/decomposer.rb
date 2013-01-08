module Decomposer
  
  class Default

    def initialize(article_path) 
      @article = Hash.new
      @full_path = File.expand_path(
        File.join(
          File.dirname(__FILE__), "../../", @@config["articles"]["path"], article_path 
        ) 
      )
      file = File.open(@full_path, "r")
      @article = JSON.parse(file.read)

      @article["decompositions"] = @article["decompositions"] || {}
      file.close
    end

    def process()
      # process your @article object here.
      # don't update entries that already exist, unless you need to.
    end

    def has_decomposition?(name)
      !@article["decompositions"][name].nil?
    end

    def add_decomposition(name, &block)
      @article["decompositions"][name] = yield block
    end

    def save
      new_article = JSON.pretty_generate(@article)
      file = File.open(@full_path, 'w')
      file.write(new_article)
      file.close
    end

  end
  
end