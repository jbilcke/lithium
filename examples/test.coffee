{inspect} = require 'util'
{Database, Profile} = require 'fussy'

pretty = (obj) -> "#{inspect obj, no, 20, yes}"
wait = (t) -> (f) -> setTimeout f, t

######
# OUR 
database = new Database "dump.json"

untagged = [
  "Personally v. excited about @adaxnik menswear collection for the modern #ecowarrior: http://wwd.us/ZslDGN  #EcoChicToTheNextLev"
  "wealthy people versus poor people"
  "NOW LIVE: President Obama speaks in Mexico http://reut.rs/PoliticsLIVE"
  "Apple's Profit Slide Is Great News For Its Prospects In China http://rww.to/1004ojg "
  "Today is anti- #DRM day. I usually tend to support @W3C positions, but not I think on this. http://www.defectivebydesign.org/dayagainstdrm  @timberners_lee"
  "Breaking: The Dow Jones Industrial Average briefly crossed 15000 points for the first time.  http://on.wsj.com/ZZQ226 "
  "As the jobless rate improves to 7.5%, see how it compares to national unemployment levels since 1948. http://on.wsj.com/16yoANe"
  "Four officials suspended in South Africa's widening Gupta scandal http://reut.rs/YrQmIE "
  "Step too far? \"@NatureNews: Scientists create hybrid flu that can go airborne http://dlvr.it/3K5BsZ\""
  "How hashtagging your Instagram photos makes them more popular http://rww.to/16ymfSA  by @johnpaul"
  "Facebook Ads and Beyond, What Marketers Need to Know. http://www.socialmediaexaminer.com/facebook-ads-and-beyond-what-marketers-need-to-know/ … via @trendspottr"
]

tagged = database.tag untagged

console.log "tagged: "
for string, tags of tagged
  console.log "  #{string}:"
  sorted = []
  for tag,value of tags
    if tag.length > 2
      sorted.push [tag, value] 
  sorted = sorted.sort (a,b) -> b[1] - a[1]
  c = 0
  for x in sorted
    console.log "   - #{x[0]}: #{x[1]}"
    break if c++ > 5

process.exit()

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



