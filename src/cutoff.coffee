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
enrichData = (db, raw) ->
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
  guessTopKeywords = (db, txt) ->
    keywords = getAllKeywords db, txt
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
    top = guessTopKeywords db, title
    console.log "top: "  +pretty top
    enriched["#{title}"] = top
  enriched


##########################
# WAIT FOR USER FEEDBACK #
##########################
userFeedback = (txt, keywords, feedback) ->
  console.log " --> Show to user: #{pretty txt} (#{pretty keywords.join(', ')}) (MORE) (LESS)"
  choice = Math.round Math.random() * 2 - 1
  feedback txt, keywords, choice

rawData = [
  "Visit the museum using your tablet"
  "How to brew your own coffee"
  "Google to launch a new museum app"
  "Apple to sue Microsoft"
]

database = createDatabaseFromDataset trainingDataset
console.log pretty database

enrichedData = enrichData database, rawData
console.log "enriched data: " + pretty enrichedData

for txt, keywords of enrichedData
  userFeedback txt, keywords, (txt, keywords, choice) ->
    choices = '1': 'more','-1':'less','0': 'ignore'
    console.log " <-- user choose: #{choices[choice.toString()]}"
    if choice is 0
      console.log "do nothing for " + pretty txt
      return


      # TODO download the page
            
      # extract words from description
      # add points for everyword in the database
      # read the words
      # remove or add points for everywords
      # points are used to statistically decide if we show a url or not
