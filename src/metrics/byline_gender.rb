require 'csv'
require 'beauvoir'

module Metrics
  class BylineGender < Metrics::Default
    
    def initialize(config)
      super(config)
      @beauvoir = Beauvoir.new :threshold => 0.66, :lower_confidence_bound => 0.5 #all countries in the data set.
      # this is a relatively low threshold, so that the Byline Gender metric can be mostly unattended
      # and to mirror previous behavior before Beauvoir was developed
    end

    def get_name
      return "bylineGender"
    end


    def process(article)

      score = { :result => "", :counts => 0 }

      if (!article.byline.nil? && 
          article.byline.is_a?(String) && 
          article.byline != "")
        if (!article.byline.downcase.index("by ").nil?)
          first_name = article.byline.split(" ")[1].downcase
        else
          first_name = article.byline.split(" ")[0].downcase
        end
      elsif (article.byline.is_a? Array)
        first_name = article.byline[0].split(" ")[0].downcase
      else
        first_name = nil
      end

      # try to retrieve from cache
      if first_name
        score[:result] = @beauvoir.guess(first_name).to_s.capitalize
        score[:proportion] = score[:result] == "Male" ? @beauvoir.male_proportion(first_name) : @beauvoir.female_proportion(first_name)
        score[:estimated_value] = score[:result] == "Female" ? @beauvoir.estimated_female_value(first_name) : @beauvoir.estimated_male_value(first_name)
        score[:counts] = :deprecated
      else
        score[:result] = "Unknown"
        score[:proportion] = 0.0
        score[:estimated_value] = 0.0
        score[:counts] = :deprecated
      end

      article.add_metric "byline_gender" do
        score
      end

      score
    end

  end
end