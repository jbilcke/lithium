{inspect} = require 'util'
{Database, Profile} = require 'fussy'

pretty = (obj) -> "#{inspect obj, no, 20, yes}"
wait = (t) -> (f) -> setTimeout f, t

######
# OUR 
database = new Database()

training =
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
  "Lady Gaga": ["Lady Gaga"]
  "Bieber": ["Bieber"]
  """John Lennon once claimed that the Beatles' "Ticket to Ride" was "one of the earliest heavy-metal records." http://t.co/ipgk6qbqWO""":

database.learn training

console.log database.toString()

untagged = [
  "Visit the NYC museum using your tablet"
  "How to brew your own coffee"
  "Google to launch a new museum app"
  "Apple to sue Microsoft"
]

tagged = database.tag untagged

console.log "tagged: " + pretty tagged

userFeedback = (txt, keywords, feedback) ->
  console.log " --> #{pretty txt} (MORE) (LESS)"
  choice = Math.round Math.random() * 2 - 1
  wait(100) -> feedback txt, keywords, choice

profile = new Profile()

do simulation = ->
 
  recommended = profile.recommend tagged
  console.log "recommendations: " + pretty recommended

  keys = Object.keys tagged
  txt = keys[Math.round Math.random() * (keys.length - 1)]
  keywords = tagged[txt]

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

    profile.learn txt, keywords, choice

  #console.log "waiting for answer from user"
  wait(200) simulation



