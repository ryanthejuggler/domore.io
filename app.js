// Generated by CoffeeScript 1.6.2
/*
Module dependencies.
*/


(function() {
  var LocalStrategy, User, app, db, doLogin, doRegister, express, flash, http, login, md, packageMeta, passport, path, register, routes, user, _ref, _ref1;

  express = require("express");

  routes = require("./routes");

  user = require("./routes/user");

  _ref = require('./routes/register'), register = _ref.register, doRegister = _ref.doRegister;

  _ref1 = require('./routes/login'), login = _ref1.login, doLogin = _ref1.doLogin;

  flash = require('connect-flash');

  http = require("http");

  path = require("path");

  app = express();

  passport = require('passport');

  User = require('./core/user');

  LocalStrategy = require('passport-local').Strategy;

  db = require('./core/db');

  packageMeta = require('./package');

  md = require('node-markdown').Markdown;

  app.set("port", process.env.PORT || 3000);

  app.set("views", __dirname + "/views");

  app.set("view engine", "jade");

  app.use(flash());

  app.use(express.favicon(__dirname + '/public/favicon.png'));

  app.use(express.logger("dev"));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(express.cookieParser("SOMESECRET"));

  app.use(express.session({
    secret: "SOMESECRET"
  }));

  app.use(passport.initialize());

  app.use(passport.session());

  app.use(require("stylus").middleware(__dirname + "/public"));

  app.use(express["static"](path.join(__dirname, "public")));

  app.use(app.router);

  passport.use(new LocalStrategy(function(username, password, done) {
    console.log("LocalStrategy invoked");
    return User.getByUserPass(username, password, done);
  }));

  passport.serializeUser(function(user, done) {
    return done(null, user._id.toString());
  });

  passport.deserializeUser(function(id, done) {
    return User.getByID(id, done);
  });

  if ("development" === app.get("env")) {
    app.use(express.errorHandler());
  }

  app.locals({
    version: packageMeta.version,
    timeago: require('timeago')
  });

  app.get("/", function(req, res) {
    if (req.user) {
      return res.render('dash', {
        user: req.user,
        title: req.user.username + "'s dash"
      });
    } else {
      return res.render('index', {
        title: 'home'
      });
    }
  });

  app.get("/users", user.list);

  app.get("/register", register);

  app.post("/register", doRegister);

  app.get("/login", login);

  app.post("/login", passport.authenticate('local', {
    successRedirect: '/',
    failureRedirect: '/fail'
  }));

  app.get("/logout", function(req, res) {
    req.logout();
    return res.render('index');
  });

  require('./routes/frontmatter')(app);

  require('./routes/snippets')(app);

  app.get('*', function(req, res) {
    return res.render('404', {
      title: '404'
    });
  });

  db.connect(function() {
    return http.createServer(app).listen(app.get("port"), function() {
      return console.log("Express server listening on port " + app.get("port"));
    });
  });

}).call(this);
