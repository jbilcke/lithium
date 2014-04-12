utils = require './utils'

###
Extract features from a JSON object
###
extract = (event, facts=[], prefix="") ->



  ###
  This was supposed to be a built-in support for a "date" attribute
  TODO but it is a bit awkward: we should rather use the schema for that.
  let's disable it for now.
  ###
  #if facts.length is 0
  #  if event.date?
  #    facts.push ['Date', 'date', moment(event.date).format()]
  #    delete event['date']


  for key, value of event

    key = prefix + key

    # TODO we should use in priority the schema for this, then only detect type
    # as a fallback

    if utils.isString value
      facts.push ['String', key, value]

    else if utils.isArray value
      facts.push ['Array', key, value]

    else if utils.isNumber value
      facts.push ['Number', key, value]

    else if utils.isBoolean value
      facts.push ['Boolean', key, value]

    else
      extract value, facts, key + "." # recursively flatten nested features

  facts

module.exports = extract
