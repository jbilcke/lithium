node-fussy
==========

*javascript recommendation engine*

NOTE: I'm not an English native, so feel free to open issues if you see typos and bad grammar

## Summary

node-fussy is a recommendation engine, powered by user actions.
It learns from user actions by adjusting some weights in a hidden network, one for each user.
This hidden network is built from the concepts extracted from the content evaluated by the user.
Recommendations are thus unique to each user. It can work even with 1 user and a few events in its database.


[![NPM](https://nodei.co/npm/fussy.png?downloads=true&stars=true)](https://nodei.co/npm/fussy/)

## Usage

You can see the examples/ dir, or:

### Basic demo

```javascript
var fussy = require('fussy');
var samples = [
  {
    profile: 'test_user_1', signal: fussy.POSITIVE,
    content: "a video advertisement about an upcoming movie featuring pirates"
  }, {
    profile: 'test_user_1',  signal: fussy.POSITIVE,
    content: "a youtube ad about hackers"
  }, {
    profile: 'test_user_1',  signal: fussy.POSITIVE,
    content: "a facebook ad selling cloud hosting"
  }, {
    profile: 'test_user_1', signal: fussy.NEGATIVE,
    content: "a video advertisement featuring video games"
  }, {
    profile: 'test_user_1', signal: fussy.NEGATIVE,
    content: "a facebook ad about video games"
  }, {
    profile: 'test_user_2',  signal: fussy.POSITIVE,
    content: "a video advertisement about an upcoming movie featuring cowboys"
  }, {
    profile: 'test_user_2',  signal: fussy.NEGATIVE,
    content: "a movie trailer about bearded magicians"
  }, {
    profile: 'test_user_2', signal: fussy.NEGATIVE,
    content: "a facebook ad selling cloud hosting"
  }, {
    profile: 'test_user_2', signal: fussy.POSITIVE,
    content: "a trailer for movie featuring cowboy sharks against aliens"
  }, {
    profile: 'test_user_2', signal: fussy.POSITIVE,
    content: "a facebook ad about a new farm game"
  }
];

// var engine = new fussy.Engine("./database.json");
// OR
var engine = new fussy.Engine({
  stringSize: [3, 14],
  ngramSize: 3
});

for (var i=0 ; i < samples.length ; i++) {
  engine.pushEvent(samples[i]);
}

// remove noise, by filtering weakest connections between concepts
engine.prune(-2, 2);


engine.rateProfiles('an ad showing a video game about pirates', { 
  profiles: ['test_user_1', 
             'test_user_2'] 
});

engine.rateProfiles(
 'an ad showing a video game about pirates', { limit: 2 }
);
// [ ["test_user_2",14], ["test_user_1",-9] ]

engine.rateContents('test_user_1', [
  'an ad about magicians',
  'an ad about tablet games'
]);
// [ ["an ad about magicians",0], ["an ad about tablet games",-3] ]


engine.rateContents('test_user_2', [
  'an ad about magicians',
  'an ad about tablet games'
]);
//  [ ["an ad about tablet games",0], ["an ad about magicians",-2] ]


engine.save("database.json");
```

## Algorithm

1. The user evaluates an object (eg. a tweet, a song, an ad..) by giving a score.
This score is typically +1 for a positive evaluation (eg. a like, a click on an ad, or when he buys a product),
but it can also be -1, for negative evaluation (eg. dislike, product removed from the cart, ad marked as irrelevant)

2. This score is sent together with a content to the recommendation engine. For the moment the content *must* be a plain english text string (this can be a wikipedia page, an ontology, a list of keywords.. anything relevant, with some meaning).

3. The engine extracts patterns of concepts (n-grams), and will reinforce (or weaken) connections between these concepts, depending on the evaluation given by the user.

4. The engine also try to detect weak relationships between concepts, by injecting synonyms from a thesaurus of the English language. It is nice because it can create hidden links between objects very quickly (eg. "dog picture" will be weakly connected to "wolf video", even if we never display a "dog video" or a "wolf picture" to the user)

## Characteristics


### Data-efficient

Even if data is scarce, the use of weak relationship (for the moment only synonyms) improve results even when there is not a lot of data to be trained on (eg. less than 10). there will be errors, but it should still perform better than with no data at all.

### Self-regulating

The network can change over time. New connections can be created, old ones can be reinforced or deleted. A user can choose to hate something he used to love months ago.

### Flexible

You can put anything in the content string, eg meta-keyword to describe not only the content but also the context or environment. 

You are not limited to -1 or +1, you can use any value. For instance if the user likes a product, that could be a +1, and if he buys it, a +5. This is up to you, you should do AB testing or other research to tweak this.
Just remember that a signal value of 0 will have no effect, because it represents the non-action (eg. the user just ignore the ad, or skip a product evaluation). If you want to force a link to be weakened (eg. automatically, after a few days or weeks) you have to use a negative value.


## Known issues

 * It would work better with a filter for the most common (and thus irrelevant) keywords. Than can be implemented using some kind of TF-IDF-like algorithm, but I've just not done it yet. This is the next thing on the TODO.

 * Injecting additional, weak connections is powerful, but using a thesaurus is still a bit limited. It would work even better with network data from DBpedia's ontology, or other semantic graph databases.

 * The memory usage can be a problem, because a lot of data is stored per-user. You will eventually need to purge the network from time to time, in order to remove the weakest/old links. That could be automatic, but it depends on how much memory you can use, so it won't be easy to implement this kind of GC.

 * The profile networks are not easily human-readable. They are made by and for the machine. But you could try to export them to visualize the graph in Gephi for instance.

## Documentation

### new fussy.Engine()

Instanciate a new engine with default settings

### new fussy.Engine(file_path)

Instanciate a new engine by loading a data dump file (basically a collection of profiles + the config)

### new fussy.Engine({ ngramSize: 3 }}

Instanciate a new engine, with a ngramSize of 3. Values > 3 go deeper into the meaning of the sentence (complex word patterns are added to the network), but dramatically increase the memory andcpu usage. "a n-gram size of 3 should be enough for most people" ™.

### fussy.Engine#rateContents(profile_id, array_of_content_strings)

Evaluate the interest of one profile for a set of contents.

### fussy.Engine#rateProfiles(content[, { profiles: array_of_profile_ids, limit: n_top_profiles_to_keep}])

Search for profiles that could be the most interested by a givent content.

### fussy.Engine#prune(min_weight, max_weight)

Delete non-significant links (those near 0 influence)

###fussy.Engine#save(file_path)

Dump the databse to a JSON file

### fussy.clearContent(string)

The cleaning function used internally by Fussy. It remove useless spaces and line returns. Handy to clean tweets to be printed in the console, for instance.

## TODO

 * Add a TF-IDF algorithm?
 * MongoDB implementation?

## Changelog

#### 0.0.4

 * Small optimization for the rateContents method

#### 0.0.3

 * Added the rateProfiles and rateContents methods

#### 0.0.2

 * Total rewrite. See README for more information. Yup, this file.

#### 0.0.1 (Wednesday, December 5, 2012)

 * Added `database.size`
 * Added `database.prune(threshold)`
 * Added `database.toFile(fileName)`
 * Removed the toy Twitter database from core
 * Added an example crawler you could use to build a tag database

#### 0.0.0

 * Initial version, not very documented
