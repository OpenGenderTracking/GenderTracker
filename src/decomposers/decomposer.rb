module Decomposer
  
  class Default

    # overwrite with your decomposer's name.
    class << self
      def get_name
        "default"
      end
    end

    def initialize
    end

    def process(article)

      if !article.is_a?(String) && !article.is_a?(Article)
        raise ArgumentError
      end

      if article.is_a?(String)
        @article = Article.new(article)
      else
        @article = article
      end

      # process your @article object here.
      # don't update entries that already exist, unless you need to.
    end

  end
  
end