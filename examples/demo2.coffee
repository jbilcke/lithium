{POSITIVE, NEGATIVE, Engine} = require 'fussy'
log = console.log 

events = [
    profile: 'test_user'
    content: """a video advertisement about an upcoming movie featuring pirates"""
    signal: POSITIVE # user clicked on the ad
  ,
    profile: 'test_user'
    content: """a youtube ad about hackers"""
    signal: POSITIVE # user clicked on the ad
  ,
    profile: 'test_user'
    content: """a facebook ad selling cloud hosting"""
    signal: POSITIVE # user clicked on the ad
  ,
    profile: 'test_user'
    content: """a video advertisement featuring video games"""
    signal: NEGATIVE # user trashed the ad or marked it as spam
  ,
    profile: 'test_user'
    content: """a facebook ad about video games"""
    signal: NEGATIVE # user trashed the ad or marked it as spam
]

engine = new Engine
  stringSize: [3, 14]
  ngramsSize: 3
  ignoreGlobalWords: yes # TODO this will be to enable the tf-idf algorithm to minimize influence of common words

for event in events
  engine.pushEvent event

engine.prune -2, 2

log JSON.stringify engine.profiles