node-fussy
==========

*javascript recommendation engine*

NOTE: I'm not an English native, so feel free to open issues if you see typos and bad grammar

## Summary

[![NPM](https://nodei.co/npm/fussy.png?downloads=true&stars=true)](https://nodei.co/npm/fussy/)

## Usage

You can see the examples/ dir, or:

### Basic demo

```Javascript
var fussy = require('fussy');
var events = [
  {
    user: 'test_user', // a unique ID to identify a user
    content: "a video advertisement about an upcoming movie featuring pirates",
    signal: fussy.POSITIVE
  }, {
    user: 'test_user',
    content: "a youtube ad about hackers",
    signal: fussy.POSITIVE
  }, {
    user: 'test_user',
    content: "a facebook ad selling cloud hosting",
    signal: fussy.POSITIVE
  }, {
    user: 'test_user',
    content: "a video advertisement featuring video games",
    signal: fussy.NEGATIVE
  }, {
    user: 'test_user',
    content: "a facebook ad about video games",
    signal: fussy.NEGATIVE
  }
];


var engine = new fussy.Engine("./existing_database.json");
// OR
var engine = new fussy.Engine({
  "ngramSize": 3,
  "debug": true // totally optional, if you enable this this will print some stuff to the console
});

for (var i=0 ; i < events.length ; i++) {
  engine.pushEvent(events[i]);
}

// just for debug
console.log(JSON.stringify(engine.profiles));

// exports the database to a json file
engine.saveAs("demo1.json");
```

## Algorithm

1. The user evaluates an object (eg. a tweet, a song, an ad..) by giving a score.
This score is typically +1 for a positive evaluation (eg. a like, a click on an ad, or when he buys a product),
but it can also be -1, for negative evaluation (eg. dislike, product removed from the cart, ad marked as irrelevant)

2. This score is sent together with a content to the recommendation engine. For the moment the content *must* be a plain english text string (this can be a wikipedia page, an ontology, a list of keywords.. anything relevant, with some meaning).

3. The engine extracts patterns of concepts (n-grams), and will reinforce (or weaken) connections between these concepts, depending on the evaluation given by the user.

4. The engine also try to detect weak relationships between concepts, by injecting synonyms from a thesaurus of the English language. It is nice because it can create hidden links between objects very quickly (eg. "dog picture" will be weakly connected to "wolf video", even if we never display a "dog video" or a "wolf picture" to the user)


## Features

### Efficient

Even if data is scarce, the injection of external relationships make it possible to work on a few events (eg. less than 10). It won't be perfect, but it should still perform better than with no data at all.

### Self-regulating

The network can change over time. New connections can be created, old ones can be reinforced or deleted. A user can choose to hate something he used to love months ago.

### More or less customizable

You are not limited to -1 or +1, you can use any value. For instance if the user likes a product, that could be a +1, and if he buys it, a +5. This is up to you, you should do AB testing or other research to tweak this.
Just remember that a signal value of 0 will have no effect, because it represents the non-action (eg. the user just ignore the ad, or skip a product evaluation). If you want to force a link to be weakened (eg. automatically, after a few days or weeks) you have to use a negative value.

## Known issues

 * It would work better with a filter for the most common (and thus irrelevant) keywords. Than can be implemented using some kind of TF-IDF-like algorithm, but I've just not done it yet.

 * Injecting additional, weak connections is powerful, but using a thesaurus is still a bit limited. It would work even better with network data from DBpedia's ontology, or other semantic graph databases.

 * The memory usage can be a problem, because a lot of data is stored per-user. You will eventually need to purge the network from time to time, in order to remove the weakest/old links. That could be automatic, but it depends on how much memory you can use, so it won't be easy to implement this kind of GC.

 * The profile networks are not easily human-readable. They are made by and for the machine. But you could try to export them to visualize the graph in Gephi for instance.


## TODO

 * Export / Save of the recommendation database. That's a block, without that Iit is still a bit useless.


## Changelog

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
