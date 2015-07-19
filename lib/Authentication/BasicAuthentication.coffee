_ = require "underscore"

module.exports = (credential, options) ->
  rawHeaderValue = credential.username + ":" + credential.password
  encryptedHeaderValue = new Buffer(rawHeaderValue).toString('base64')
  header = "Basic #{encryptedHeaderValue}"
  options.headers ?= {}
  options.headers["Authorization"] = header
