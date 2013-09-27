fs        = require 'fs'
thesaurus = require 'thesaurus'
{pick}    = require 'deck'

debug = ->

isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))

P = (p=0.5) -> + (Math.random() < p)

replaceAll = (find, replace, str) ->
   str.replace(new RegExp(find, 'g'), replace)

exports.cleanContent = cleanContent = (content) -> 
  content.replace(/(?:\.|\?|!)+/g, '.').replace(/\s+/g, ' ').replace(/(?:\\n)+/g, '').replace(/\n+/g, '')

enrich = (words) ->
  moreWords = []
  for word in words
    similarWords = thesaurus.find word

    if similarWords.length
      # ignore words with too many different meanings, for complexity's sake
      continue if similarWords.length > 3

      # only add up to 4 similar words
      for similarWord in similarWords[...3]

        # ignore words too small or too large
        continue unless 2 < similarWord.length < 13

        # ignore synonyms already added
        continue if similarWord in moreWords

        moreWords.push similarWord 

    # no synonym found.. maybe a number?
    else
      test = (Number) word
      continue unless (not isNaN(test) and isFinite(test))

      categories = [
        10, 20, 30, 40, 50, 60, 70, 80, 90,
        100, 200, 300, 400, 500, 600, 700, 800, 900,
        1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 
        10000
      ]
      for category in categories
        if test < category
          moreWords.push "less_than_#{category}"
          break

      for category in categories.reverse()
        if test > category
          moreWords.push "more_than_#{category}"
          break
    

  moreWords

POSITIVE = exports.POSITIVE = +1
NEGATIVE = exports.NEGATIVE = -1
NEUTRAL  = exports.NEUTRAL  = 0

# Extract n-grams from a string, returns a map
_ngramize = (words, n) ->
  unless Array.isArray words
    words = for w in words.split ' '
      continue if w.length < 3
      w

  grams = {}
  if n < 2
    for w in words
      grams["#{w}"] = if Array.isArray(w) then w else [w]
    return grams
  for i in [0...words.length]
    gram = words[i...i+n]
    subgrams = _ngramize gram, n - 1
    for k,v of subgrams
      grams[k] = v
    if i > words.length - n
      break
    grams["#{gram}"] = gram
  grams

ngramize = (words, n) -> 
  for ngram in Object.keys _ngramize words, n
    ngram.split(",").sort().toString()

class exports.Engine
  constructor: (opts={}) ->
    if isString opts
      debug "loading '#{opts}'.."
      opts = JSON.parse fs.readFileSync opts, 'utf8'
    @stringSize = opts.stringSize ? [0, 30]
    @ngramSize  = opts.ngramSize ? 3
    @debug      = opts.debug ? no
    @sampling   = opts.sampling ? 0.3
    debug       = if @debug then console.log else ->
    @profiles   = opts.profiles ? {}


  multiplyFacets: (content, facets=[]) ->

    words = content.split ' '

    for a in facets
      for b in facets
        facet = [a,b].sort().toString()
        continue if a is b
        continue unless P @sampling
        facets.push facet

    # find extra facets using a synonym database
    for synonym in enrich words
      for facet in @ngramize synonym
        facets.push facet
    facets

  ngramize: (words) ->
    ngramize words, @ngramSize

  pushEvent: (event) ->

    if event.signal is NEUTRAL
      debug "signal is neutral, ignoring"
      return

    # analyze the content
    if !@profiles[event.profile]?
      debug "creating profile for #{event.profile}"
      @profiles[event.profile] = {}

    profile = @profiles[event.profile]

    debug "updating profile #{event.profile}.."

    content = cleanContent event.content

    alreadyAdded = {}
    for facet in @multiplyFacets content, @ngramize content

      # filter
      continue unless @stringSize[0] < facet.length < @stringSize[1]
      continue if facet of alreadyAdded

      alreadyAdded[facet] = profile[facet] = event.signal + (profile[facet] ? 0)
    
    @

  # lighten the database, removing weak connections (neither strongly positive or negative)
  prune: (min, max) ->
    for profile, facets of @profiles
      for facet, _ of facets
        facets[facet] = facets[facet] - 1
        if min < facets[facet] < max
          delete facets[facet]
    @

  # search for profiles matching a given content,
  # and evaluate them
  # you can optionally limit the number of results to the first N,
  # using the {limit: N} parameter,
  # or filter result to a restricted list of profiles using {profiles: ["some_id"]}
  rateProfiles: (content, opts={}) ->
    filter = opts.profiles ? []
    limit = opts.limit
    results = []

    content = cleanContent content

    facets = []
    for facet in @multiplyFacets content, @ngramize content
      continue if facet in facets
      facets.push facet

    for id, profile of @profiles
      continue if filter.length and id not in filter
      score = 0
      for facet in facets
        score += profile[facet] ? 0
      results.push [id, score]

      continue unless limit?
      break if --limit <= 0

    results.sort (a, b) -> b[1] - a[1]
    results

  # rate an array of contents for a given profile id,
  # sorting results from best match to worst
  rateContents: (id, contents) ->
    profile = @profiles[id] ? {}

    top = []
    id = 0
    for content in contents
      score = 0
      alreadyAdded = {}
      for facet in @multiplyFacets content, @ngramize content
        continue if facet of alreadyAdded
        score += profile[facet] ? 0
        alreadyAdded[facet] = yes
      top.push [content, score]
    top.sort (a, b) -> b[1] - a[1]
    top

  save: (filePath) ->
    throw "Error, no file path given" unless filePath?
    # the code is written using appendFileSync, this is not pretty
    # but when exporting huge database it allows us to see the progression line by line
    # eg. using "watch ls -l" or "tail -f file.json" on unix
    write = (x) -> fs.appendFileSync filePath, x.toString() + '\n'
    #write = (x) -> console.log "#{x}"
    fs.writeFileSync filePath, '{\n' # first line is in write-mode
    write """  "stringSize": [#{@stringSize}],"""
    write """  "ngramSize": #{@ngramSize},"""
    write """  "profiles": {"""

    remaining_profiles = Object.keys(@profiles).length # not efficient?
    for profile, facets of @profiles
      write """    "#{profile}": {"""
      remaining_facets = Object.keys(facets).length # not efficient?
      for facet, weight of facets
        write """      "#{facet}": #{weight}#{if --remaining_facets > 0 then ',' else ''}"""
      write """    }#{if --remaining_profiles > 0 then ',' else ''}"""
    write """  }\n}"""


