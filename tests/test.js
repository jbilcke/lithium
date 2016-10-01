const util = require('util')
const pretty = obj => util.inspect(obj, false, 20, true);

const lithium = require('../lithium.js');

const logic = lithium("./tests/truth-table.csv", {
  debug: false,
  allowTie: true // to allow multiple winners (top results with the same best score)
});
/*
logic.solve([{ rule: "Q", P: "F", Q: "T", R: null }], {
  //reducer: "boolean",
  allowTie: true
}).then(results => {
  console.log("test 1: " + pretty(results))
})
*/

logic.solve([{ rule: null, P: "F", Q: "T", R: "T" }]
).then(results => {
  console.log("test 2: "+ pretty(results))
})

/*
// If you do not control how the data is formatted, you can use a custom
// unknown variable detection function, like this:
logic.solve([{ rule: '<missing data>', P: "F", Q: "T", R: "T" }], {
  unknowns: (key, val) => val === '<missing data>',
}).then(results => {
  console.log("test 3: "+ pretty(results))
})
*/

// in the partial dataset, the last 4 entries have been removed, two of them
// have been made into unit tests
const shrooms = lithium("./tests/mushrooms-partial.csv", {
  // reducer: 'boolean'
});

// If you do not control how the data is formatted, you can use a custom
// unknown variable detection function, like this:
shrooms.solve([
{
  'edible': null, // 'e',
  'cap-share': 'x',
  'cap-surface': 's',
  'cap-color': 'n',
  'bruises?': 'f',
  'odor': 'n',
  'gill-attachment': 'a',
  'gill-spacing': 'c',
  'gill-size': 'b',
  'gill-color': 'y',
  'stalk-shape': 'e',
  'stalk-root': '?',
  'stalk-surface-above-ring': 's',
  'stalk-surface-below-ring': 's',
  'stalk-color-above-ring': 'o',
  'stalk-color-bellow-ring': 'o',
  'veil-type': 'p',
  'veil-color': 'o',
  'ring-number': 'o',
  'ring-type': 'p',
  'spore-print-color': 'o',
  'population': 'c',
  'habitat': 'l'
}
], {
  //unknowns: (key, val) => val === '<missing data>',
}).then(results => {
  console.log("test 4: should say it is edible:    "+ pretty(results[0].edible))
})

shrooms.solve([
{
  'edible': null, // 'e',
  'cap-share': 'k',
  'cap-surface': 'y',
  'cap-color': 'n',
  'bruises?': 'f',
  'odor': 'y',
  'gill-attachment': 'f',
  'gill-spacing': 'c',
  'gill-size': 'n',
  'gill-color': 'b',
  'stalk-shape': 't',
  'stalk-root': '?',
  'stalk-surface-above-ring': 's',
  'stalk-surface-below-ring': 'k',
  'stalk-color-above-ring': ',',
  'stalk-color-bellow-ring': 'w',
  'veil-type': 'p',
  'veil-color': 'w',
  'ring-number': 'o',
  'ring-type': 'e',
  'spore-print-color': 'w',
  'population': 'v',
  'habitat': 'l'
}
], {
  //unknowns: (key, val) => val === '<missing data>',
}).then(results => {
  console.log("test 5: should say it is poisonous: "+ pretty(results[0].edible))
})
