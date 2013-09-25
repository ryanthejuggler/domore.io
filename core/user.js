// Generated by CoffeeScript 1.6.2
(function() {
  var ObjectID, User, crypto, db;

  db = require('./Db');

  ObjectID = db.ObjectID;

  crypto = require('crypto');

  /**
    @class User
  */


  User = (function() {
    /** 
      @field name
      @field username
      @field providers
      @field profile
    */

    /**
      @constructor
    */
    function User(config) {
      if (config != null) {
        this._id = config._id, this.username = config.username, this.name = config.name, this.providers = config.providers, this.profile = config.profile, this.password = config.password, this.joined = config.joined;
      }
    }

    /** 
      @method setBasicsFromPassport
    */


    User.prototype.setBasicsFromPassport = function(profile) {
      return this.profile = profile;
    };

    /** 
      @method save
    */


    User.prototype.save = function(callback) {
      var user;

      user = {
        name: this.name,
        providers: this.providers,
        profile: this.profile,
        password: this.password,
        username: this.username
      };
      if (this._id) {
        user._id = this._id;
      }
      return db.collection('users', function(err, cxn) {
        return cxn.save(user, {
          safe: true
        }, function(err, user) {
          return callback(err, user);
        });
      });
    };

    return User;

  })();

  /**
    @method load
    @static
  */


  User.getByLogin = function(provider, id, callback) {
    return db.collection('users', function(err, cxn) {
      return cxn.findOne({
        'providers.$.provider': provider,
        'providers.$.id': id
      }, {
        safe: true
      }, function(err, userData) {
        return callback(err, new User(userData));
      });
    });
  };

  User.getByName = function(username, callback) {
    return db.collection('users', function(err, cxn) {
      return cxn.findOne({
        username: username
      }, {
        safe: true
      }, function(err, userData) {
        if (userData) {
          return callback(err, new User(userData));
        } else {
          return callback(err);
        }
      });
    });
  };

  User.getByUserPass = function(username, password, callback) {
    var md5;

    md5 = crypto.createHash('md5');
    password = md5.update(password).digest('base64');
    return db.collection('users', function(err, cxn) {
      return cxn.findOne({
        username: username,
        password: password
      }, {
        safe: true
      }, function(err, userData) {
        if (userData) {
          return callback(err, new User(userData));
        } else {
          return callback(err);
        }
      });
    });
  };

  User.getByID = function(id, callback) {
    return db.collection('users', function(err, cxn) {
      return cxn.findOne({
        _id: new ObjectID(id)
      }, function(err, userData) {
        if (userData) {
          return callback(err, new User(userData));
        } else {
          return callback(err);
        }
      });
    });
  };

  module.exports = User;

}).call(this);
