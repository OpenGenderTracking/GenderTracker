## Gender Tracker requirements

1. get jruby 1.6.3 by your favorite method of choice. I recommend rvm.
2. run `gem install bundler`
3. run `bundle install`
4. Intall redis

To run the server:

1. start redis with the config file in `db/` folder
2. run he server `bundle exec server.rb`

To process an article publish to the redis queue:

`public process_article path/to/article.json`

To get notification of an article being done subscribe to the

`process_article_done` message.

## Changelog

### 2013/02/07

* added running information to the readme.

### 2013/01/25

* Set `server.rb` to use redis as a messaging queue using EventMachine and deferring processing per article. 

### 2013/01/20

* Added pronoun metric + tests

### 2013/01/10

* Added spec tests. Run: `bundle exec rspec spec`
* Removed event machine since the java opennlp libs are not thread safe. oops.
* Made decomposers and metrics need only a single instantiation that will process articles on a need basis. Much faster for decomposition ~22s.

### 2013/01/09

* Parallelized article decomposition.
* Refactored Articles as standalone elements
* Did some performance experiments with EventMachine and decomposing the 1834 articles. We're looking at about 2m8s for tokens & sentences. It's not great but doable for now. 

### 2013/01/08

* basic decomposition using opennlp (sentences, tokens)
* added globalvoices local feed parser and fleshed out global data entries under data.