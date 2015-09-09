_ = require "underscore"
Promise = require "bluebird"
errors = require "../../../helper/errors"
Match = require "mtr-match"
Strategy = require "../Strategy"
Binding = require "../../lib/Binding"

class APIStrategy extends Strategy
  constructor: (input, dependencies) ->
    Match.check input, Match.ObjectIncluding
      avatarId: String
    @binding = @createBinding()
    @mongodb = dependencies.mongodb
    Match.check @mongodb, Match.Any
    super

  execute: (input) ->
    Promise.bind(@)
    .then

  acquireCredential: (avatarId) ->
    selector =
      avatarId: avatarId
      api: @binding.api
      scopes: {$all: @binding.scopes}
    Promise.bind(@)
    .then -> @mongodb.collection("Credentials").findOne(selector)
    .then (credential) ->
      throw new errors.RuntimeError(
        message: "Can't find API credential"
        selector: selector
      ) unless credential
      @binding.setCredential(credential)
      @binding

  createBinding: ->

module.exports = APIStrategy
