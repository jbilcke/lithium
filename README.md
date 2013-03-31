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


## Detailed algorithm
  
### Phase 1 - learning
  
  In the learning phase, we take a list of tagged sentences, in the form:
  
    { 
      "sentence": [ "tag" ], 
      "another sentence": [ "other", "tag" ] 
    }
  
  For instance:
  
    
    { 
      "beer brew": [ "beverage", "stuff" ], 
      "home brew": [ "mac", "stuff" ] 
    }
  
  
  The algorithm will read each sentence, split it into n-grams,
  then for each ngram we will "bind" it with a tag from the list.
  
  for instance here, we will get, in the end:
  
     "beer":
         "stuff": 1
         "beverage": 1
         
     "brew":
         "stuff": 2
         "mac": 1
         "beverage": 1
             
     "home":
         "mac": 1
         "stuff": 1
    
    "beer brew":
        "stuff": 1
        "beverage": 1
        
    "home brew":
        "stuff": 1
        "mac": 1
        
  N-grams allow the system to catch complex associations (the immediate context), such as word that have double meaning depending on the words before and after them.
 
  
### Phase 2 - Tagging

   Using the data structure previously generated,
   it is then easy to tag a new, never seen before sentence, using the reverse process:
   
   we split the new sentence into n-grams, then we lookup these ngrams in the database, to extract all the related tags,
   and compute a score for each of them. 
   
   In node-fussy, this is done in-memory, but this could be done in any key-value store.
   
### Phase 3 - Recording user preferences
  

  Each user has a "profile", which is just a map of tags with attached preference scores.

  Whenever we have a new tagged sentence, we can submit the text to the user (it doesn't matter if he knows the tags or not. they can be hidden),
  and then  we can expect (it's asynchronous; he may reply or not) an answer like:
   
   * +1 (like/more)
   * 0 (skip/unknow)
   * -1 (dislike/less)
   
This is the feeling of the user toward the text. 
Fussy uses a ternary system, but you could imagine something more accurat, with sliders/range,
allowing in-between values like "a bit more" (+0.5) etc..

Now, this single score will then be used to update the score of every other tags in the user profile,
just by adding the score to them.
   
This is why Fussy is dynamic: 
Let's say you fancy hipster things, and +1 articles containing the h-word.
If later you keep "-1" articles containing the word "hipster",
but continue to +1 all others, after a moment the word hipster will have a low score,
and when the recommendation phase sort and filter out sentences, hipster-related content
will have a low score.
(since score are used for relative and not absolute comparison, the score does not have to be near zero or negative to be effective)
   

### Phase 4 - Recommendation

  TO BE CONTINUED LATER
  
  but basically, we do the previous steps in the reverse order, to compute a "user-related" score for a sentence,
  which can then be used for cool things, like filtering tweets, articles, literally, or in a more subtle way (personally, I prefer to use the score as a parameter of a probability function,
  so this way there is some chance that articles I didn't "like" still get into my timeline, unless I really marked them as "bad")

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
