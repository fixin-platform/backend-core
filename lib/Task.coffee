_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
winston = require "winston"

class Task
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      logger: winston.Logger
    _.extend @, options, dependencies
    log = @
    dependencies.logger.extend @
    @log = log
  details: (details) -> _.defaults details, _.pick(@, @signature())
  signature: -> throw new Error("Implement me!")

module.exports = Task