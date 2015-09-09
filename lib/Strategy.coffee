_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"

class Strategy
  constructor: (options, dependencies) ->
    _.extend @, options
    @listeners = {}
    # trigger getters
    @logger = dependencies.logger
    Match.check @logger, Match.Any
    log = @log
    @logger.extend @
    @log = log
  details: (details) -> _.defaults details, _.pick(@, @signature())
  signature: -> throw new Error("Implement me!")

  on: (event, handler) ->
    @listeners[event] ?= []
    @listeners[event].push handler

  emit: (event, args...) ->
    return Promise.resolve() unless @listeners[event]?.length
    Promise.all(listener(args...) for listener in @listeners[event])

module.exports = Strategy
