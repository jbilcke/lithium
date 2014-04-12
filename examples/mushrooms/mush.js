//
var Fussy = require('fussy');

// these 4 lines are just to add some eye-candy console printing
require('colors');
var util = require('util');
var puts = util.puts;
var pretty = function(x){ return ""+util.inspect(x, false, 20, true); };


// get an instance of fussy
var fussy = new Fussy();

// import and shuffle a dataset
var data = fussy.toolbox.shuffle(
  fussy.toolbox.dataset('data.csv', 'schema.json')
);

// select the training and testing samples
var training = data.slice(0, 8001); // train on 8,000 mushrooms
var testing  = data.slice(8001, 8101); // test on 100 mushrooms

// use the training dataset
fussy.insert(training);


var i, test, solution, query;
for (i=0; i < testing.length; i++) {
  test = testing[i];

  // read the solution for later use
  solution = test['edible'];

  // delete it from the data, so that Fussy will have to work to solve it
  delete test['edible'];

  // ask Fussy to guess the best candidate for the missing 'edible' field
  var prediction = fussy.query({select: 'edible', where: test}).best();

  // check if this is the solution. we can have multiple predicted fields,
  // so you need to target the ones you want
  var is_right = (solution === prediction['edible']);

  // the rest is just eye candy boilerplate, to display the result in green
  // if we did a good prediction, yellow if we missed a edible mushroom,
  // and red if we missed a poisonous mushroom, which means game over.
  if (is_right) {
      if (solution == 'edible') msg = 'eat ';
      puts(
        ((solution === 'edible') ? 'eat ' : 'skip').green
        + (" ("+solution+")").grey);
  } else {
    if (solution === 'edible') {
        puts(("MISSED ("+solution+")").yellow);
    } else {
        puts(("FATAL ("+solution+")").red);
    }
  }

}
