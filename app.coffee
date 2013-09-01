
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
{register, doRegister} = require './routes/register'
{login, doLogin} = require './routes/login'
flash = require 'connect-flash'
http = require("http")
path = require("path")
app = express()
passport = require 'passport'
User = require './core/user'
LocalStrategy = require('passport-local').Strategy
db = require './core/db'
packageMeta = require './package'
md = require('node-markdown').Markdown

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

app.use flash()

app.use express.favicon __dirname + '/public/favicon.png'
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("SOMESECRET")
app.use express.session
  secret: "SOMESECRET"
app.use passport.initialize()
app.use passport.session()
app.use require("stylus").middleware(__dirname + "/public")
app.use express.static(path.join(__dirname, "public"))
app.use app.router

passport.use new LocalStrategy  (username, password, done) ->
  console.log "LocalStrategy invoked"
  User.getByUserPass username, password, done


passport.serializeUser (user, done) ->
  done null, user._id.toString()

passport.deserializeUser (id, done) ->
  User.getByID id, done


# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.locals
  version: packageMeta.version

app.get "/", (req, res) ->
  if req.user
    res.render 'dash',
      user: req.user
      title: req.user.username+"'s dash"
  else
    res.render 'index',
      title: 'home'
app.get "/users", user.list
app.get "/register", register
app.post "/register", doRegister
app.get "/login", login
app.post "/login", passport.authenticate('local', { successRedirect:'/',failureRedirect: '/fail' })

app.get "/logout", (req, res) ->
  req.logout()
  res.render 'index'

require('./routes/frontmatter') app


app.get '*', (req, res) ->
  res.render '404',
    title: '404'

db.connect ->
  http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")
