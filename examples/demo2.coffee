{POSITIVE, NEGATIVE, Fussy} = require 'fussy'
log = console.log 

testDataset = [
    user: 'test_user'
    entity: 'test_product'
    content: """
      a video advertisement about an upcoming movie featuring pirates
    """
    signal: POSITIVE # user clicked on the ad
  ,
    user: 'test_user'
    entity: 'test_product'
    content: """
      a youtube ad about hackers
    """
    signal: POSITIVE # user clicked on the ad
  ,
    user: 'test_user'
    entity: 'test_product'
    content: """
      a facebook ad selling cloud hosting
    """
    signal: POSITIVE # user clicked on the ad
  ,
    user: 'test_user'
    entity: 'test_product'
    content: """
      a video advertisement featuring video games
    """
    signal: NEGATIVE # user trashed the ad or marked it as spam
  ,
    user: 'test_user'
    entity: 'test_product'
    content: """
      a facebook ad about video games
    """
    signal: NEGATIVE # user trashed the ad or marked it as spam
]
do main = ->

  log "step 0: initialize the system"
  engine = new exports.Engine
    stringSize: [3, 14]
    ngramsSize: 3
    ignoreGlobalWords: yes # will use the tf-idf algorithm to minimize influence of common words



  log "step 1: user choice"

  for event in testDataset
    engine.pushEvent event

  engine.prune -2, 2
  
  log pretty engine.profiles