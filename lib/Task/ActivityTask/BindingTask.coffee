_ = require "underscore"
Promise = require "bluebird"
errors = require "../../../../helper/errors"
Match = require "mtr-match"
ActivityTask = require "../ActivityTask"

class BindingTask extends ActivityTask
  constructor: (input, options, streams, dependencies) ->
    Match.check input, Match.ObjectIncluding
      avatarId: String
    super
    Match.check @mongodb, Match.Any
    @binding = @createBinding()

  acquireCredential: ->
    api = @binding.api
    scopes = @binding.scopes
    Promise.bind(@)
    .then -> @mongodb.collection("Credentials").findOne(
      api: api
      scopes: {$all: scopes}
    )
    .then (credential) ->
      throw new errors.RuntimeError(
        message: "Can't find #{api} credential for scopes \"#{scopes}\""
        api: api
        scopes: scopes
      ) unless credential
      @binding.setCredential(credential)
      @binding

  createBinding: -> throw new Error("Implement me!")

module.exports = BindingTask
