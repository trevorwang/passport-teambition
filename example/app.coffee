express = require('express')
passport = require('passport')
util = require('util')
GitHubStrategy = require('../src').Strategy
GITHUB_CLIENT_ID = '88fc4f30-983a-11e5-a51a-f5a1e8cbbcce'
GITHUB_CLIENT_SECRET = 'f01b0f2f-947a-467b-ad41-dcae8fe6ed7c'
# Passport session setup.
#   To support persistent login sessions, Passport needs to be able to
#   serialize users into and deserialize users out of the session.  Typically,
#   this will be as simple as storing the user ID when serializing, and finding
#   the user by ID when deserializing.  However, since this example does not
#   have a database of user records, the complete GitHub profile is serialized
#   and deserialized.
# Simple route middleware to ensure user is authenticated.
#   Use this route middleware on any resource that needs to be protected.  If
#   the request is authenticated (typically via a persistent login session),
#   the request will proceed.  Otherwise, the user will be redirected to the
#   login page.

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/login'
  return

passport.serializeUser (user, done) ->
  done null, user
  return
passport.deserializeUser (obj, done) ->
  done null, obj
  return
# Use the GitHubStrategy within Passport.
#   Strategies in Passport require a `verify` function, which accept
#   credentials (in this case, an accessToken, refreshToken, and GitHub
#   profile), and invoke a callback with a user object.
passport.use new GitHubStrategy({
  clientID: GITHUB_CLIENT_ID
  clientSecret: GITHUB_CLIENT_SECRET
  callbackURL: 'http://localhost:3000/auth/github/callback'
}, (accessToken, refreshToken, profile, done) ->
  # asynchronous verification, for effect...
  process.nextTick ->
    # To keep the example simple, the user's GitHub profile is returned to
    # represent the logged-in user.  In a typical application, you would want
    # to associate the GitHub account with a user record in your database,
    # and return that user instead.
    done null, profile
  return
)
app = express.createServer()
# configure Express
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session(secret: 'keyboard cat')
  # Initialize Passport!  Also use passport.session() middleware, to support
  # persistent login sessions (recommended).
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use express.static(__dirname + '/public')
  return
app.get '/', (req, res) ->
  res.render 'index', user: req.user
  return
app.get '/account', ensureAuthenticated, (req, res) ->
  res.render 'account', user: req.user
  return
app.get '/login', (req, res) ->
  res.render 'login', user: req.user
  return
# GET /auth/github
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  The first step in GitHub authentication will involve redirecting
#   the user to github.com.  After authorization, GitHubwill redirect the user
#   back to this application at /auth/github/callback
app.get '/auth/github', passport.authenticate('teambition'), (req, res) ->
  # The request will be redirected to GitHub for authentication, so this
  # function will not be called.
  return
# GET /auth/github/callback
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  If authentication fails, the user will be redirected back to the
#   login page.  Otherwise, the primary route function function will be called,
#   which, in this example, will redirect the user to the home page.
app.get '/auth/github/callback', passport.authenticate('teambition', failureRedirect: '/login'), (req, res) ->
  res.redirect '/'
  return
app.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/'
  return
app.listen 3000
