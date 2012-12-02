
node-cutoff
===========

*filter unwanted noise out of your news streams*

alternative title:

*your very own filter bubble*


## WARNING

WARNING: THIS PROJECT IS EXPERIMENTAL AND A WORK IN PROGRESS,
UNTIL IT IS RELEASED PLEASE DO NOT EXPECT IT TO WORK OR BE DEVELOPER-FRIENDLY

## Presentation

cutoff is a simple noise filtering engine:

cutoff will try to find articles and tweets that correspond to your tastes,
and also randomly propose new topics (those will have less probability of appearing).

Then you will have the possibility of either ignoring, liking or disliking the feed.

The more you like a topic, the more articles talking about it will appear in your feed.
if you don't like a topic, the less they should.

Since these are just probabilities, you will still find new, original articles
you didn't expect (that's the magic of maths and internet!)
so f you happen to change your mind, topics you were not interested in before
might become a trend in your private stream.

## Technology

node-cutoff is composed of two main components:

### Automatic topic detection

This works using a manually-created dataset, and feeding it to cutoff,
so it can learn from it.

How well does it perform?
For now I only managed to manually create 10 fake titles + tags,
so it is probably too small to be statistically significant.

However, I still tried to see if the algorithm worked. Here are the results:

The training dataset (manually created):

```Coffeescript
trainingDataset =
  "Twitter to sue Google over twitter stream monetization": ["Technology", "Twitter", "Google", "Internet"]
  "A new library open in the east center": ["city","library","nyc"]
  "Rumors: Apple to launch a new tablet for emerging markets": ["Technology", "Apple", "Rumor"]
  "Microsoft reveal its new data center": ["Technology", "Rumor", "Microsoft"]
  "An energy-friendly data center for emerging countries": ["Technology", "World", "Energy"]
  "History of the countries: world music festival at the museum": ["Music", "City","Culture"]
  "Visiting a museum is good for health": ["Health", "Culture"]
  "Using home brew to install appplications on your Apple macbook": ["Computers", "Software", "Apple"]
  "How to brew your own beer": ["DIY", "Fooding", "Beverages", "Beer"]
  "Facebook to reveal a new open source library": ["Opensource","Technology","Facebook","Social Networks"]
  "Open source conference give free beer to first 50 people": ["Opensource","Beer","Conference"]
  "What is in people's head? an in-depth data analysis": ["Psychology"]
```

The test data:

```Coffeescript
testing = [
  'Visit the museum using your tablet'
  'How to brew your own coffee'
  'Google to launch a new museum app'
  'Apple to sue Microsoft
]
```

once auto-tagged:

```Coffeescript
tagged =
  'Visit the museum using your tablet': [ 'Music', 'City', 'Culture' ]
  'How to brew your own coffee': [ 'DIY', 'Fooding', 'Beverages' ]
  'Google to launch a new museum app': [ 'Technology', 'Apple', 'Rumor' ]
  'Apple to sue Microsoft': [ 'Technology', 'Apple', 'Rumor' ] 
``



(More in it later)

### User profile learning

(More in it later)