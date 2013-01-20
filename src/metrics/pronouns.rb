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

      # count how many tokens fall within the pronoun dictionary
      counts = { :male => 0, :female => 0, :neutral => 0 }
      article.get_decomposition("tokens").each do |token|
        m = @pronouns[:male].index(token)
        if (!m.nil?)
          counts[:male] += 1
        else
          f = @pronouns[:female].index(token)
          if (!f.nil?)
            counts[:female] += 1
          else
            n = @pronouns[:neutral].index(token)
            if (!n.nil?)
              counts[:neutral] += 1
            end
          end
        end
      end

      score = { :result => "", :counts => counts }
      if ((counts[:male] + counts[:female]) == 0)
        score[:result] = "Unknown"
      elsif (counts[:neutral] > (counts[:male] + counts[:female]))
        score[:result] = "Neutral"
      else
        male_percent = counts[:male].to_f / (counts[:male] + counts[:female])
        if (male_percent > 0.66)
          score[:result] = "Male"
        elsif (male_percent > 0.33)
          score[:result] = "Neutral"
        else
          score[:result] = "Female"
        end
      end

      article.add_metric "pronouns" do
        score
      end

      article.save
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