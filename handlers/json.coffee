
module.exports = (entry) ->
  tag = entry.match /\w+/
  tag = tag[0]
  entry = '{' + entry.substr(tag.length).trim() + '}'
  entry = entry.replace /([{,]\s*)(\w+)\:/g, (whole, $1, $2) ->
    return $1 + '"' + $2 + '":'
  data = JSON.parse entry
  return [tag, data]