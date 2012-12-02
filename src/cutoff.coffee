{inspect} = require 'util'
deck = require 'deck'
pretty = (obj) -> "#{inspect obj, no, 20, yes}"
wait = (t) -> (f) -> setTimeout f, t
# step 1: guess topics from the text
# this will be done manually, and is hidden from the final users
# the algorithm is simple:
# we create a link between the keyword and every possible ngram in the description
# it's combinatory, but it is the most exact way of computing it

# step 2: add weight to each topic by asking the final user if it's hot or not

trainingDataset =
  "Twitter to sue Google over twitter stream monetization": ["Technology", "Twitter", "Google", "Internet"]
  "A new library open in the east center in NYC": ["city","library","nyc"]
  "Rumors: Apple to launch a new tablet for emerging markets": ["Technology", "Apple", "Rumor"]
  "Microsoft reveal its new data center": ["Technology", "Rumor", "Microsoft"]
  "An energy-friendly data center for emerging countries": ["Technology", "World", "Energy"]
  "History of the countries: world music festival at the museum": ["Music", "City","Culture"]
  "Visiting a museum is good for health": ["Health", "Culture"]
  "Using home brew to install appplications on your Apple macbook": ["Computers", "Software", "Apple"]
  "How to brew your own beer": ["DIY", "Fooding", "Beverages", "Beer"]
  "Facebook to reveal a new open source library": ["Opensource","Technology","Facebook","Social Networks"]
  "Open source conference give free beer to first 50 people in NY": ["Opensource","Beer","Conference", "City"]
  "What is in people's head? an in-depth data analysis": ["Psychology"]


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

#######################################################
# LEARN FROM THE DATASET AND BUILD A WEIGHTED NETWORK #
#######################################################
createDatabaseFromDataset = (set, size=3) ->
  db = {}
  for txt, keywords of set
    for n, ngram of ngramize txt, size
      unless n of db
        db[n] = ngram: ngram, keywords: {}
      for key in keywords
        unless key of db[n].keywords
          db[n].keywords[key] = 0
        db[n].keywords[key] += 1
  db

#######################################
# AUTOMATIC KEYWORD TAGGING OF A TEXT #
#######################################
enrichData = (db, raw,weighted=no) ->

  getAllKeywords = (db, txt) ->
    grams = ngramize title, 3
    #console.log "grams: " + pretty grams
    keywords = {}
    for ngramString, ngramArray of grams
      if ngramString of db
        for keyword, value of db[ngramString].keywords
          unless keyword of keywords
            keywords[keyword] = 0
          keywords[keyword] += value
    keywords

  guessTopKeywords = (db, txt, maxKeywords=3, minWeight=2) ->
    keywords = getAllKeywords db, txt
    #console.log "keywords: " + pretty keywords
    top = []
    # for now we ignore the weight, but of course it is important
    for keyword, weight of keywords
      continue if weight < minWeight
      break if top.length >= maxKeywords
      top.push keyword
    top

  enriched = {}
  for title in raw
    top = []
    if weighted
      top = getAllKeywords db, title
    else
      top = guessTopKeywords db, title
    console.log "top: "  +pretty top
    enriched["#{title}"] = top
  enriched

##############################################
# GUESS IF AN ARTICLE WILL INTEREST THE USER #
##############################################
computeInterestScore = (txt, keywords, profile) ->

  maxConfidence = 0
  keptKeywords = {}
  for keyword, confidence of keywords
    if keyword of profile
      keptKeywords[keyword] = confidence
      maxConfidence = confidence if confidence > maxConfidence

  keywords = keptKeywords
  size = Object.keys(keywords).length

  finalScore = 0
  for keyword, confidence of keywords
    count = profile[keyword].count # how many times the user saw the keyword
    weight = profile[keyword].weight # how the user like it
    finalScore += (confidence / maxConfidence) * (weight / count)
  finalScore /= size
  finalScore = 0 unless isFinite finalScore

  console.log "final score: " + pretty finalScore

  finalScore


#####
#   #
#####
computeScores = (db, data, profile) ->
  result = {}
  for txt, keywords of data
    score = computeInterestScore txt, keywords, profile
    result[txt] = score
  result

#####
# RETURN  #
#####
sortScoredData = (scoredData) ->
  tmp = for k, v of scoredData
    [k, 1 + v]
  tmp.sort (a,b) -> b.v - a.v
  for i in tmp
    txt: i[0]
    score: i[1] - 1

##########################
# WAIT FOR USER FEEDBACK #
##########################
userFeedback = (txt, keywords, feedback) ->
  console.log " --> #{pretty txt} (MORE) (LESS)"
  choice = Math.round Math.random() * 2 - 1
  wait(100) -> feedback txt, keywords, choice

rawData = [
  "Visit the NYC museum using your tablet"
  "How to brew your own coffee"
  "Google to launch a new museum app"
  "Apple to sue Microsoft"
]

database = createDatabaseFromDataset trainingDataset
console.log pretty database

enrichedData = enrichData database, rawData, yes
console.log "initial enriched data: " + pretty enrichedData

profile = {}

scoredData = computeScores database, enrichedData, profile
console.log "initial scored data: " + pretty scoredData

##########################################
# SUBMIT INITIAL (RANDOM) FEEDS TO USERS #
##########################################
mode = 'random' # 'recommended'
seen = {}
do simulation = ->
  console.log "update the profile <--> feed link.."
  scoredData = computeScores database, enrichedData, profile
  console.log "scored data: " + pretty scoredData
  topData = sortScoredData scoredData
  console.log "top feeds: " + pretty topData

  keywords = []
  txt = ""
  if mode is 'random'
    console.log "RANDOM"
    keys = Object.keys enrichedData
    txt = keys[Math.round Math.random() * (keys.length - 1)]
    keywords = enrichedData[txt]
    console.log "keywords: :::: " + pretty keywords

  else if mode is 'recommended'
    console.log "RECOMMENDED"

  console.log "txt: #{txt}  keywords: #{keywords}"

  unless txt
    console.log "nothing to show"
    wait(100) simulation
    return

  userFeedback txt, keywords, (txt, keywords, choice) ->
      choiceStr = {'1': 'LIKE','-1':'DISLIKE','0': 'IGNORE'}[choice.toString()]
      console.log " <-- user choose to #{choiceStr}"
      if choice is 0
        console.log "do nothing for " + pretty txt
        return
      for word, value of keywords
        unless word of profile 
          profile[word] = weight: 0, count: 0
        profile[word].weight += choice
        profile[word].count += 1
  #console.log "waiting for answer from user"
  wait(200) simulation



