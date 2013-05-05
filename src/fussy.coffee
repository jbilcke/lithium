# STANDARD NODE LIBRARY MODULES
{inspect} = require 'util'
fs        = require 'fs'

# THIRD PARTIES MODULES
deck      = require 'deck'

# check if an object is a String
isString  = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))

# output a pretty string representation of an object
pretty    = (obj) -> "#{inspect obj, no, 20, yes}"

# just an alias to set timeout
wait      = (t) -> (f) -> setTimeout f, t


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


###


###
class Database

  constructor: (input) ->
    @_={}
    if input?
      if isString input
        rawData = "{}"
        try
          rawData = fs.readFileSync input
          console.log "loaded file #{input}"
        catch e
          console.log "couldn't read input file, will create a new one"
        @_ = JSON.parse "#{rawData}"
        #console.log "parsed data #{rawData}"

      else
        @_ = input

    # we will generate tuples / n-grams of 1, 2 and 3 words
    @ngramSize = 3
    @length = Object.keys(@_).length
    @size = rawData.length

  ###
  usage:
     learn { "sentence" : [ tags, .. ] }
     
     learn "sentence, [ tags, .. ]
  ###
  learn: (tagged, value) =>
    
    # learn "sentence, [ tags, .. ]
    if value?
      _tagged = {}
      _tagged["#{tagged}"] = value
      tagged = _tagged

    # learn { "sentence" : [ tags, .. ] }
    for txt, keywords of tagged
      for n, ngram of ngramize txt, @ngramSize
        #console.log "n: #{n}, ngram: #{ngram}"
        unless n of @_
          @_[n] = ngram: ngram, keywords: {}
        for key in keywords
          unless key of @_[n].keywords
            @_[n].keywords[key] = 0
          @_[n].keywords[key] += 1
    @length = Object.keys(@_).length
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


  ###

  we need to delete connections of weight inferior or equal to a threshold
  
  ###
  prune: (threshold, onComplete) =>

    pruned = 
      keywords: 0
      ngrams: 0
    prunableKeywords = []
    for ngram, ngrams of @_
      prunableKeys = []
      for keyword, count of ngrams.keywords
        if filter { keyword, count }
          prunableKeys.push keyword
      for p in prunableKeys
        delete ngrams.keywords[p]
        pruned.keywords += 1
      if Object.keys(ngrams.keywords).length is 0
        prunableKeywords.push ngram
    for p in prunableKeywords
      delete @_[p]
      pruned.ngrams += 1
    @length = Object.keys(@_).length
  
    if onComplete?
      onComplete pruned
      return
    else
      pruned


  toFile: (fileName, onComplete) => 
    fs.writeFile fileName, "#{@}", (err) ->
      throw err if err
      console.log 'It\'s saved!'
      onComplete?()


  toString: => 
    dump = JSON.stringify @_, null, 2
    @size = dump.length
    dump
  

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
