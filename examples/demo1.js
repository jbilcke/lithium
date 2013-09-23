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
  }
];
var engine = new fussy.Engine({
  stringSize: [3, 14],
  ngramSize: 3
});

for (var i=0 ; i < events.length ; i++) {
  engine.pushEvent(events[i]);
}

engine.prune(-2, 2);

console.log(JSON.stringify(
  engine.profiles
));


engine.save("demo1.json");