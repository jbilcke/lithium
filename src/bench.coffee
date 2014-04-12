
{puts, inspect} = require 'util'
{pretty} = require './utils'
{ProgressBar} = require 'progressbar'
require 'colors'

###
Benchmark utility function

TODO add more comments and documentation
###
module.exports = (opts) ->

  opts.name     ?= 'testing'
  opts.progress ?= yes
  opts.debug    ?= no
  opts.onTest   ?= (solution, predicted) -> solution is predicted

  opts.instance.insert opts.training

  if opts.progress
    progress = new ProgressBar()

    progress
      .step opts.name
      .setTotal opts.testing.length

  stats = errors: 0, tests: 0

  for test in opts.testing

    solution = test[opts.compare]
    delete test[opts.compare]

    promise = opts.instance.query
      select: opts.compare
      where: test

    results = promise.best()

    predicted = results[opts.compare]

    msg = "solution: " + solution+"\tpredicted: " + predicted

    if opts.onTest solution, predicted
      if opts.debug
        puts msg.green
    else
      stats.errors++
      if opts.debug
        puts msg.yellow
    stats.tests++
    if opts.progress
      progress.addTick()

  if opts.progress
    progress.finish()

  opts.onComplete?(stats)
  stats
