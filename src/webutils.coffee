

exports.extractLinks = extractLinks = (txt) ->
  urlRegex = /(https?:\/\/[^\s]+)/g
  results = []
  "#{txt}".replace urlRegex, (url) -> results.push url
  results

  # extract opengraph title from an html page
exports.extractTitle = extractTitle = (html) ->

  pattern = ///<title>([^<]*)</title>///  
  
  # og:title
  #pattern = ///<meta\s+property="og:title"\s+content="([^"]*)"\s*/>///

  results = html.match pattern
  title = if results? then (results[1] ? "") else ""
  title.replace('&amp;','&').replace('&nbsp;',' ')


############################
# GET TITLE FROM A WEBSITE #
############################
exports.fetchTitle = fetchTitle = (url, onComplete) ->

  request = ->
  try
    request = require 'request'
  catch e
    throw new Error "Youneed to install node-request before using fetchTitle"
  console.log "downloading #{url}"
  request url, (error, response, body) ->
    if error
      console.log "couldn't download #{url}"
    onComplete extractTitle (body ? '')

