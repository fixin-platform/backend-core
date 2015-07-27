_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"

class Task
  constructor: (options, dependencies) ->
    _.extend @, options
    # trigger getters
    @logger = dependencies.logger
    Match.check @logger, Match.Any
    log = @log
    @logger.extend @
    @log = log
  details: (details) -> _.defaults details, _.pick(@, @signature())
  signature: -> throw new Error("Implement me!")

module.exports = Task