_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
requestAsync = Promise.promisify(require "request")

module.exports = class Binding
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      api: String
      scopes: [String]
    _.extend @, options
    @requestAsync = requestAsync

  request: (options) -> @requestAsync(options)

  setCredential: (credential) -> @credential = credential
