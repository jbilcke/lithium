node-fussy
==========

*The recommendation engine that care about your actions*

## Presentation

Fussy is a minimalist recommendation engine. 
It filters unwanted noise out of your news streams—but not too much! 
Fussy will watch carefully, and suggest things from time to time.
If you change your mind later, Fussy will notice, and adjust your profile. 
That way, Fussy keeps up-to-date with the ever-changing you.

It sounds like magic! But you can trust Fussy. 

Because, you know, he’s very picky.


## How it works

It’s based on a basic, naïve-bayesian style algorithm.
Everytime you call `profile.learn()`, Fussy increments or decrements weights in the underlying network of tags.
That’s how Fussy unlearns things if you change your mind. 
You can always decrement the importance of keywords dynamically. 
Even hours, days, or months after liking them.


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
  "What is in people’s head? an in-depth data analysis"
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

Fussy is a memory hog. Since it keeps everything in RAM (every single 
`ngram` it encounters), you’ll have to clean weak connections.

Fortunately, it’s really simple: just call `database.prune(threshold)`.
Connections whose `weight <= threshold` are removed, reclaiming memory.

Typically you’ll want to do this:

```CoffeeScript
# regularly prune the database (or else memory will explode)
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

#### Learning User Preference

Be sure to save the full text along with the keywords.
You can have Fussy hide the keywords from the end user, if you want;
but Fussy needs them internally to compute scores.

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

(To be continued…)


## Examples

  (See the `/examples` folder.)

  The example `crawler.coffee` that show how one could use Twitter to get a "randomly" tagged dataset for free. (Notice: this example has a few dependencies. But, they’re all on NPM.)

## Wishlist

 * unit tests

## Changelog

#### 0.0.1 (Wednesday, December 5, 2012)

 * Added `database.size`
 * Added `database.prune(threshold)`
 * Added `database.toFile(fileName)`
 * Removed the toy Twitter database from core
 * Added an example crawler you could use to build a tag database

#### 0.0.0

 * Initial version, not very documented
