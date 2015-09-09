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
    Match.check(event, String)
    Match.check(handler, Function)
    @listeners[event] ?= []
    @listeners[event].push handler

  emit: (event, args...) ->
    Match.check(event, String)
    return Promise.resolve() unless @listeners[event]?.length
    Promise.all(listener(args...) for listener in @listeners[event])

module.exports = Strategy
