module Metrics
  class Pronouns < Metrics::Default

    def initialize
      @pronouns = {
        :male => read_type("male"),
        :female => read_type("female"),
        :neutral => read_type("neutral")
      }
      @decompositions = [ Decomposer::Tokens ]
    end

    class << self
      def get_name
        return "pronouns"
      end
    end

    def process(article)
      super(article)
    end

    private
    def read_type(type)
      File.open(
        File.expand_path(
          File.join(
            File.dirname(__FILE__), 
            "../../lib/metrics/pronouns/#{type}-#{@@config["lang"]}.csv"
          )
        ), "r"
      ).read.split("\n")
    end 
  end
end