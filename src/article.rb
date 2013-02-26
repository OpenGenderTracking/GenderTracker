require 'json'
require 'ruby-debug'

class Article

  def initialize(options)
    
    # Make sure we get an argument hash.
    if (!options.is_a? Hash)
      raise ArgumentError, 'A new article requires an object with a \'path\' or \'article\' property'
    end

    # Did we get a file path?
    if (options[:path])
      raise ArgumentError unless options[:path].is_a? String
      @path = options[:path]
      file = File.open(@path, "r")
      body = file.read
      @article = JSON.parse(body)
      file.close
      
    # Did we get the article directly?
    elsif (options[:article])

      # Parse the article if we need to.
      if (options[:article].is_a? String)
        @article = JSON.parse(options[:article])
      else
        @article = options[:article]
      end
    else
      raise ArgumentError, 'An object with a \'path\' property pointing to an article on the filesystem or \'article\' with the full article json must be provided.' 
    end

    @article["decompositions"] = @article["decompositions"] || {}
    @article["metrics"] = @article["metrics"] || {}
    
  end

  # make keys accessible
  def method_missing(m, *args)
    if (!@article.has_key?(m.to_s))
      super
    else
      if args.size > 0
        @article[m.to_s] = args[0]
      end
      @article[m.to_s]
    end
  end

  def has_decomposition?(name)
    !@article["decompositions"][name].nil?
  end

  def add_decomposition(name, &block)
    @article["decompositions"][name] = yield block
  end

  def get_decomposition(name) 
    @article["decompositions"][name]
  end

  def has_metric?(name)
    !@article["metrics"][name].nil?
  end

  def add_metric(name, &block)
    @article["metrics"][name] = yield block
  end

  def get_metric(name)
    @article["metrics"][name]
  end

  def to_json
    @article
  end

  def save
    new_article = JSON.pretty_generate(@article)
    file = File.open(@path, 'w')
    file.write(new_article)
    file.close
  end
end
