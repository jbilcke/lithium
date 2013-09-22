
thesaurus = require 'thesaurus'

debug = ->

enrich = (words) ->
  moreWords = []
  for word in words
    for anotherWord in thesaurus.find word
      moreWords.push anotherWord unless anotherWord in moreWords
  moreWords

POSITIVE = exports.POSITIVE = +1
NEGATIVE = exports.NEGATIVE = -1
NEUTRAL  = exports.NEUTRAL  = 0

#################################
# EXTRACT N-GRAMS FROM A STRING #
#################################
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
    @stringSize = opts.stringSize ? [0, 30]
    @ngramsSize = opts.ngramsSize ? 2
    @debug      = opts.debug ? no
    debug = if debug then console.log else ->
    @profiles = {}

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


    for facet, _ of ngramize event.content, @ngramsSize
      continue unless @stringSize[0] < facet.length < @stringSize[1]
      profile[facet] = event.signal + (profile[facet] ? 0)
      changed.content++

    # use external data to improve results
    # TODO: use TF-IDF to further refine the filter,
    # are remove over-used words
    for synonym in enrich event.content.split(' ')
      for facet, _ of ngramize synonym, 3
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
