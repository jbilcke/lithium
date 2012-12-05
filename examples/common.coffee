request = require 'request'

pretty = (obj) -> "#{inspect obj, no, 20, yes}"
wait = (t) -> (f) -> setTimeout f, t
repeat = (t) -> (f) -> setInterval f, t
# "poor's man machine learning"


exports.extractLinks = extractLinks = (txt) ->
  urlRegex = /(https?:\/\/[^\s]+)/g
  results = []
  "#{txt}".replace urlRegex, (url) -> results.push url
  results

  # extract opengraph title + keywords from an html page
exports.extractData = extractData = (html) ->
  titleResults = html.match ///<meta\s+property="og:title"\s+content="([^"]*)"\s*/>///
  unless titleResults?
    titleResults = html.match ///<meta\s+name="title"\s+content="([^"]*)"\s*/>/// 
  title = if titleResults? then (titleResults[1] ? "") else ""
  title.replace('&amp;','&').replace('&nbsp;',' ')

  descriptionResults = html.match ///<meta\s+property="og:description"\s+content="([^"]*)"\s*/>///
  unless descriptionResults?
    descriptionResults = html.match ///<meta\s+name="description"\s+content="([^"]*)"\s*/>/// 
  description = if descriptionResults? then (descriptionResults[1] ? "") else ""
  description.replace('&amp;','&').replace('&nbsp;',' ')

  keywordsResults = html.match ///<meta\s+property="og:keywords"\s+content="([^"]*)"\s*/>/// 
  unless keywordsResults?
    keywordsResults = html.match ///<meta\s+name="keywords"\s+content="([^"]*)"\s*/>/// 
  keywords = if keywordsResults? then (keywordsResults[1] ? "") else ""
  keywords.replace('&amp;','&').replace('&nbsp;',' ')

  title: title
  description: description
  keywords: for k in keywords.split ','
    k.trim()

exports.openGraph = openGraph = (url, onComplete) ->
  #console.log "downloading #{url}"
  request url, (error, response, body) ->
    if error
      console.log "couldn't download #{url}"
    onComplete extractData (body ? '')