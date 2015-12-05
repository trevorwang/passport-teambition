###*
# Parse profile.
#
# @param {Object|String} json
# @return {Object}
# @api private
###

exports.parse = (json) ->
  if 'string' == typeof json
    json = JSON.parse(json)
  profile = {}
  profile.id = json._id
  profile.displayName = json.name
  profile.username = json.name
  profile.email = json.email
  profile.emails = json.emails
  profile
