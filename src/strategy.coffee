###*
# Module dependencies.
###

util = require('util')
OAuth2Strategy = require('passport-oauth2')
Profile = require('./profile')
InternalOAuthError = require('passport-oauth2').InternalOAuthError

###*
# Inherit from `OAuth2Strategy`.
###

###*
# `Strategy` constructor.
#
# The teambition authentication strategy authenticates requests by delegating to
# teambition using the OAuth 2.0 protocol.
#
# Applications must supply a `verify` callback which accepts an `accessToken`,
# `refreshToken` and service-specific `profile`, and then calls the `done`
# callback supplying a `user`, which should be set to `false` if the
# credentials are not valid.  If an exception occured, `err` should be set.
#
# Options:
#   - `clientID`      your teambition application's Client ID
#   - `clientSecret`  your teambition application's Client Secret
#   - `callbackURL`   URL to which teambition will redirect the user after granting authorization
#   - `scope`         array of permission scopes to request.  valid scopes include:
#                     'user', 'public_repo', 'repo', 'gist', or none.
#                     (see http://developer.teambition.com/v3/oauth/#scopes for more info)
#   — `userAgent`     All API requests MUST include a valid User Agent string.
#                     e.g: domain name of your application.
#                     (see http://developer.teambition.com/v3/#user-agent-required for more info)
#
# Examples:
#
#     passport.use(new teambitionStrategy({
#         clientID: '123-456-789',
#         clientSecret: 'shhh-its-a-secret'
#         callbackURL: 'https://www.example.net/auth/teambition/callback',
#         userAgent: 'myapp.com'
#       },
#       function(accessToken, refreshToken, profile, done) {
#         User.findOrCreate(..., function (err, user) {
#           done(err, user);
#         });
#       }
#     ));
#
# @param {Object} options
# @param {Function} verify
# @api public
###

Strategy = (options, verify) ->
  options = options or {}
  options.authorizationURL = options.authorizationURL or 'https://account.teambition.com/oauth2/authorize'
  options.tokenURL = options.tokenURL or 'https://account.teambition.com/oauth2/access_token'
  options.scopeSeparator = options.scopeSeparator or ','
  options.customHeaders = options.customHeaders or {}
  if !options.customHeaders['User-Agent']
    options.customHeaders['User-Agent'] = options.userAgent or 'passport-teambition'
  OAuth2Strategy.call this, options, verify
  @name = 'teambition'
  @_userProfileURL = options.userProfileURL or 'https://api.teambition.com/users/me'
  @_oauth2.useAuthorizationHeaderforGET true
  @_oauth2._authMethod = 'OAuth2'
  return

util.inherits Strategy, OAuth2Strategy

###*
# Retrieve user profile from teambition.
#
# This function constructs a normalized profile, with the following properties:
#
#   - `provider`         always set to `teambition`
#   - `id`               the user's teambition ID
#   - `username`         the user's teambition username
#   - `displayName`      the user's full name
#   - `profileUrl`       the URL of the profile for the user on teambition
#   - `emails`           the user's email addresses
#
# @param {String} accessToken
# @param {Function} done
# @api protected
###

Strategy::userProfile = (accessToken, done) ->
  @_oauth2.get @_userProfileURL, accessToken, (err, body, res) ->
    json = undefined
    if err
      return done(new InternalOAuthError('Failed to fetch user profile', err))
    try
      json = JSON.parse(body)
    catch ex
      return done(new Error('Failed to parse user profile'))
    profile = Profile.parse(json)
    profile.provider = 'teambition'
    profile._raw = body
    profile._json = json
    done null, profile
    return
  return

###*
# Expose `Strategy`.
###

module.exports = Strategy
