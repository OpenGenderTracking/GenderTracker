require 'csv'

module Metrics
  class BylineGender < Metrics::Default
    
    def initialize
      @names = {
        :male => read_names("male"),
        :female => read_names("female")
      }
      # cache names 
      @computed_names = {}
    end

    def get_name
      return "bylineGender"
    end


    def process(article)

      score = { :result => "", :counts => 0 }

      if (article.byline.is_a? String)
        first_name = article.byline.split(" ")[0].downcase
      elsif (article.byline.is_a? Array)
        first_name = article.byline[0].split(" ")[0].downcase
      else
        first_name = nil
      end

      # try to retrieve from cache
      if (!first_name.nil?)
        if (@computed_names[first_name]) 

          score = @computed_names[first_name]

        else

          male = @names[:male][:counts][first_name] || 0
          female = @names[:female][:counts][first_name] || 0
          total = male + female

          prob_male = 0
          prob_female = 0

          if (total > 0)
            
            # compute probabilities      
            prob_male = male / total.to_f if male
            prob_female = female / total.to_f if female

            score[:counts] = { :male => prob_male, :female => prob_female }
          end

          if (male > 0 && female > 0)  
            if (prob_female > 0.66)
              score[:result] = "Female"
            elsif (prob_male > 0.66)
              score[:result] = "Male"
            else
              score[:result] = "Unknown"
            end
          elsif (male > 0)
            score[:result] = "Male"
          elsif (female > 0)
            score[:result] = "Female"
          else
            if (@names[:male][:definite].index(first_name))
              score[:result] = "Male"
              score[:counts] = { :male => 1.0, :female => 0.0 }
            elsif (@names[:female][:definite].index(first_name))
              score[:result] = "Female"
              score[:counts] = { :male => 0.0, :female => 1.0 }
            else
              score[:result] = "Unknown"
              score[:counts] = { :male => 0.0, :female => 0.0 }
            end
          end
          # cache for future use
          @computed_names[first_name] = score
        end
      else
        score[:result] = "Unknown"
        score[:counts] = { :male => 0.0, :female => 0.0 }
      end

      article.add_metric "byline_gender" do
        score
      end


      score
    end

    private

    def read_names(gender)
      lang = @@config["lang"] || "EN"
      country = @@config["country"] || "US"

      count_file_name = gender + "_names_" + lang + "_" + country + ".csv"
      definite_file_name = gender + "_auxilliary.csv"

      count_data = {}
      definite_data = []

      CSV.open(
        File.expand_path(
          File.join(
            File.dirname(__FILE__), 
            "../../lib/metrics/names/#{count_file_name}"
          )
        ), 'r').to_a.each do |namePair|
        count_data[namePair[0].downcase] = namePair[1].to_f
      end

      definite_data = CSV.open(
        File.expand_path(
          File.join(
            File.dirname(__FILE__), 
            "../../lib/metrics/names/#{definite_file_name}"
          )
        ),'r').to_a.flatten.compact.collect{|r| r.downcase } rescue []

      return {
        :counts => count_data,
        :definite => definite_data
      }

    end
  end
end