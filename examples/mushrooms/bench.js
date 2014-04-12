var Fussy = require('fussy');
var fussy = new Fussy();

var data = fussy.toolbox.shuffle(
  fussy.toolbox.dataset('data.csv', 'schema.json')
);

fussy.toolbox.bench({
  name    : 'mushrooms',
  instance: fussy,
  training: data.slice(0, 8001),
  testing : data.slice(8001, 8101),
  compare : 'edible',
  debug   : false,
  progress: true,
  onComplete: function(stats){
    console.log(fussy.toolbox.pstats(stats));
    process.exit();
  }
});
