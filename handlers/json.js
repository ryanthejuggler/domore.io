// Generated by CoffeeScript 1.6.2
(function() {
  module.exports = function(entry) {
    var data, hashtags, re, tag;

    tag = entry.match(/[\w-]+/);
    tag = tag[0];
    entry = '{' + entry.substr(tag.length).trim() + '}';
    re = /\:\s*(?![."\s])((?:[^{}[\]",]+)\s*)(?=[,}]|$)/g;
    entry = entry.replace(re, ':"$1"');
    hashtags = [];
    entry = entry.replace(/([{,]\s*)([\w-]+)\:/g, function(whole, $1, $2) {
      return $1 + '"' + $2 + '":';
    });
    re = /#(\w+)\s*([,}]|$)/g;
    entry = entry.replace(re, function(whole, tag, tail) {
      hashtags.push(tag);
      return '"' + tag + '":true' + tail;
    });
    data = JSON.parse(entry);
    return [tag, data, hashtags];
  };

}).call(this);
