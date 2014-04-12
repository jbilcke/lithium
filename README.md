# node-fussy

*JSON prediction and recommendation engine*

[![Build Status](https://secure.travis-ci.org/jbilcke/node-fussy.png)](http://travis-ci.org/jbilcke/node-fussy)
[![Dependency Status](https://gemnasium.com/jbilcke/node-fussy.png)](https://gemnasium.com/jbilcke/node-fussy)

## Summary

Fussy is an inference engine for Node. You can use it to guess missing values in a JSON object.

It tried to find the most probable values for missing attributes by scanning a database of previously seen objects, computing a weighted average based on similarity.


## Examples

Demo examples (included in the project):

- [Logic: playing with boolean and fuzzy truth tables](https://github.com/jbilcke/node-fussy/tree/master/examples/logic)
- [Mushrooms: recommendation of mushrooms](https://github.com/jbilcke/node-fussy/tree/master/examples/mushrooms)

More examples:

- [Sonar: categorization of sonar data into mines or rocks](https://github.com/jbilcke/node-fussy-examples/tree/master/sonar)
- [Wilt: detecting diseased trees in Quickbird imagery](https://github.com/jbilcke/node-fussy-examples/tree/master/wilt)
- [Emotiv: detecting eye state from Emotiv EEG Headset](https://github.com/jbilcke/node-fussy-examples/tree/master/emotiv)
- [Letters: letter recognition (OCR)](https://github.com/jbilcke/node-fussy-examples/tree/master/letters)


## License

BSD (see LICENCE.txt file).

## Current issues

Fussy is an experimental project, and has a number of pitfalls:

 - no tests yet (but soon)
 - code is alpha quality, not reviewed
 - all data must be loaded into memory (cannot use a remote db yet)
 - extremely slow (see mushroom demo..)
 - the "0" value is not supported well
 - not tested for strings (distance function is a bit broken, and will be rewritten)
 - and probably many other bugs..


## How it works

### Algorithm

The algorithm works as the following:

For a given JSON object with some missing fields, it tries to determine the most probable value of these fields, by looking at all the past values, and computing the average.

However, it does a weighted average: a different "trust" is given to each past object, depending on how close and relevant they are from the object to repair.

For this, what Fussy do is iteraring over all the stored objects (in a map-reduce fashion), and computing a distance score, based on the similarity between values: strings, numbers..

This distance will be used to weight the value of the missing field when computing the average.



## Quick-start

### Installation

#### As a dependency

Go to your Node (and NPM-managed) project, and run:

    $ npm install fussy --save

#### From sources

To download the sources, build the coffee-script and link into your system:

    $ git clone git@github.com:jbilcke/node-fussy.git
    $ cd node-fussy
    $ npm run build
    $ npm link


### Initialization

First you have to get an instance of the class Fussy

```javascript
var Fussy = require('fussy');
var fussy = new Fussy();
```

### Inserting JSON data

Then you can insert documents. You have a few ways of doing this.

You can use use the `insert` method, which takes a JSON object, or an array of
objects:

```javascript
fussy
  .insert({ 'food': 'rice',  'taste': 'good'});
  .insert([
    { 'food': 'salad', 'taste': 'good'},
    { 'food': 'grass', 'taste': 'bad' }
  ]);

```

### Importing a dataset

After spending some time using Fussy on various datasets, I found it handy
to write a small importer for CSV files. So here we go!

The `import` function takes an input CSV file, and a list of columns as parameter:

```javascript
var data = fussy.import('thermal.csv', [ 'day', 'temperature' ]);
```

This second parameter can be used to define types:

```javascript
fussy.import('thermal.csv', [
    ['day','String'],
    ['temperature','Number']
]);
```

You can also define a dictionary of values, when using Strings:

```javascript
fussy.import('thermal.csv', [
    ['day', {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday'
      }],
    ['temperature','Number']
]);
```

### Using the dataset function

Sometimes you need to do some operations on a dataset before using it.

For instance, maybe you only want to keep a subset of the dataset, or do
random sampling, so you need access to the array before importing it.

Fussy provides a function to create a dataset (array of JSONs), available
in the `fussy.toolbox` object.

The `fussy.toolbox.dataset` takes an input CSV file and a list of columns as
parameter.

It works like the import function:

```javascript
var data = fussy.toolbox.dataset('thermal.csv', [ 'day', 'temperature' ]);
```

You can then manipulate this array, before importing it. For instance:

```javascript
var data = fussy.toolbox.shuffle(
  fussy.toolbox.dataset('data.csv', 'schema.json')
);
```

Will load the dataset and shuffle it.


### Predicting data


```javascript
var query = fussy.query({
  select: ['column'],
  where: {
    foo: '',
    bar: ''
  }
});
```

### Using the results

When you call the query object, what you get is a result set, or "view" on
the data. This view has the following methods:

#### best()

The `best` function returns the best value for a given field. It actually
just takes the first element of the `all` function.

Depending on the distribution and the category of problem you are trying to
solve, this might not be the best choice for you.

#### mix()

The `mix` compute the weighted average value for a numeric field.

For instance, say there are 3 possible values for a "temperature" field: 10, 20, 40..

While the `all` function will returns an array of value->weight, the `mix`
function will directly returns you the weighted average, eg. 23.33.

#### all()

The `all` function returns the distribution of values: an array sorted by weight,
of all possible choices for the requested fields.

This is actually an array of `(value, weight)` tuples.

Use this function if you want access to raw data, and need to make
multiple, weighted decisions. (eg. for investment, risk management use cases).
