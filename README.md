
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

This works using a maually-created dataset, and feeding it to cutoff,
so it can learn from it.

(More in it later)

### User profile learning

(More in it later)