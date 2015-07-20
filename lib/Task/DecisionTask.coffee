_ = require "underscore"
camelize = require "underscore.string/camelize"
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
        @barriers = {}
        @decisions = []
        @modifier = {}
        for event in @events
          if @[event.eventType]
            attributes = camelize(event.eventType, true) + "EventAttributes"
            console.log attributes
            input = JSON.parse event[attributes].input if event[attributes].input
            @[event.eventType](event, event[attributes], input)
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
  ActivityTaskStarted: (event) ->
  # default decisions
  ScheduleActivityTask: (activityTypeName, input) ->
    decisionType: "ScheduleActivityTask"
    scheduleActivityTaskDecisionAttributes:
      activityType:
        name: activityTypeName
        version: "1.0.0"
      activityId: activityTypeName
      input: JSON.stringify input
  # workflow helpers
  createBarrier: (name, obstacles) ->
    @barriers[name] = obstacles
  removeBarrierObstacle: (name, obstacle) ->
    @barriers[name] = _.without @barriers[name], obstacle
  isBarrierPassed: (name) ->
    not @barriers[name].length

module.exports = DecisionTask