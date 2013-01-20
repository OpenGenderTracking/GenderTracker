require "spec_helper"
require 'json'
require File.expand_path(File.join(File.dirname(__FILE__), "../src/article"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/decomposers/decomposer.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "../src/decomposers/tokens.rb"))

describe "Decomposer::Tokens" do

  before {
    @article = Article.new(article_file_name)
  }

  context "initialisation" do
    
    it "should have a name const" do
      Decomposer::Tokens.get_name.should eq "tokens"
    end

    it "should accept no parameters" do
      dt = Decomposer::Tokens.new()
      dt.should be_a Decomposer::Tokens
    end

  end

  context "decomposition" do
    before {
      @dt = Decomposer::Tokens.new
    }
    
    it "should decompose the article" do
      @dt.process(@article).should be_a Article
    end

    it "should have 'tokens' decomposition" do
      @dt.process(@article)
      @article.has_decomposition?("tokens").should eq true
      @article.get_decomposition("tokens").should eq ["test", "sentence", "test", "sentence", "two", "another", "sentence", "test"]
    end

    it "should have 'sentences' decomposition" do
      @dt.process(@article)
      @article.has_decomposition?("sentences").should eq true
      @article.get_decomposition("sentences").should eq [
          "Test Sentence.",
          "Test sentence two.",
          "Another sentence test."
        ]
    end

    after {
      article = JSON.parse(File.open(article_file_name,'r').read)
      article.delete "decompositions"
      f = File.open(article_file_name, 'w')
      f.write(JSON.pretty_generate(article))
      f.close
    }
  end
end

def article_file_name
  File.join(FIXTURES_DIR, "article.json")
end