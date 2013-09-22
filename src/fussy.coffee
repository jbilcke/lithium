fs        = require 'fs'
thesaurus = require 'thesaurus'

debug = ->

isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))

enrich = (words) ->
  moreWords = []
  for word in words
    for anotherWord in thesaurus.find word
      moreWords.push anotherWord unless anotherWord in moreWords
  moreWords

POSITIVE = exports.POSITIVE = +1
NEGATIVE = exports.NEGATIVE = -1
NEUTRAL  = exports.NEUTRAL  = 0

# Extract n-grams from a string, returns a map
ngramize = (words, n) ->
  unless Array.isArray words
    words = words.split ' '
  grams = {}
  if n < 2
    for w in words
      grams["#{w}"] = if Array.isArray(w) then w else [w]
    return grams
  for i in [0...words.length]
    gram = words[i...i+n]
    subgrams = ngramize gram, n - 1
    for k,v of subgrams
      grams[k] = v
    if i > words.length - n
      break
    grams["#{gram}"] = gram
  grams



class exports.Engine
  constructor: (opts={}) ->
    if isString opts
      debug "loading '#{opts}'.."
      opts = JSON.parse fs.readFileSync opts, 'utf8'
    @stringSize = opts.stringSize ? [0, 30]
    @ngramSize  = opts.ngramSize ? 2
    @debug      = opts.debug ? no
    debug       = if @debug then console.log else ->
    @profiles   = opts.profiles ? {}

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

    # pretty straightfoward
    changed = content: 0, synonyms: 0

    # our dataset contains two collections:
    # raw words, and synonyms


    for facet, _ of ngramize event.content, @ngramSize
      continue unless @stringSize[0] < facet.length < @stringSize[1]
      profile[facet] = event.signal + (profile[facet] ? 0)
      changed.content++

    # use external data to improve results
    # TODO: use TF-IDF to further refine the filter,
    # are remove over-used words
    for synonym in enrich event.content.split(' ')
      for facet, _ of ngramize synonym, @ngramSize
        continue unless @stringSize[0] < facet.length < @stringSize[1]
        profile[facet] = event.signal + (profile[facet] ? 0)
        changed.synonyms++

    debug "#{if event.signal > 0 then 'reinforced' else 'weakened'} #{JSON.stringify changed} facets"

  # lighten the database, removing weak connections (neither strongly positive or negative)
  prune: (min, max) ->
    for profile, facets of @profiles
      for facet, _ of facets
        facets[facet] = facets[facet] - 1
        if min < facets[facet] < max
          delete facets[facet]

  # return scores for a single person, to see if she would like the content
  matchOne: (id, content) ->

  # return the top N users who may be interested in the content
  matchAll: (content, N) ->

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


