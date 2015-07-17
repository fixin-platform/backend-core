_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"
errors = require "./errors"

class Task
  constructor: (options) ->
    _.extend @, options

module.exports = Task