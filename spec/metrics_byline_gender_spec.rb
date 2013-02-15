require "spec_helper"
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), "../src/article"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/metric.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/byline_gender.rb"))

describe "Metrics::BylineGender" do

  before {
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
      mn = Metrics::BylineGender.new(@config)
      mn.should be_a Metrics::BylineGender
      mn.get_name.should eq "bylineGender"
    end
  end

  context "process" do

    before {
      @mn = Metrics::BylineGender.new(@config)
      @female_article = Article.new({ :path => File.join(
      FIXTURES_DIR, "byline_female_test_fixture.json"
      )})
      @male_article = Article.new({ :path => File.join(
        FIXTURES_DIR, "byline_male_test_fixture.json"
      )})
      @unknown_article = Article.new({ :path => File.join(
        FIXTURES_DIR, "byline_unknown_test_fixture.json"
      )})
    }

    it "should detect a female author" do
      scores = @mn.process(@female_article)
      scores[:result].should eq "Female"
      scores[:counts][:male].round.should eq 0
      scores[:counts][:female].round.should eq 1
    end

    it "should detect a male author" do
      scores = @mn.process(@male_article)
      scores[:result].should eq "Male"
      scores[:counts][:male].round.should eq 1
      scores[:counts][:female].round.should eq 0
    end

    it "should be unable to detect author" do
      scores = @mn.process(@unknown_article)
      scores[:result].should eq "Unknown"
      scores[:counts][:male].should be_< 0.66
      scores[:counts][:female].should be_< 0.66
    end

    it "should detect a female author from aux list" do
      @female_article.byline("Anemona")
      scores = @mn.process(@female_article)
      scores[:result].should eq "Female"
      scores[:counts][:male].should eq 0.0
      scores[:counts][:female].should eq 1.0
    end

    it "should detect a male author from aux list" do
      @male_article.byline("Kelefa")
      scores = @mn.process(@male_article)
      scores[:result].should eq "Male"
      scores[:counts][:male].should eq 1.0
      scores[:counts][:female].should eq 0.0
    end

    it "should fail to detect a name that doesn't exist in any list" do
      @male_article.byline("jn323kjnbjt whwet")
      scores = @mn.process(@male_article)
      scores[:result].should eq "Unknown"
      scores[:counts][:male].should eq 0.0
      scores[:counts][:female].should eq 0.0
    end

  end
end