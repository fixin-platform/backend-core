_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
errors = require "../../helper/errors"
Task = require "../Task"

class DecisionTask extends Task
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      events: [Object]
    super
  execute: ->
    new Promise (resolve, reject) =>
      try
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
      catch error
        reject error
      resolve()
  # default noops, can be implemented by child class if necessary
  DecisionTaskScheduled: (event) ->
  DecisionTaskStarted: (event) ->
  DecisionTaskCompleted: (event) ->
  ActivityTaskScheduled: (event) ->
  ActivityTaskStarted: (event) ->

module.exports = DecisionTask