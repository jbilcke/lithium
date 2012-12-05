{inspect}   = require 'util'
Twitter     = require 'ntwitter'
timmy       = require 'timmy'
{Database}  = require 'fussy'
{openGraph} = require './common'

pretty = (obj)      -> "#{inspect obj, no, 20, yes}"
wait   = (t) -> (f) -> setTimeout f, t
P      = (x)        -> Math.random() < x

database = new Database()
twit     = new Twitter require './credentials'

blacklist = [
  "http://instagr.am"
  "http://yfrog.com"
  "http://tmblr.co"
  "http://youtu.be"
  "https://youtu.be"
  "http://www.youtube."
  "http://fb.me"
  "https://fb.me"
  "http://www.amazon."
  "http://google."
  "https://google."
  "http://youtube."
  "http://facebook."
  "https://facebook."
  "http://twitter."
  "https://twitter."
  "http://pinterest"
  "http://twitpic."
  "http://ask.fm"
  "http://4sq.com"
  "http://25.media.tumblr.com"
]

URLs = []


# we need to regularly prune the database or else memory will explode  
do prune = ->
  console.log "database size: #{database.size} entries"
  if database.size > 100
    console.log "pruning.."
    pruned = database.prune 2
    console.log "pruned #{pruned.keywords} keywords and #{pruned.ngrams} ngrams\n"
    wait(30.sec) prune
  else
    console.log "no need to prune."
    wait(5.sec) prune

# do a snapshot of the database every N seconds
do snapshot = ->
  return
  console.log "dumping database to file.."
  database.toFile 'dump.json'
  wait(60.sec) snapshot


do crawl = ->
  console.log "we have #{URLs.length} urls.."
  if URLs.length is 0
    wait(1.sec) crawl
    return
  # for now we can only process one url at the time
  url = URLs[0]
  URLs = []
  console.log "testing " + pretty url
  openGraph url, ({description, keywords}) ->
    if description.length > 3 and keywords.length and keywords[0] isnt ''
      # store in the database
      console.log "#{description} --> " + pretty keywords
      database.learn description, keywords
      wait(5.ms) crawl
    else
      wait(20.ms) crawl

twit.stream 'statuses/sample', (stream) ->
  stream.on 'data', (data) ->
    return unless data.entities.urls.length and data.user.lang is 'en'
    for url in data.entities.urls
      continue unless url.expanded_url?
      url = url.expanded_url
      skip = no
      for black in blacklist
        skip = yes if url.lastIndexOf(black, 0) is 0
      continue if skip
      #console.log "#{url} not begin with #{black}"
      URLs.push url

