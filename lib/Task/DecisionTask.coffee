_ = require "underscore"
_.mixin require "underscore.deep"
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
        @updates = []
        for event in @events
          @info "DecisionTask:processEvent", @details({event: event})
          if @[event.eventType]
            attributes = _.deepClone @eventAttributes(event)
            args = [event, attributes]
            input = (JSON.parse attributes.input if attributes.input) or undefined
            result = (JSON.parse attributes.result if attributes.result) or undefined
            executionContext = (JSON.parse attributes.executionContext if attributes.executionContext) or undefined
            freeform = input or result or executionContext
            args.push freeform if freeform
            if attributes.scheduledEventId
              scheduledEvent = @find @events,
                eventId: attributes.scheduledEventId
              scheduledAttributes = @eventAttributes(scheduledEvent)
              args.push scheduledEvent, scheduledAttributes
            if attributes.startedEventId
              startedEvent = @find @events,
                eventId: attributes.startedEventId
              startedAttributes = @eventAttributes(startedEvent)
              args.push startedEvent, startedAttributes
            if event.eventType is "WorkflowExecutionStarted"
              @input = input
              @results = {}
            @[event.eventType].apply(@, args)
          else
            throw new errors.EventHandlerNotImplementedError
              message: "Event handler '#{event.eventType}' not implemented"
              event: event
        @executionContext = JSON.stringify
          updates: @updates
      catch error
        if error.message is "WorkflowExecutionCancelRequested"
          @barriers = {}
          @decisions = []
          @updates = []
          @addDecision @CancelWorkflowExecution({})
        else
          reject error
      resolve()

  # default handlers (can be overridden by child class)
  DecisionTaskScheduled: (event, attributes) -> # noop

  DecisionTaskStarted: (event, attributes) -> # noop

  DecisionTaskCompleted: (event, attributes, executionContext) ->
    @removeUpdate update for update in executionContext.updates

  DecisionTaskTimedOut: (event, attributes) -> # noop
    # We shouldn't re-schedule the decision task, because SWF has already re-scheduled it
    @info "DecisionTask:DecisionTaskTimedOut", @details({event: event, attributes: attributes})

  ActivityTaskStarted: (event, attributes) -> # noop

  ActivityTaskScheduled: (event, attributes, input) ->
    @removeScheduleActivityTaskDecision attributes.activityId

  ActivityTaskCompleted: (event, attributes, result, scheduledEvent, scheduledAttributes, startedEvent, startedAttributes) ->
    @results[scheduledAttributes.activityId] = result
    @removeObstacle scheduledAttributes.activityId

  ActivityTaskFailed: (event, attributes, scheduledEvent, scheduledAttributes, startedEvent, startedAttributes) ->
    @addDecision @FailWorkflowExecution attributes.reason, attributes.details

  ActivityTaskTimedOut: (event, attributes, scheduledEvent, scheduledAttributes, startedEvent, startedAttributes) ->
    @addDecision @FailWorkflowExecution "Activity task timed out",
      activityId: scheduledAttributes.activityId
      timeoutType: attributes.timeoutType
      lastHeartbeatDetails: attributes.details

  WorkflowExecutionCancelRequested: (event, attributes) ->
    throw new Error("WorkflowExecutionCancelRequested")

  # default decisions
  ScheduleActivityTask: (activityShorthand, input) ->
    decisionType: "ScheduleActivityTask"
    scheduleActivityTaskDecisionAttributes:
      activityType:
        name: activityShorthand
        version: "1.0.0"
      activityId: activityShorthand
      input: JSON.stringify input

  FailWorkflowExecution: (reason, details) ->
    decisionType: "FailWorkflowExecution"
    failWorkflowExecutionDecisionAttributes:
      reason: reason
      details: JSON.stringify details

  CompleteWorkflowExecution: (result) ->
    decisionType: "CompleteWorkflowExecution"
    completeWorkflowExecutionDecisionAttributes:
      result: JSON.stringify result

  CancelWorkflowExecution: (details) ->
    decisionType: "CancelWorkflowExecution"
    cancelWorkflowExecutionDecisionAttributes:
      details: JSON.stringify details

  # workflow helpers
  addDecision: (decision) ->
    if not @decisions.length and not @commandSetIsStartedUpdateAdded
      @commandSetIsStartedUpdateAdded = true # unelegant, but let's stick with that
      @addUpdate @commandSetIsStarted @input.commandId
    @decisions.push decision
    if decision.decisionType is "CompleteWorkflowExecution"
      @addUpdate @commandSetIsCompleted @input.commandId
      @addUpdate @commandSetResult @input.commandId, JSON.parse decision.completeWorkflowExecutionDecisionAttributes.result
    if decision.decisionType is "FailWorkflowExecution"
      @addUpdate @commandSetIsFailed @input.commandId
  removeDecision: (decisionType, query) ->
    index = @findIndex @decisions, _.extend
      decisionType: decisionType
    , query
    throw new errors.RuntimeError(
      message: "Can't find \"#{decisionType}\" decision to remove"
      query: query
    ) if not ~index
    @decisions.splice(index, 1)
  addUpdate: (update) ->
    @updates.push update
  removeUpdate: (updateBlueprint) ->
    index = @findIndex @updates, (update) -> _.isEqual update, updateBlueprint
    throw new errors.RuntimeError(
      message: "Can't find an update to remove"
    ) if not ~index
    @updates.splice(index, 1)
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

  # progress helpers
  commandSetIsStarted: (commandId) -> [{_id: commandId}, {$set: {isStarted: true}}]
  commandSetIsCompleted: (commandId) -> [{_id: commandId}, {$set: {isCompleted: true}}]
  commandSetIsFailed: (commandId) -> [{_id: commandId}, {$set: {isFailed: true}}]
  commandSetResult: (commandId, result) -> [{_id: commandId}, {$set: {result: result}}]

module.exports = DecisionTask
