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
  profile.username = json.email or json.name
  if json.email
    profile.emails = [{ value: json.email }]
  profile
