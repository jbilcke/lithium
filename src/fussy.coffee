fs = require 'fs'
path = require 'path'

utils = require './utils'
text = require './text'
bench = require './bench'
extract = require './extract'


debug = (msg) -> console.log msg

###
The main Fussy class

TODO add more comments and documentation
###
class Fussy

  constructor: (@objects=[]) ->


    #@tag = text.ngramize
    @toolbox =
      parseOne: utils.parseOne
      parseMany: utils.parseMany
      randomizeCSV: utils.randomizeCSV
      loadCSV: utils.loadCSV
      pperf: utils.pperf
      pstats: utils.pstats

      dataset: utils.dataset
      shuffle: utils.shuffle

      bench: bench

  ###
  TODO: take a param in account?
  ###
  repair: (objects) ->
    unless objects?
      objects = @objects

    schema = {}
    for obj in objects
      for key, value of obj
        schema[key] = on

    results = for obj in objects

      # construct the request
      query =
        objects: objects
        select: []
        where: {}

      for key, value of schema
        if key of obj
          query.where[key] = obj[key]
        else
          query.select.push key

      repaired = {}

      for key, value of obj
        repaired[key] = value

      for key, value of @query(query).best()
        repaired[key] = value

      repaired

    results

  ###
  Load an object into the memory
  ###
  insert: (data) ->

    if utils.isArray data
      for obj in data
        @objects.push obj

    else if utils.isString data
      @insert utils.loadJSON data

    else
      @objects.push data

    @

  ###
  This helper should probably be deleted
  ###
  import: (file, schema) ->
    @insert utils.parseMany schema, utils.loadCSV file

  ###
  Executes a query

  TODO clean this function, it is too complicated (callback hell)
  ###
  query: (query) ->
    #debug "QUERY: " + pretty query
    #debug pretty @objects

    _executeJob = =>
      result = {}
      types = {}

      if utils.isString query.select
        tmp = {}
        tmp[query.select] = []
        query.select = tmp

      unless utils.isArray query.where
        query.where = [ query.where ]

      unless query.objects?
        query.objects = @objects

      for obj in query.objects

        features = extract obj

        weight = 0
        factors = []

        nb_feats = 0

        MAGIC = 2

        for where in query.where
          depth = 0
          complexity = 0

          for [type, key, value] in features

            if key of where

              whereValues = if utils.isArray where[key]
                  where[key]
                else
                  [where[key]]

              match = no
              for whereValue in whereValues

                switch type
                  when 'String'
                    value = "#{value}"
                    whereValue = "#{whereValue}"
                    if ' ' in value or ' ' in whereValue
                      [_depth,_nb_feats] = text.distance value, whereValue
                      depth += _depth
                      nb_feats += _nb_feats
                      match = yes
                    else
                      if value is whereValue
                        depth += 1
                        match = yes

                  when 'Number'
                    whereValue = (Number) whereValue
                    if !isNaN(whereValue) and isFinite(whereValue)
                      delta = Math.abs value - whereValue
                      # bad performance if we use 2/1 on sonar dataset
                      depth += 1 / (1 + delta)
                      match = yes


                  when 'Boolean'
                    if ((Boolean) value) is ((Boolean) whereValue)
                      depth += 1
                      match = yes

                  else
                    console.log "type #{type} not supported"

              if match
                nb_feats += 1

          # these parameters depends on the plateform
          depth *= Math.min 6, 300 / nb_feats
          weight += 10 ** Math.min 300, depth

        for [type, key, value] in features
          #debug "key: "+key

          continue unless key of query.select

          unless key of types
            types[key] = type

          # TODO put the 4 following lines before the "continue unless"
          # if you want to catch all results
          unless key of result
            result[key] = {}

          unless value of result[key]
            result[key][value] = 0


          #debug "match for #{key}: #{query.select[key]}"

          match = no
          if utils.isArray query.select[key]
            #debug "array"
            if query.select[key].length
              if value in query.select[key]
                #debug "SELECT match in array!"
                match = yes
            else
              #debug "empty"
              match = yes
          else
            #debug "not array"
            if value is query.select[key]
              #debug "SELECT match single value!"
              match = yes

          if match
            result[key][value] += weight

      options: result
      types: types

    sort = (fn, cb) =>
      result = {}
      {options, types} = _executeJob()

      for key, options of options
        result[key] = []
        for option, weight of options
          if types[key] is 'Number'
            option = (Number) option
          else if types[key] is 'Boolean'
            option = (Boolean) option
          result[key].push [option, weight]
        result[key].sort fn

      if cb?
        cb result
        undefined
      else
        result

    all = (cb) =>

      fn =  (a,b) -> b[1] - a[1]
      sort fn, cb

    best = =>
      result = {}
      for key, options of all()
        result[key] = options[0][0] # first element of the first entry in the array

      if cb?
        cb result
        undefined
      else
        result

    toString: => utils.pretty all()

    mix = =>

      result = {}
      {options, types} = _executeJob()

      for key, options of options
        isNumerical = types[key] is 'Number'

        if utils.isNumerical

          sum = 0
          for option, weight of options
            sum += weight

          result[key] = 0
          for option, weight of options
            option = (Number) option
            result[key] += option * (weight / sum)

        else
          result[key] = []
          for option, weight of options
            if types[key] is 'Boolean'
              option = (Boolean) option
            result[key].push [option, weight]
          result[key].sort (a,b) -> b[1] - a[1]
          best = result[key][0] # get the best
          result[key] = best[0] # get the value

      if cb?
        cb result
        undefined
      else
        result

    {sort, all, best, mix, toString}

module.exports = Fussy
