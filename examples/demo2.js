var fussy = require('fussy');
var events = [
  {
    profile: 'test_user_1', signal: fussy.POSITIVE,
    content: "a video advertisement about an upcoming movie featuring pirates"
  }, {
    profile: 'test_user_1',  signal: fussy.POSITIVE,
    content: "a youtube ad about hackers"
  }, {
    profile: 'test_user_1',  signal: fussy.POSITIVE,
    content: "a facebook ad selling cloud hosting"
  }, {
    profile: 'test_user_1', signal: fussy.NEGATIVE,
    content: "a video advertisement featuring video games"
  }, {
    profile: 'test_user_1', signal: fussy.NEGATIVE,
    content: "a facebook ad about video games"
  }, {
    profile: 'test_user_2',  signal: fussy.POSITIVE,
    content: "a video advertisement about an upcoming movie featuring cowboys"
  }, {
    profile: 'test_user_2',  signal: fussy.NEGATIVE,
    content: "a movie trailer about bearded magicians"
  }, {
    profile: 'test_user_2', signal: fussy.NEGATIVE,
    content: "a facebook ad selling cloud hosting" 
  }, {
    profile: 'test_user_2', signal: fussy.POSITIVE,
    content: "a trailer for movie featuring cowboy sharks against aliens"
  }, {
    profile: 'test_user_2', signal: fussy.POSITIVE,
    content: "a facebook ad about a new farm game"
  }
];

var engine = new fussy.Engine({
  stringSize: [3, 14],
  ngramSize: 1,
  sampling: 0.8 // if you only have keywords, then increase the sampling
});

for (var i=0 ; i < events.length ; i++) {
  engine.pushEvent(events[i]);
}


// remove noise
engine.prune(-2, 2);


console.log("rate profiles for test content: " + JSON.stringify(
  engine.rateProfiles('an ad showing a video game about pirates', {limit: 2})
));
// will print: 
// rate profiles for test content: [["test_user_2",14],["test_user_1",-9]]


// how to use this data?
// well, let's imagine we can only afford to show the ad to one person.
// then it is better to show it to user_2, because user_1 probably hates video games.


console.log("rate content for test user 1: " + JSON.stringify(
  engine.rateContents('test_user_1', [
    'an ad about magicians',
    'an ad about tablet games'
  ])
));
// will print:
// rate content for test user 1: [["an ad about magicians",0],["an ad about tablet games",-3]]


console.log("rate content for test user 2: " + JSON.stringify(
  engine.rateContents('test_user_2', [
    'an ad about magicians',
    'an ad about tablet games'
  ])
));
// will print:
// rate content for test user 2: [["an ad about tablet games",0],["an ad about magicians",-2]]


engine.save("demo2.json");