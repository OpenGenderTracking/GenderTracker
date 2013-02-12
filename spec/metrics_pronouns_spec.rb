require "spec_helper"
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), "../src/article"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/metric.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/pronouns.rb"))


describe "Metrics::Pronouns" do

  before {
    @path = File.join(
      FIXTURES_DIR, "pronoun_test_article.json"
    )
    @article = Article.new(@path)
    @config = Confstruct::Configuration.new(
      YAML.load_file(
        File.expand_path(
          File.join(File.dirname(__FILE__), 'fixtures/config.yaml')
        )
      )
    )
  }

  context "initialisation" do

    it "should accept no parameters" do
      dt = Metrics::Pronouns.new(@config)
      dt.should be_a Metrics::Pronouns
      dt.get_name.should eq "pronouns"
    end

  end

  context "processing" do

    before {
      @dt = Metrics::Pronouns.new(@config)
    }

    it "should process" do
      @dt.process(@article)
      scores = @article.get_metric("pronouns")
      scores.should be_a Hash
      scores[:result].should eq "Neutral"
      scores[:counts][:male].should eq 4
      scores[:counts][:female].should eq 3
      scores[:counts][:neutral].should eq 1
    end

    after {
      article = JSON.parse(File.open(@path,'r').read)
      article.delete "decompositions"
      article.delete "metrics"
      f = File.open(@path, 'w')
      f.write(JSON.pretty_generate(article))
      f.close
    }
  end

end