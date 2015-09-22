_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
requestAsync = Promise.promisify(require "request")
errors = require "../helper/errors"

module.exports = class Binding
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      api: String
      scopes: [String]
    _.extend @, options

  request: (options) -> requestAsync(options)

  setCredential: (credential) -> @credential = credential

  checkStatusCode: (response, body) ->
    if response.statusCode >= 400
      throw new errors.RuntimeError
        response: response.toJSON() # important: always call toJSON()
        body: body
    [response, body]

