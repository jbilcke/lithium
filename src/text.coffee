{isArray, isString, isEmpty} = require './utils'

###
Compute the distance between two strings

TODO
  This function needs a bit more research.

  Ideally, I would like a function that give me:
  - 1 for exact match between two strings
  - tend to 0 the further I get from the target string.

However, there are various approach and metrics to this, it is really hard to pick one.

Basically:
 - character substitution (typos)
 - phonetic(similarly sounding words)
 - n-grams (sentences)

See:
 - http://www.postgresql.org/docs/9.2/static/fuzzystrmatch.html
 - http://www.postgresql.org/docs/9.2/static/pgtrgm.html
 - http://www.mi.fu-berlin.de/wiki/pub/ABI/AdvancedAlgorithms11_Searching/script-05-FastFilteringQuasar.pdf
 - http://en.wikipedia.org/wiki/N-gram
 - http://stackoverflow.com/questions/1938678/q-gram-approximate-matching-optimisations

For for now, I am experimenting. Maybe I will use a couple of functions.
###
exports.distance = distance = (str1, str2, n=3) ->
  console.log "distance(#{str1}, #{str2})"

  _ngramize = (str, n) ->
    #console.log "str before: \"#{str}\""
    str = str.trim()
    str = str.replace(/,/, ' ', 'g')
    str = str.replace(/\s+/,' ', 'g')
    str = str.split(' ')
    #console.log "str after: \"#{str}\""
    r = []
    maxScore = 0
    for len in [1..n]
      #console.log "len: "+len+", str.length: "+str.length
      for i in [0...str.length] by 1
        words = str[i...i+len]
        continue if words.length < len
        #console.log "words: \"#{words}\""

        r.push words.join ','
        maxScore += 10 ** len
        #console.log "words.length: " + words.length
    #console.log "maxScore: " + maxScore
    [r,maxScore]

  [ngrams1,max1] = _ngramize str1, n
  [ngrams2,max2] = _ngramize str2, n

  max = Math.max max1, max2
  #console.log "max1: "+max1+", max2: "+max2+", biggest: "+max
  weight = 0
  nb_feats = 0
  for ngram1 in ngrams1
    for ngram2 in ngrams2
      #console.log "ngram1:"+ngram1+", ngram2:"+ngram2
      if ngram1 is ngram2
        depth = ngram1.split(',').length

        if depth > nb_feats
          nb_feats = depth

        if depth > 0
          weight += 10 ** depth
        console.log "depth: "+depth
  console.log "weight: "+weight+", max: "+max+", nb_feats: "+nb_feats
  console.log "result: " + (weight / max)
  final_weight = if max is 0 then 1 else weight / max
  [final_weight, nb_feats]


###
Clean a string from punctiation and useless stuff.

TODO Document it clearly: what it does and when to use it.
###
exports.cleanContent = (content) ->
  content = content.replace(/(&[a-zA-Z]+;|\\t)/g, ' ')
  content = content.replace(/(?:\.|\?|!|\:|;|,)+/g, '.')
  content = content.replace(/\s+/g, ' ')
  content = content.replace(/(?:\\n)+/g, '')
  content = content.replace(/\n+/g, '')
  content
