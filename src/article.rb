require 'json'
require 'ruby-debug'

class Article

  def initialize(path)
    
    raise ArgumentError unless path.is_a? String

    @path = path
    file = File.open(@path, "r")
    body = file.read
    @article = JSON.parse(body)
    @article["decompositions"] = @article["decompositions"] || {}
    file.close
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

  def save
    new_article = JSON.pretty_generate(@article)
    file = File.open(@path, 'w')
    file.write(new_article)
    file.close
  end
end
