{inspect} = require 'util'
pretty = (obj) -> "#{inspect obj, no, 20, yes}"
# step 1: guess topics from the text
# this will be done manually, and is hidden from the final users
# the algorithm is simple:
# we create a link between the keyword and every possible ngram in the description
# it's combinatory, but it is the most exact way of computing it

# step 2: add weight to each topic by asking the final user if it's hot or not

trainingDataset =
  "Twitter to sue Google over twitter stream monetization": ["Technology", "Twitter", "Google", "Internet"]
  "A new library open in the east center": ["city","library","nyc"]
  "Rumors: Apple to launch a new tablet for emerging markets": ["Technology", "Apple", "Rumor"]
  "Microsoft reveal its new data center": ["Technology", "Rumor", "Microsoft"]
  "An energy-friendly data center for emerging countries": ["Technology", "World", "Energy"]
  "History of the countries: world music festival at the museum": ["Music", "City","Culture"]
  "Visiting a museum is good for health": ["Health", "Culture"]
  "Using home brew to install appplications on your Apple macbook": ["Computers", "Software", "Apple"]
  "How to brew your own beer": ["DIY", "Fooding", "Beverages", "Beer"]
  "Facebook to reveal a new open source library": ["Opensource","Technology","Facebook","Social Networks"]
  "Open source conference give free beer to first 50 people": ["Opensource","Beer","Conference"]
  "What is in people's head? an in-deep data analysis": ["Psychology"]



ngramize = (words, n) ->
  #console.log "NGRAMIZE #{n}"
  unless Array.isArray words
    words = words.split ' '
  grams = {}

  if n < 2
    for w in words
      grams["#{w}"] = if Array.isArray(w) then w else [w]
    #console.log "res: #{res}"
    return grams

  for i in [0...words.length]
    gram = words[i...i+n]
    #console.log "subgramable: #{gram}"
    subgrams = ngramize gram, n - 1
    #console.log "subgrams: #{inspect subgrams}"
    for k,v of subgrams
      grams[k] = v
    if i > words.length - n
      break
    grams["#{gram}"] = gram
  grams

#console.log pretty ngramize "What is in people's head? an in-deep data analysis", 4

##########################
# LEARN FROM THE DATASET #
########################## 
database = {}
for title, keywords of trainingDataset
  for ngramString, ngramArray of ngramize title, 3
    unless ngramString of database
      database[ngramString] = ngram: ngramArray, keywords: {}
    for keyword in keywords
      unless keyword of database[ngramString].keywords
        database[ngramString].keywords[keyword] = 0
      database[ngramString].keywords[keyword] += 1

console.log pretty database

enrichData = (raw) ->

  getAllKeywords = (txt) ->
    grams = ngramize title, 3
    #console.log "grams: " + pretty grams
    keywords = {}
    for ngramString, ngramArray of grams
      if ngramString of database
        for keyword, value of database[ngramString].keywords
          unless keyword of keywords
            keywords[keyword] = 0
          keywords[keyword] += value
    keywords

  guessTopKeywords = (txt) ->
    keywords = getAllKeywords txt
    #console.log "keywords: " + pretty keywords
    top = []
    # for now we ignore the weight, but of course it is important
    for keyword, weight of keywords
      continue if weight < 3
      break if top.length > 2
      top.push keyword
    top


  enriched = {}
  for title in raw
    top = guessTopKeywords title
    console.log "top: "  +pretty top
    enriched["#{title}"] = top
  enriched



userFeedback = (feed, feedback) ->
  choice = 1 # Math.round Math.random() * 2 - 1
  feedback feed, choice

rawData = [
  "Visit the museum using your tablet"
  "How to brew your own coffee"
  "Google to launch a new museum app"
  "Apple to sue Microsoft"
]

enrichedData = enrichData rawData
console.log "enriched data: " + pretty enrichedData

for feed in feeds
  console.log "waiting for user feedback on " + pretty feed
  userFeedback feed, (feed, choice) ->
    if choice is 0
      console.log "do nothing for feed " + pretty feed
      return

    keywords = guessTopKeywords feed
    console.log "feed keywords: " + pretty keywords
      # TODO download the page
            
      # extract words from description
      # add points for everyword in the database
      # read the words
      # remove or add points for everywords
      # points are used to statistically decide if we show a url or not
