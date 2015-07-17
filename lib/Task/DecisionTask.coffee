_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"
errors = require "../errors"
Task = require "../Task"

class DecisionTask extends Task
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      events: [Object]
    super
  execute: ->
    @decisions = []
    @modifier = {}
    for event in @events
      if @[event.eventType]
        @[event.eventType](event)
      else
        throw new errors.EventHandlerNotImplementedError
          message: "Event handler '#{event.eventType}' not implemented"
          event: event
    if not @decisions.length
      throw new errors.NoDecisionsError
        event: event
  # default noops, can be implemented by child class if necessary
  DecisionTaskScheduled: (event) ->
  DecisionTaskStarted: (event) ->
  ActivityTaskStarted: (event) ->

module.exports = DecisionTask