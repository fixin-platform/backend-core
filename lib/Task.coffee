_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"

class Task
  constructor: (options, dependencies) ->
    _.extend @, options
    for name in Object.getOwnPropertyNames(dependencies)
      @[name] = dependencies[name] # trigger getters
    Match.check @logger, Match.Any
    log = @log
    @logger.extend @
    @log = log
  details: (details) -> _.defaults details, _.pick(@, @signature())
  signature: -> throw new Error("Implement me!")

module.exports = Task