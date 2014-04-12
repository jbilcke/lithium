###
WARNING:
This file is quite old, and could use some cleaning or refactoring.

Maybe be split into submodules, and cleaner way of handling synchronous and
asynchronous modes.
###

###
standard library
###
util = require 'util' # used for inspect, isArray
fs   = require 'fs'   # filesystem operations
path = require 'path' # file path operations

###
managed modules
###
deck      = require 'deck'       # shuffler
colors    = require 'colors'     # console colors
csvString = require 'csv-string' # csv row parser


###
Check if a reference is an Array. We use the native function.
###
exports.isArray = isArray = util.isArray
###
Check if a reference is a String.

(taken from underscore.coffee)
###
exports.isString = isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))

###
Check if a reference is a Function.

(taken from underscore.coffee)
###
exports.isFunction = isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)

###
Check if a reference is a Boolean.

(taken from underscore.coffee)
###
exports.isBoolean = isBoolean   = (obj) -> obj is true or obj is false

###
Check if a reference is a Number.

(taken from underscore.coffee)
###
exports.isNumber = isNumber = (obj) -> toString.call(obj) is '[object Number]'

###
Check is an object is empty.

(taken from underscore.coffee)
###
exports.isEmpty = isEmpty = (obj) ->
  return obj.length is 0 if isArray(obj) or isString(obj)
  return false for own key of obj
  true

###
Pretty-print an object (convert to coloured string)
###
exports.pretty = pretty = (obj) -> "#{util.inspect obj, no, 20, yes}"

###
Pretty-print performances.

This is a low-level function, just pretty printing the value to colored string.
###
exports.pperf = pperf = (nbErrors, total=100, decimals=2) ->
  p = 100 - (nbErrors / total) * 100
  t = "#{p.toFixed decimals}%"
  if p < 50
    t.red
  else if p < 80
    t.yellow
  else
    t.green

###
Pretty-print performances.

This is a high-level function, printing out some more info, in addition to the
actual performance.
###
exports.pstats = pstats = ({errors, tests}) ->
  "performance: "+pperf(errors, tests) + " (#{errors} errors for #{tests} tests)"


###
TODO Document and add comments to this function
###
exports.fields2map = fields2map = (fields) ->
  map = {}
  if fields.length is 1
    field = fields[0]
    if isString field
      map[field] = []
    else if isArray field
      for k, v of field
        map[k] = v
    else
      for key, values of field
        map[key] = if isArray values
            values
          else
            [ values ]
  else
    for field in fields
      map[field] = []
  map

###
TODO Document and add comments to this function
###
exports.findsum = findsum = (obj, pattern, root=yes) ->

  #pattern = pattern.replace /\*\*/g,'*.*'
  [head, last...] = pattern.split '.'

  tmp =  0
  match = no
  for key, value of obj
    # are we a leaf?
    if head is '*' or head is key
      match = yes
      if last.length is 0
        x = (Number) value
        unless isNaN x
          tmp += x
      else
        [sub_sum, match] = findsum(value, last.join('.'), no)
        if match is yes
          tmp += sub_sum

  if root
    tmp
  else
    [tmp, match]

###
TODO Document and add comments to this function
###
exports.find = find = (obj, pattern, root=yes) ->

  #pattern = pattern.replace /\*\*/g,'*.*'

  [head, last...] = pattern.split '.'

  tmp = {}
  match = no
  for key, value of obj
    # are we a leaf?
    if head is '*' or head is key
      match = yes
      if last.length is 0
        x = (Number) value
        unless isNaN x
          tmp[key] = x + tmp[key] ? 0
      else
        [sub_map, match] = findsum(value, last.join('.'), no)
        if match is yes
          for k,v of sub_map
            tmp[k] = v + tmp[k] ? 0

  if root
    tmp
  else
    [tmp, match]

###
A global cache, used to store schema.

TODO FIXME
Doing this is prone to memory leaks. Schemas are lightweight, but never deleted.
A better implementation would use an expiration timeout, or limits the number of
stored schemas.
###
parse_cache = {}

###
Load a dataset schema.

Can be:
 - a String (file path to JSON file)
 - a JSON object (pre-loaded file).
###
exports.loadSchema = loadSchema = (schema) ->
  # file path?
  if isString schema
    # replace by the cached version, or replace by a new one
    if schema of parse_cache
      #console.log "using cache"
      parse_cache[schema]
    else
      #console.log "warming cache"
      parse_cache[schema] = JSON.parse "#{fs.readFileSync schema}" # !toString
  else
    schema

###
private function, used to parse a CSV row
TODO FIXME rename to something like parseCSVRow?
###
parse = (schema, row) ->

  columns = []

  columns = csvString.parse(row)[0]

  if columns.length > schema.length
    throw "invalid columns length (#{columns.length}), does not match schema (#{schema.length})"

  facts = {}

  for i in [0...columns.length]
    #console.log schema[i]
    # No type defined
    if isString schema[i]
      #console.log schema[i]
      facts[schema[i]] = columns[i]
      continue


    if schema[i].length is 1
      facts[schema[i][0]] = columns[i]

      continue

    [key,values] = schema[i]

    unless values
      facts[key] = columns[i]
      continue

    if isString values

      if values is "Number"
        facts[key] = (Number) columns[i]
        #console.log "casted to "+facts[key]
      else if values is "Boolean"
        facts[key] = (Boolean) columns[i]

      else if values is "String"
        facts[key] = "#{columns[i]}"

      else if values is "Symbol"
        facts[key] = "#{columns[i]}"

      else
        throw "unrecognized type '#{values}'"

    else
      if columns[i] of values
        facts[key] = values[columns[i]]
      else
        facts[key] = columns[i]

  facts

exports.parseOne = parseOne = (schema, row) ->
  schema = loadSchema schema
  parse schema, row

exports.parseMany = parseMany = (schema, rows) ->
  schema = loadSchema schema
  for row in rows
    parse schema, row


###
Loads a JSON file

TODO FIXME This function is a bit of a callback hell!
###
exports.loadJSON = loadJSON = (filePath, cb) ->
  execDir = process.cwd()


  execPath =  execDir + '/' + filePath

  scriptPath = undefined
  if process.argv.length > 1
    scriptDir = process.argv[1].split('/')[0...-1].join('/')
    scriptPath = scriptDir + '/' + filePath

  _load = (file) ->
    if cb?
     JSON.parse fs.readFile file, 'UTF-8', (err, data) ->
        throw err if err
        cb JSON.parse data
    else
      return JSON.parse fs.readFileSync file, 'UTF-8'

  if cb?
    fs.exists filePath, (exists) ->
      if exists
        return _load filePath

      fs.exist execPath, (exists) ->
        if exists
          return _load execPath

          unless scriptPath
            throw "couldn't find file"

          fs.exists scriptPath, (exists) ->
            if exists
              return _load scriptPath
            else
              throw "couldn't find file"


  else
    if fs.existsSync filePath
      return _load filePath

    if fs.existsSync execPath
      return _load execPath

    unless scriptPath
      throw "couldn't find file"

    if fs.existsSync scriptPath
      return _load scriptPath

    return {}

###
Load a CSV file, from a filepath

This function assumes rows have '\n' line returns
###
exports.loadCSV = loadCSV = (filePath) ->
  # init the event parser
  dataset = []
  for row in fs.readFileSync(filePath).toString().split("\n")
    if row.length
      dataset.push row
  dataset

###
Shuffle an Array
###
exports.shuffle = deck.shuffle

###
TODO FIXME OBSOLETE
###
exports.randomizeCSV = randomizeCSV = (filePath) ->
  # init the event parser
  dataset = loadCSV filePath
  deck.shuffle dataset

###
High-level function, to load a dataset (eg. CSV) using a schema,
with optional "from" and "to" indexes, used like this: array[from...to]
###
exports.dataset = dataset = (uri, schema, from, to) ->
  data = loadCSV uri

  splice = if from and to
      data[from...to]
    else if from
      data[from...]
    else if to
      data[...to]
    else
      data

  parseMany schema, splice
