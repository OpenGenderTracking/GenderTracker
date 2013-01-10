require "spec_helper"
require 'json'

require File.expand_path(File.join(File.dirname(__FILE__), "../src/article"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/metric.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/metrics/pronouns.rb"))


describe "Decomposer::Tokens" do

  before {
    @article = Article.new(article_file_name)
  }

  context "initialisation" do
    
    it "should have a name" do
      Metrics::Pronouns.get_name.should eq "pronouns"
    end

    it "should accept no parameters" do
      dt = Metrics::Pronouns.new()
      dt.should be_a Metrics::Pronouns
    end

  end

  context "processing" do

    before {
      @dt = Metrics::Pronouns.new()
    }

    it "should process" do
      @dt.process(@article)
    end
  end

end