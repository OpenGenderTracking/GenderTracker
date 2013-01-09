require 'jruby-opennlp'

module Decomposer

  class Tokens < Decomposer::Default

    def initialize(article)
      super(article)

      sentence_model_file_path = File.expand_path(File.join(
        File.dirname(__FILE__), 
        "../../", 
        "lib/opennlp-models/en-sent.bin"
      ))
      token_model_file_path = File.expand_path(File.join(
        File.dirname(__FILE__), 
        "../../", 
        "lib/opennlp-models/en-token.bin"
      ))

      sentence_model_file = java.io.FileInputStream.new(sentence_model_file_path)
      sentence_model      = OpenNLP::SentenceDetector::Model.new(sentence_model_file)
      @sentence_detector  = OpenNLP::SentenceDetector.new(sentence_model)

      token_model_file    = java.io.FileInputStream.new(token_model_file_path)
      token_model         = OpenNLP::Tokenizer::Model.new(token_model_file)
      @token_detector     = OpenNLP::Tokenizer.new(token_model)

    end

    def get_name
      "tokens"
    end

    def process

      if !@article.has_decomposition?("sentence") &&
         !@article.has_decomposition?("tokens")

        tokens = []
        
        # add sentences. Break out tokens as we iterate sentences... no point
        # in breaking up the whole thing twice.
        @article.add_decomposition "sentence" do
          sentences = @sentence_detector.detect(@article.body) rescue []

          # iterate over sentences and tokenize them. Ignore tokens that are
          # punctuation. Only check the last ones in a sentence for now.
          sentences.each do |sentence|
            sentence_tokens = @token_detector.tokenize(sentence)

            if /[A-ZZa-z0-9\-_].*/.match(sentence_tokens.last).nil?
              sentence_tokens.delete_at(sentence_tokens.length-1)
            end

            tokens = tokens + sentence_tokens
          end

          sentences
        end

        @article.add_decomposition "tokens" do
          tokens
        end

        @article.save
      else
        puts "decompositions exist. skipping."
      end

    end
  end
end