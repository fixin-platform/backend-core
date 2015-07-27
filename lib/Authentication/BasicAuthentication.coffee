_ = require "underscore"

module.exports = (details, options) ->
  rawHeaderValue = details.username + ":" + details.password
  encryptedHeaderValue = new Buffer(rawHeaderValue).toString('base64')
  header = "Basic #{encryptedHeaderValue}"
  options.headers ?= {}
  options.headers["Authorization"] = header
