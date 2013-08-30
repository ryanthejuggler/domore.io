settings = require './dbconfig.json'
{MongoClient, ObjectID} = require 'mongodb'

db = {}

connect = exports.connect = (next) ->
  MongoClient.connect 'mongodb://'+settings.host+':'+settings.port+'/'+settings.db, (err, _db) ->
    db = _db
    next err, db

collection = exports.collection = (cx, next) ->
  db.collection cx, next

exports.ObjectID = ObjectID