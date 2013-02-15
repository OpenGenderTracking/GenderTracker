require "spec_helper"
require File.expand_path(File.join(File.dirname(__FILE__), "../src/article"))

describe "Article" do
  context "initialisation" do
    
    it "should fail when not providing an object" do
      lambda { Article.new(article_file_name) }.should raise_error(ArgumentError)
    end

    it "should accept a string filename parameter" do
      a = Article.new({ :path => article_file_name })
      a.should be_a Article
    end

    it "should accept the body of an article unparsed" do
      f = File.open(article_file_name, 'r').read
      a = Article.new({ :article => f })
      a.should be_a Article
    end

    it "should accept the body of an article" do
      f = JSON.parse(File.open(article_file_name, 'r').read)
      a = Article.new({ :article => f })
      a.should be_a Article
    end

    it "should raise an argument error otherwise" do
      lambda { Article.new(nil) }.should raise_error(ArgumentError)
    end
  end

  context "accessing properties" do

    before {
      @article = Article.new({ :path => article_file_name })
    }

    it "should have a title" do
      @article.title.should eq "Greece: Uproar over plan to build border fence and expel migrants"
    end

    it "should have a url" do
      @article.url.should eq "http://globalvoicesonline.org/?p=160165"
    end

    it "should have a pub-date" do
      @article.pub_date.should eq "2011-01-10T00:29:03Z"
    end

    it "should have a byline" do
      @article.byline.should eq "Asteris Masouras"
    end
  end

  context "decompositions" do
    before {
      @article = Article.new({ :path => article_file_name })
    }

    it "should have no decompositions" do
      @article.has_decomposition?("token").should eq false
    end

    it "should add decomposition" do
      @article.add_decomposition "test" do
        ["hi"]
      end

      @article.has_decomposition?("test").should eq true
      @article.get_decomposition("test").should eq ["hi"]
    end
  end
end

def article_file_name
  File.join(FIXTURES_DIR, "article.json")
end