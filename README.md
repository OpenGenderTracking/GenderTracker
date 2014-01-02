# Gender Tracker

GenderTracker is a service that decomposes articles and computes various gender-related metrics based on the content. It accepts articles to process via a redis queue (as file paths) and then outputs them back with the metrics computed. 

## article json format

```json
{
  "url": "<Article url>",
  "id": "<Unique ID>",
  "body": "<Body of text>",
  "original_body": "<Body of text as originally captured>",
  "title": "<Article title>",
  "byline": "<Author name>",
  "pub_date": "<Publication Date>"
}
```

You can add additional attributes, if you'd like, but these are core attributes required by the decomposer and metrics.

## Requirements

1. get jruby 1.7.6 by your favorite method of choice. rvm and rbenv are both good choices.
2. run `gem install bundler`
3. run `bundle install`
4. Install redis

## Running the service

1. start redis 
  - with the config file in `db/` folder
  - or with redis's default
2. run the server `bundle exec ruby server.rb`

## Requesting an article be published

GenderTracker has the notion of jobs. Articles can all belong to a single job, so first one must request a new job id from the server. To do that publish the following to the queue:

`publish new_job, <some_unique_id>`

The service will then send a message back using the unique id above as a channel name with the new id assigned to the job.

`subscribe <some_unique_id>, <your callback>`

Once a job id has been obtained.
To process an article, publish to the redis queue a request that either passes the file path to the article like so:

`public process_article { job_id: <job_id>, path: path/to/article.json }`

Or the entire article body like so:

`public process_article { job_id: <job_id>, article: { ... } }`

To get notification of an article being done subscribe to the `process_article_done` channel. It will return the same payload you sent (`path`|`article`, and `job_id`.)

## Licensing

The project is dual licensed under the GPLv3 license as well as the MIT license. Pick your favorite.

## Changelog

### 2013/11/12

Switch to updated version of JRuby.
Use the Beauvoir gem for byline gender coding.

### 2013/03/04

Added licensing information. Dual licensed, GPLv3 and MIT.

### 2013/02/15

Modified the server to accept not only the filepath of an article, but the entire body of the article. This is more convenient for when we start thinking about distributing things across machines. Since Redis can handle string values up to 512MB this is a slight limitation, but we probably shouldn't be processing files even half that size.

### 2013/02/12

Major changes in GenderTracker! GenderTracker now exclusively accepts a standard json format for articles. This allows us to build clients fairly rapidly that are able to convert their data into the proper format, and then get it evaluated. This way, we can maintain a single unique system that doesn't care about the source of the content.

All the work that was related to global voices, has been moved into its own repo here: github.com/opengendertracking/globalvoices


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