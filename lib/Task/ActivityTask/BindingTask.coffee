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
    @binding = @createBinding()

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
      @binding

  createBinding: -> throw new Error("Implement me!")

module.exports = BindingTask
