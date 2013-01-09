module Decomposer
  
  class Default

    def initialize(article) 
      @article = article
    end

    # overwrite with your decomposer's name.
    def get_name
      "default"
    end

    def process()
      # process your @article object here.
      # don't update entries that already exist, unless you need to.
    end

  end
  
end