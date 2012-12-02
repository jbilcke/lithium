
node-fussy
==========

*A recommendation engine that care about user actions*

## Presentation

Fussy is a minimalist recommendation engine. It filter unwanted noise out of your news streams,
but not too much: fussy will watch carefully and try to suggest things from time to time.
If you change your mind later, fussy will detect it, and adjust your profile a.k.a "filter bubble",
so that it is not a bubble anymore.

It's sounds like magic, but you can trust fussy. Because you know, he is very picky.

## How it works

Everytime your do actions, it will impact their profile, adding or removing a "weight" somewhere. 
That's why Fussy can fix profiles back.

## Installation

    $ npm install fussy

## Documentation

### Automatic text tagging

Fussy has a built-in text tagger. 

#### Learning tags
To make it work, you just have to train Fussy on a curated dataset, and he will do the rest: 

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
database.tag [
  " a second test"
]
```

### User recommendation


## Changelog

#### 0.0.0

 * Initial version, not very documented
