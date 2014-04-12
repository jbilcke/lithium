# Mushrooms

*On Recommendation Of Edible Mushrooms*

## Overview

Fussy is used here to classify mushrooms as edible or poisonous, using a
database of pre-classified mushrooms, described by some features (ie. physical characteristics).

## Performance

I prefer to shuffle the dataset, and run many tests, to avoid a "good sample"
bias. Granted, I haven't tested all the combinations, but so far I got:

#### mush.js:

100% accuracy (0% errors).

#### bench.js:

100% accuracy (0% errors).

## Files

#### Scripts:

- mush.js: heavily commented example, with eye candy printing
- bench.js: example using the benchmark function

#### Data files:

- data.csv: mushroom dataset, in CSV, containing a bit more than 8,100 mushrooms
- schema.json: dataset schema, defining columns and types, used by the importer

## Dataset Information

#### Reference:

Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml].
Irvine, CA: University of California, School of Information and Computer Science.

#### Source:

https://archive.ics.uci.edu/ml/datasets/Mushroom

#### Origin:

Mushroom records drawn from The Audubon Society Field Guide to North American Mushrooms (1981). G. H. Lincoff (Pres.), New York: Alfred A. Knopf

#### Donor:

Jeff Schlimmer
