{inspect} = require 'util'
deck = require 'deck'

pretty = (obj) -> "#{inspect obj, no, 20, yes}"
wait = (t) -> (f) -> setTimeout f, t


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


class Database

  constructor: (@_={}) ->
    @ngramSize = 3
    @size = 0

  learn: (tagged) =>
    for txt, keywords of tagged
      for n, ngram of ngramize txt, @ngramSize
        unless n of @_
          @_[n] = ngram: ngram, keywords: {}
        for key in keywords
          unless key of @_[n].keywords
            @size += 1
            @_[n].keywords[key] = 0
          @_[n].keywords[key] += 1
    @

  ##################################################
  # AUTOMATIC KEYWORD TAGGING OF A LIST OF STRINGS #
  ##################################################
  tag: (untagged, learn=no) =>
    if Array.isArray untagged
      tagged = {}
      for txt in untagged
        tagged["#{txt}"] = @tag txt
      if learn # auto-learn from the tagging?
        @learn tagged
      tagged
    else
      keywords = {}
      for n, ngram of ngramize untagged, 3
        if n of @_
          for k, count of @_[n].keywords
            unless k of keywords
              keywords[k] = 0
            keywords[k] += count
      keywords

  # delete connections of weight inferior or equal to a threshold
  prune: (threshold, onComplete) =>
    pruned = 
      keywords: 0
      ngrams: 0
    prunableKeywords = []
    for ngram, ngrams of @_
      prunableKeys = []
      for keyword, count of ngrams.keywords
        if count <= threshold
          prunableKeys.push keyword
      for p in prunableKeys
        delete ngrams.keywords[p]
        pruned.keywords += 1
      if Object.keys(ngrams.keywords).length is 0
        prunableKeywords.push ngram
    for p in prunableKeywords
      delete @_[p]
      pruned.ngrams += 1
  
    if onComplete?
      onComplete pruned
      return
    else
      pruned


  toFile: (fileName, onComplete) => 
    fs.writeFile fileName, @toString(), (err) ->
      throw err if err
      console.log 'It\'s saved!'
      onComplete?()


  toString: => JSON.serialize @_
  

class Profile
  constructor: (@_={}) ->

  learn: (txt, keywords=[], choice=0) =>
    for word, value of keywords
      unless word of @_ 
        @_[word] = weight: 0, count: 0
      @_[word].weight += choice
      @_[word].count += 1
  

  guess: (txt="", keywords=[]) =>

    maxConfidence = 0
    tmp = {}
    for keyword, confidence of keywords
      if keyword of @_
        tmp[keyword] = confidence
        maxConfidence = confidence if confidence > maxConfidence
    keywords = tmp
    size = Object.keys(keywords).length

    finalScore = 0
    for keyword, confidence of keywords
      count = @_[keyword].count # how many times the user saw the keyword
      weight = @_[keyword].weight # how the user like it
      finalScore += (confidence / maxConfidence) * (weight / count)
    finalScore /= size
    finalScore = 0 unless isFinite finalScore
    console.log "final score: " + pretty finalScore
    finalScore
 
  recommend: (tagged=[]) =>
    tmp = for txt, keywords of tagged
      score = @guess txt, keywords
      [txt, (1 + score) * 0.5]
    tmp.sort (a,b) -> b[1] - a[1]
    for i in tmp
      txt: i[0]
      score: i[1]

exports.Database = Database
exports.Profile = Profile