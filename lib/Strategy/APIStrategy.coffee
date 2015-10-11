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

    @mongodb = dependencies.mongodb
    @redis = dependencies.redis
    Match.check @mongodb, Match.Any
    Match.check @redis, Match.Any

    super
    @binding ?= @createBinding()

  acquireCredential: ->
    selector =
      avatarId: @avatarId
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

  createBinding: -> throw new Error("Implement me!")

module.exports = APIStrategy
