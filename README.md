
node-fussy
==========

*A recommendation engine that care about user actions*

## Presentation

Fussy is a minimalist recommendation engine. It filters unwanted noise out of your news streams, but not too much: fussy will watch carefully and try to suggest things from time to time.
If you change your mind later, fussy will detect it, and adjust your profile a.k.a "filter bubble",
so that it is not a bubble anymore.

It's sounds like magic, but you can trust fussy. Because you know, he is very picky.

## How it works

It's based on a basic, naive-bayesian style algorithm:
Everytime you call profile.learn() this will increment or decrement some weights in the underlying network of tags.
That's why Fussy can fix profiles back: you can decrement the importance of keywords dynamically, hours, days or months after liking them.

## Installation

    $ npm install fussy

## Demo

```CoffeeScript
{Database, Profile} = require 'fussy'
database = new Database()
database.learn
  "Twitter to sue Google over twitter stream monetization": ["Technology", "Twitter", "Google", "Internet"]
  "A new library open in the east center in NYC": ["city","library","nyc"]
  "Rumors: Apple to launch a new tablet for emerging markets": ["Technology", "Apple", "Rumor"]
  "Microsoft reveal its new data center": ["Technology", "Rumor", "Microsoft"]
  "An energy-friendly data center for emerging countries": ["Technology", "World", "Energy"]
  "History of the countries: world music festival at the museum": ["Music", "City","Culture"]
  "Visiting a museum is good for health": ["Health", "Culture"]
  "Using home brew to install appplications on your Apple macbook": ["Computers", "Software", "Apple"]
  "How to brew your own beer": ["DIY", "Fooding", "Beverages", "Beer"]
  "Facebook to reveal a new open source library": ["Opensource","Technology","Facebook","Social Networks"]

profile = new Profile()

# news to ask the user for like/dislike
training = database.tag [
  "Visit the NYC museum using your tablet"
  "How to brew your own coffee"
  "Google to launch a new museum app"
  "Apple to sue Microsoft"
]

for txt, keywords of training

  # +1: like, 0: indifference, -1: dislike 
  choice = 1

  profile.learn txt, keywords, choice

# news to sort / rate
news = database.tag [
  "Open source conference give free beer to first 50 people in NY"
  "What is in people's head? an in-depth data analysis"
]
recommendations = profile.recommend news
console.log "--> #{Object.keys recommendations}"
```

## Documentation

### Automatic text tagging

Fussy has a built-in text tagger. 

#### Learning tags

Fussy need to learn tags from an existing dataset: 

```CoffeeScript
fussy = require 'fussy'
database = new fussy.Database()
database.learn
  "a short test text": ["keyword one", "keyword two"]
  "a second text": ["keyword one", "a new keyword"]
```

#### Tagging words

Then you can use it to tag text:

```CoffeeScript
tagged = database.tag [
  " a second test"
]
```

#### Saving memory

Fussy is a memory hog: since it keeps everything in RAM
(every single ngram he encounters) you will have to
clean weaks connections by calling database.prune(threshold)

connections with a weight <= threshold will be removed,
saving memory.

Typically you will want to do this:

```CoffeeScript
# we need to regularly prune the database or else memory will explode  
wait = (t) -> (f) -> setTimeout f, t
do prune = ->
  # database.size is the number of connections in the underlying network
  console.log "database size: #{database.size} entries"
  if database.size > 500000 # for instance
    console.log "pruning.."
    pruned = database.prune 1
    console.log "pruned #{pruned.keywords} keywords and #{pruned.ngrams} ngrams\n"
    setTimeout prune, 1000
  else
    console.log "no need to prune."
    setTimeout prune, 5000
```

### User recommendation


#### Creating a new Profile

```CoffeeScript
profile = new Profile()
```

#### Learning from a user preference

We need to save the full text together with the keywords.
The keywords can be hidden for the end user (he can only see the text if you want),
but you have to keep in mind that internally Fussy need them 
to compute its scores.

```CoffeeScript
profile.learn "there is snow at the train station", ["weather","city","snow","winter"], +1
profile.learn "it is too hot in the city hall",     ["weather","city","summer","hot"],  -1
```

#### Recommending a text

```CoffeeScript
tagged = database.tag [
  "a brand new movie synopsis with a cool scenario"
  "a new movie about teletubbies"
  "martians have been discovered on Mercury! but they are dead"
]
recommended = profile.recommend tagged
```


To be continued, see the example

## Examples

  See the /examples folder.

  There is an example crawler.coffee (careful: it needs a few dependencies, but they are on NPM) that show how one could use Twitter to get a "randomly" tagged dataset for free.

## Wishlist

 * unit tests

## Changelog

#### 0.0.1 (Wednesday, December 5, 2012)

 * Added database.size
 * Added database.prune(threshold)
 * Added database.toFile(fileName)
 * Removed the toy twitter database from core
 * Added an example crawler you could use to build a tag database

#### 0.0.0

 * Initial version, not very documented
