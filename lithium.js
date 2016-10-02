const util = require('util')
const Papa = require('papaparse')
const fs = require('fs')

function pretty(obj) {
  return util.inspect(obj, false, 20, true)
}

function deltascale (x, y){
  //console.log("x: "+x+", y: "+y)
  if (typeof x === 'string') {
    const nx = parseFloat(x);
    if (!isNaN(nx) && isFinite(nx)) x = nx;
  }
  if (typeof y === 'string') {
    const ny = parseFloat(y);
    if (!isNaN(ny) && isFinite(ny)) y = ny;
  }
  if (typeof x === 'string' && typeof y === 'string'){
    //console.log(`comparing ${x} with ${y}`)
    return (x === y) ? 1 : 0
  } else if (typeof x === 'string' || typeof y === 'string'){
    return 0
  } else if (typeof x === 'boolean' && typeof x === 'boolean'){
    return x == y
  } else if (typeof y === 'string' || typeof y === 'boolean'){
    return 0
  } else if (isNaN(x) || !isFinite(x)) {
    return 0
  } else if (isNaN(y) || !isFinite(y)) {
    return 0
  } else {
    var abs = Math.abs(x - y);
    var delta = (true) ? abs : x - y;
    if (abs > 1) { // give a num between 1 and 0.5
      return 1 - (1 / (1 + delta));
    } else { // give a num between 0.5 and 0
      return delta * 0.5;
    }
  }
}

function extract(database, unknowns) {
  const patterns = {};
  const unknownsArr = Array.from(unknowns.values());
  database.forEach(row => {
    const knowns = Object
      .keys(row)
      .filter(key => !unknowns.has(key))
      .map(known => [known,row[known]]);

    unknownsArr.forEach(unknown => {
      //console.log("row: "+pretty(row))
      const then = `${unknown} = ${row[unknown]}`;
      if (!patterns[then]) patterns[then] = [];
      patterns[then].push(knowns)
    })
  })
  return patterns;
}

function booleanReducer(results, allowTie = false) {
  let bests = [];
  let bestValue = -1;
  Object.keys(results).forEach(key => {
    const value = results[key];
    if (bests.length == 0) {
      bests.push(key);
      bestValue = value;
    } else if (value > bestValue) {
      bests = [ key ];
      bestValue = value;
    } else if (value == bestValue) {
      bests.push(key)
    }
  })

  return allowTie ? bests : bests[0]
}

function solve(opts = {}){

  const database = (typeof opts.database === 'undefined') ? [] : opts.database;
  const data     = (typeof opts.data     === 'undefined') ? [] : Array.isArray(opts.data)     ? opts.data     : [ opts.data     ];
  const debug    = opts.debug;
  const solveIf  = (typeof opts.unknowns  === 'function') ? opts.unknowns : function(key, value){
    return typeof value === 'undefined' || value === null
  }
  const allowTie = (typeof opts.allowTie  === 'boolean') ? opts.allowTie : false;
  const reducer  = (typeof opts.reducer === 'function')
    ? opts.reducer
    : (opts.reducer === 'boolean')
      ? booleanReducer
      : (x => x);

  const unknowns = new Set();
  data.forEach(row => {
    Object.keys(row).forEach(key => {
      if (solveIf(key, row[key])) {
        unknowns.add(key);
      }
    })
  })

  const rules = extract(database, unknowns);
  if (debug) console.log("rules: "+ pretty(rules))

  return data.map(row => {
    if (debug) console.log("row: "+ pretty(row))
    const results = {};
    Object.keys(rules).map(k => {

      //console.log("k: "+k)
      const score = rules[k]
        .reduce((total, tuples) => (
          total + tuples.reduce((s, t) => (
            s + deltascale(row[t[0]], t[1])
          ), 0) //  / Math.max(1, tuples.length)
        ), 0)

      //console.log("score: "+pretty(score))
      const parts = k.split(' = ');
      const key = parts[0];
      const value = parts[1];
      if (!results[key]) results[key] = {};
      if (!results[key][value]) results[key][value] = 0;
      results[key][value] += score;
    })

    Object.keys(results).forEach(key => (results[key] = reducer(results[key], allowTie)));
    return results;
  })
}

function lithium(src, defaults = {}, db = null){

  return {
    defaults: _defaults => {
      defaults = _defaults;
      return this;
    },
    solve: (data, opts = {}) => {
      if (!db) {
        db = new Promise((resolve, reject) => {
          if (src.match(/\n/)) { // plain file
            resolve(src)
            return;
          }
          const encoding = defaults.encoding ? defaults.encoding : 'utf8';
          fs.readFile(src, encoding, (err, csv) => {
            if (err) {
              reject(err)
            } else {
              Papa.parse(csv, {
                header: true,
              	complete: results => {
                  if (results.errors && results.errors.length && results.errors[0] && results.errors[0].row) {
                    results.data.splice(results.errors[0].row, 1)
                  }
                  resolve(results.data);
                }
              })
            }
          })
        })
      }
      return db.then(database => {
        return Promise.resolve(solve(Object.assign({}, defaults, opts, {
          database: database,
          data: data
        })))
      })
    }
  }
}

module.exports = lithium;
lithium.solve = solve;
