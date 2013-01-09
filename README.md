## Gender Tracker requirements

1. get jruby 1.6.3 by your favorite method of choice. I recommend rvm.
2. run `gem install bundler`
3. run `bundle install`


## Changelog

### 2013/01/09

* Parallelized article decomposition.
* Refactored Articles as standalone elements
* Did some performance experiments with EventMachine and decomposing the 1834 articles. We're looking at about 2m8s for tokens & sentences. It's not great but doable for now. 

### 2013/01/08

* basic decomposition using opennlp (sentences, tokens)
* added globalvoices local feed parser and fleshed out global data entries under data.