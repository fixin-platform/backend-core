_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
AWS = require "aws-sdk"
winston = require "winston"

class Actor
  constructor: (options, dependencies) ->
    Match.check dependencies,
      swf: AWS.SWF
      logger: winston.Logger
    _.extend @, options
    _.extend @, dependencies

module.exports = Actor