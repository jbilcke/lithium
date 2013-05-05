{inspect}   = require 'util'
fs          = require 'fs'
Twitter     = require 'mtwitter'
timmy       = require 'timmy'
{Database}  = require 'fussy'
{openGraph} = require './common'

pretty = (obj)      -> "#{inspect obj, no, 20, yes}"
wait   = (t) -> (f) -> setTimeout f, t
P      = (x)        -> Math.random() < x


config   = require './config'
credentials = require './credentials'
console.log pretty credentials
twit     = new Twitter credentials
database = new Database config.databaseFile

URLs = []


# we need to regularly prune the database or else memory will explode  
do prune = ->
  console.log "database stats: length #{database.length} keys, size #{Math.round(database.size / 1000)} Kb"
  if database.size > config.databasePruningThreshold
    console.log "pruning.."
    pruned = database.prune ({keyword, count}) -> count <= config.databasePruningWeight or keyword.length <= config.databasePruningLength
           
    console.log "pruned #{pruned.keywords} keywords and #{pruned.ngrams} ngrams\n"
    wait(3.sec) prune
  else
    #console.log "no need to prune."
    wait(3.sec) prune

# do a snapshot of the database every N seconds
do snapshot = ->
  console.log "dumping database to file.."
  database.toFile config.databaseFile
  wait(config.databaseDumpInterval) snapshot


do crawl = ->
  #console.log "we have #{URLs.length} urls.."
  if URLs.length is 0
    wait(10.ms) crawl
    return
  # for now we can only process one url at the time
  url = URLs[0]
  URLs = []
  console.log "testing " + pretty url
  openGraph url, ({description, keywords}) ->
    curated = {}
    for keyword in keywords
      if keyword.length >= 3
        curated[keyword.toLowerCase()] = 1
    keywords = Object.keys curated
    if description.length > config.minimumTitleLength and keywords.length
      # store in the database
      console.log "#{description} --> " + pretty keywords
      database.learn description, keywords
      wait(1.ms) crawl
    else
      wait(3.ms) crawl

query =
  track       : config.keywords
  lang        : config.languages
  delimited   : 'length'


twit.stream 'statuses/filter', query, (stream) ->
  stream.on 'error', (err) ->
    console.log "error: #{err}"

  stream.on 'data', (data) ->
    return if typeof(data) is "number"
    return unless data.text?
    return if data.text.length < config.minimumTweetLength
    return if data.entities.urls.length is 0
    #console.log "good candidate: #{data.text}"
    for url in data.entities.urls
      continue unless url.expanded_url?
      url = url.expanded_url
      skip = no
      for black in config.blacklist
        skip = yes if url.lastIndexOf(black, 0) is 0
      continue if skip
      #console.log "#{url} not begin with #{black}"
      URLs.push url

