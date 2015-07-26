_ = require "underscore"
camelize = require "underscore.string/camelize"
Promise = require "bluebird"
Match = require "mtr-match"
opath = require "object-path"
errors = require "../../helper/errors"
Task = require "../Task"

class DecisionTask extends Task
  constructor: (events, options, dependencies) ->
    Match.check events, [Object]
    super(options, dependencies)
    @events = events
  signature: -> ["taskToken", "workflowExecution", "workflowType"]
  execute: ->
    new Promise (resolve, reject) =>
      try
        @barriers = {}
        @decisions = []
        @modifiers = []
        for event in @events
          if @[event.eventType]
            attributes = _.deepClone @eventAttributes(event)
            input = (JSON.parse attributes.input if attributes.input) or undefined
            result = (JSON.parse attributes.result if attributes.result) or undefined
            @info "DecisionTask:processEvent", @details({event: event})
            @[event.eventType](event, attributes, input or result)
          else
            throw new errors.EventHandlerNotImplementedError
              message: "Event handler '#{event.eventType}' not implemented"
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
  ScheduleActivityTask: (activityShorthand, input) ->
    decisionType: "ScheduleActivityTask"
    scheduleActivityTaskDecisionAttributes:
      activityType:
        name: activityShorthand
        version: "1.0.0"
      activityId: activityShorthand
      input: JSON.stringify input
  # workflow helpers
  addDecision: (decision) ->
    @decisions.push decision
  removeDecision: (decisionType, query) ->
    index = @findIndex @decisions, _.extend
      decisionType: decisionType
    , query
    throw new errors.RuntimeError(
      message: "Can't find \"#{decisionType}\" decision to remove"
      query: query
    ) if not ~index
    @decisions.splice(index, 1)
  findIndex: (array, query) ->
    _.findIndex array, (element) ->
      for path, value of query
        return false unless opath.get(element, path) is value
      return true
  find: (array, query) ->
    index = @findIndex array, query
    array[index] if ~index
  attributesProperty: (name, suffix) -> camelize(name, true) + suffix
  eventAttributesProperty: (event) -> @attributesProperty(event.eventType, "EventAttributes")
  decisionAttributesProperty: (decision) -> @attributesProperty(decision.decisionType, "DecisionAttributes")
  eventAttributes: (event) -> event[@eventAttributesProperty(event)]
  decisionAttributes: (decision) -> decision[@decisionAttributesProperty(decision)]
  removeScheduleActivityTaskDecision: (activityId) ->
    @removeDecision "ScheduleActivityTask",
      "scheduleActivityTaskDecisionAttributes.activityId": activityId
  createBarrier: (name, obstacles) ->
    @barriers[name] = obstacles
  removeObstacle: (obstacle) ->
    for name, barrier of @barriers
      index = barrier.indexOf(obstacle)
      if ~index
        barrier.splice(index, 1)
        if not barrier.length and not barrier.isPassed
          barrier.isPassed = true
          @["#{name}BarrierPassed"]()

module.exports = DecisionTask