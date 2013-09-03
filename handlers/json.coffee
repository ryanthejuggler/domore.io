
module.exports = (entry) ->
  tag = entry.match /\w+/
  tag = tag[0]
  entry = '{' + entry.substr(tag.length).trim() + '}'
  re = /\:\s*(?![."\s\d])([^{}[\]",]+)\s*(?=[,}]|$)/g
  entry = entry.replace re, ':"$1"'
  hashtags = []
  entry = entry.replace /
  entry = entry.replace /([{,]\s*)(\w+)\:/g, (whole, $1, $2) ->
    return $1 + '"' + $2 + '":'
  re = /#(\w+)\s*([,}]|$)/g
  entry = entry.replace
  data = JSON.parse entry, (whole, tag, tail) ->
    hashtags.push tag
    tag+":true"+tail
  return [tag, data, hashtags]