_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"
errors = require "../errors"
Task = require "../Task"

class ActivityTask extends Task
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      worker: Function
    super
  execute: -> throw new Error("Implement me!")

module.exports = ActivityTask