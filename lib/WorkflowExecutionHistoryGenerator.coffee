_ = require "underscore"
_.mixin require "underscore.deep"
Match = require "mtr-match"
opath = require "object-path"
camelize = require "underscore.string/camelize"
errors = require "../helper/errors"

class WorkflowExecutionHistoryGenerator
  constructor: (options) ->
    _.extend @, options
    _.defaults @,
      eventIdInitial: 1
      eventTimestampInitial: 1420000000.123 # seconds, not milliseconds
      eventTimestampIncrement: 1
      tree: {}
  seed: (planter) ->
    @tree = planter.call(@)
    Match.check @tree, [Object]
  histories: ->
    histories = []
    for branch in @tree
      histories = histories.concat @trace(branch, [])
    histories
  trace: (root, previousEvents) ->
    Match.check root,
      events: [Object]
      decisions: [Object]
      updates: [[Object]]
      branches: Match.Optional [Object]
    events = _.deepClone root.events
    decisions = _.deepClone root.decisions
    updates = _.deepClone root.updates
    branches = _.deepClone root.branches or []
    previousEvents = _.deepClone previousEvents
    events.push @DecisionTaskScheduled()
    events.push @DecisionTaskStarted()
    nextEvents = @nextEvents events, previousEvents
    histories = []
    histories.push
      name: _.pluck(nextEvents, "eventType").join(" -> ")
      events: nextEvents
      decisions: decisions
      updates: updates
    decisionEvents = @decisionsToEvents(decisions, updates)
    nextEventsWithDecisionEvents = @nextEvents(decisionEvents, nextEvents)
    for event in nextEventsWithDecisionEvents
      mappings = @remappedEventTypes[event.eventType] or []
      for mapping in mappings
        parentEvent = _.find nextEventsWithDecisionEvents, (parentEvent) -> opath.get(parentEvent, mapping.fromMatchField) is opath.get(event, mapping.toMatchField)
        throw new errors.RuntimeError(
          message: "Couldn't find parent event using mapping"
          mapping: mapping
          event: event
        ) unless parentEvent
        opath.set(event, mapping.toField, opath.get(parentEvent, mapping.fromField))
    for branch in branches
      histories = histories.concat @trace(branch, nextEventsWithDecisionEvents)
    histories
  decisionsToEvents: (decisions, updates) ->
    events = []
    events.push @DecisionTaskCompleted
      updates: updates
    for decision in decisions
      attributes = decision[@decisionAttributesProperty(decision)]
      switch decision.decisionType
        when "ScheduleActivityTask"
          events.push @ActivityTaskScheduled(attributes.activityId, attributes.input)
          events.push @ActivityTaskStarted(attributes.activityId)
        when "CompleteWorkflowExecution"
          events.push @WorkflowExecutionCompleted(attributes.result)
        when "FailWorkflowExecution"
          events.push @WorkflowExecutionFailed(attributes.reason, attributes.details)
        when "CancelWorkflowExecution"
          # not implemented
        else
          throw new Error("decisionsToEvents() for decisionType \"#{decision.decisionType}\" not implemented")
    events
  nextEvents: (events, previousEvents) ->
    lastEvent = _.last previousEvents
    eventIdLast = lastEvent?.eventId or (@eventIdInitial - 1)
    eventTimestampLast = lastEvent?.eventTimestamp or @eventTimestampInitial - @eventTimestampIncrement
    for event in events
      event.eventId = eventIdLast + 1
      event.eventTimestamp = eventTimestampLast + @eventTimestampIncrement
      eventIdLast = event.eventId
      eventTimestampLast = event.eventTimestamp
    previousEvents.concat(events)
  attributesProperty: (name, suffix) ->
    camelize(name, true) + suffix
  eventAttributesProperty: (event) ->
    @attributesProperty(event.eventType, "EventAttributes")
  decisionAttributesProperty: (decision) ->
    @attributesProperty(decision.decisionType, "DecisionAttributes")
  Event: (attributes, options) ->
    attributes.input = JSON.stringify attributes.input if attributes.input
    attributes.result = JSON.stringify attributes.result if attributes.result
    attributes.executionContext = JSON.stringify attributes.executionContext if attributes.executionContext
    _.defaults options,
      eventId: 0
      eventTimestamp: null
      "#{@eventAttributesProperty(options)}": attributes
# Here should be a mega-validator of event
  Decision: (attributes, options) ->
    attributes.input = JSON.stringify attributes.input if attributes.input
    attributes.result = JSON.stringify attributes.result if attributes.result
    attributes.details = JSON.stringify attributes.details if attributes.details
    _.defaults options,
      "#{@decisionAttributesProperty(options)}": attributes
# Here should be a mega-validator of event
  WorkflowExecutionStarted: (input = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        input: input
      , attributes
    , _.extend
        eventType: "WorkflowExecutionStarted"
      ,
        options
    )
  DecisionTaskScheduled: (attributes = {}, options = {}) ->
    @Event(
      _.extend {}
      , attributes
    , _.extend
        eventType: "DecisionTaskScheduled"
      , options
    )
  DecisionTaskStarted: (attributes = {}, options = {}) ->
    @Event(
      _.extend {}
      , attributes
    , _.extend
        eventType: "DecisionTaskStarted"
      , options
    )
  DecisionTaskCompleted: (executionContext, attributes = {}, options = {}) ->
    @Event(
      _.extend
        executionContext: executionContext
      , attributes
    , _.extend
        eventType: "DecisionTaskCompleted"
      , options
    )
  ActivityTaskScheduled: (activityShorthand, input = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        activityType:
          name: activityShorthand
          version: "1.0.0"
        activityId: activityShorthand
        input: input
      , attributes
    , _.extend
        eventType: "ActivityTaskScheduled"
      , options
    )
  ActivityTaskStarted: (__activityId, attributes = {}, options = {}) ->
    @Event(
      _.extend
        __activityId: __activityId
      , attributes
    , _.extend
        eventType: "ActivityTaskStarted"
      , options
    )
  ActivityTaskCompleted: (__activityId, result = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        __activityId: __activityId
        result: result
      , attributes
    , _.extend
        eventType: "ActivityTaskCompleted"
      , options
    )
  ActivityTaskFailed: (__activityId, reason = "", details = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        __activityId: __activityId
        reason: reason
        details: details
      , attributes
    , _.extend
        eventType: "ActivityTaskFailed"
      , options
    )
  WorkflowExecutionFailed: (reason = "", details = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        reason: reason
        details: details
      , attributes
    , _.extend
        eventType: "WorkflowExecutionFailed"
      , options
    )
  WorkflowExecutionCompleted: (result = {}, attributes = {}, options = {}) ->
    @Event(
      _.extend
        result: result
      , attributes
    , _.extend
        eventType: "WorkflowExecutionCompleted"
      , options
    )
  WorkflowExecutionCancelRequested: (cause = "", attributes = {}, options = {}) ->
    @Event(
      _.extend
        cause: cause
      , attributes
    , _.extend
        eventType: "WorkflowExecutionCancelRequested"
      , options
    )
  ScheduleActivityTask: (activityShorthand, input = {}, attributes = {}, options = {}) ->
    @Decision(
      _.extend
        activityType:
          name: activityShorthand
          version: "1.0.0"
        activityId: activityShorthand
        input: input
      , attributes
    ,
      _.extend
        decisionType: "ScheduleActivityTask"
      , options
    )
  CompleteWorkflowExecution: (result, attributes = {}, options = {}) ->
    @Decision(
      _.extend
        result: result
      , attributes
    ,
      _.extend
        decisionType: "CompleteWorkflowExecution"
      , options
    )
  FailWorkflowExecution: (reason = "", details = {}, attributes = {}, options = {}) ->
    @Decision(
      _.extend
        reason: reason
        details: details
      , attributes
    ,
      _.extend
        decisionType: "FailWorkflowExecution"
      , options
    )
  CancelWorkflowExecution: (details = {}, attributes = {}, options = {}) ->
    @Decision(
      _.extend
        details: details
      , attributes
    ,
      _.extend
        decisionType: "CancelWorkflowExecution"
      , options
    )
  progressBarStartUpdate: (commandId, activityId) ->
    [{_id: commandId, "progressBars.activityId": activityId}, {$set: {"progressBars.$.isStarted": true}}]
  progressBarFinishUpdate: (commandId, activityId) ->
    [{_id: commandId, "progressBars.activityId": activityId}, {$set: {"progressBars.$.isFinished": true}}]
  remappedEventTypes:
    "ActivityTaskStarted": [
      fromMatchField: "activityTaskScheduledEventAttributes.activityId"
      toMatchField: "activityTaskStartedEventAttributes.__activityId"
      fromField: "eventId"
      toField: "activityTaskStartedEventAttributes.scheduledEventId"
    ]
    "ActivityTaskCompleted": [
      fromMatchField: "activityTaskScheduledEventAttributes.activityId"
      toMatchField: "activityTaskCompletedEventAttributes.__activityId"
      fromField: "eventId"
      toField: "activityTaskCompletedEventAttributes.scheduledEventId"
    ,
      fromMatchField: "activityTaskStartedEventAttributes.scheduledEventId"
      toMatchField: "activityTaskCompletedEventAttributes.scheduledEventId"
      fromField: "eventId"
      toField: "activityTaskCompletedEventAttributes.startedEventId"
    ]
    "ActivityTaskFailed": [
      fromMatchField: "activityTaskScheduledEventAttributes.activityId"
      toMatchField: "activityTaskFailedEventAttributes.__activityId"
      fromField: "eventId"
      toField: "activityTaskFailedEventAttributes.scheduledEventId"
    ,
      fromMatchField: "activityTaskStartedEventAttributes.scheduledEventId"
      toMatchField: "activityTaskFailedEventAttributes.scheduledEventId"
      fromField: "eventId"
      toField: "activityTaskFailedEventAttributes.startedEventId"
    ]

module.exports = WorkflowExecutionHistoryGenerator

sampleDecision =
  decisionType: 'ScheduleActivityTask | RequestCancelActivityTask | CompleteWorkflowExecution | FailWorkflowExecution | CancelWorkflowExecution | ContinueAsNewWorkflowExecution | RecordMarker | StartTimer | CancelTimer | SignalExternalWorkflowExecution | RequestCancelExternalWorkflowExecution | StartChildWorkflowExecution'
  cancelTimerDecisionAttributes:
    timerId: 'STRING_VALUE'
  cancelWorkflowExecutionDecisionAttributes:
    details: 'STRING_VALUE'
  completeWorkflowExecutionDecisionAttributes:
    result: 'STRING_VALUE'
  continueAsNewWorkflowExecutionDecisionAttributes:
    childPolicy: 'TERMINATE | REQUEST_CANCEL | ABANDON'
    executionStartToCloseTimeout: 'STRING_VALUE'
    input: 'STRING_VALUE'
    tagList: ['STRING_VALUE']
    taskList:
      name: 'STRING_VALUE'
    taskPriority: 'STRING_VALUE'
    taskStartToCloseTimeout: 'STRING_VALUE'
    workflowTypeVersion: 'STRING_VALUE'
  failWorkflowExecutionDecisionAttributes:
    details: 'STRING_VALUE'
    reason: 'STRING_VALUE'
  recordMarkerDecisionAttributes:
    markerName: 'STRING_VALUE'
    details: 'STRING_VALUE'
  requestCancelActivityTaskDecisionAttributes:
    activityId: 'STRING_VALUE'
  requestCancelExternalWorkflowExecutionDecisionAttributes:
    workflowId: 'STRING_VALUE'
    control: 'STRING_VALUE'
    runId: 'STRING_VALUE'
  scheduleActivityTaskDecisionAttributes:
    activityId: 'STRING_VALUE'
    activityType:
      name: 'STRING_VALUE'
      version: 'STRING_VALUE'
    control: 'STRING_VALUE'
    heartbeatTimeout: 'STRING_VALUE'
    input: 'STRING_VALUE'
    scheduleToCloseTimeout: 'STRING_VALUE'
    scheduleToStartTimeout: 'STRING_VALUE'
    startToCloseTimeout: 'STRING_VALUE'
    taskList:
      name: 'STRING_VALUE'
    taskPriority: 'STRING_VALUE'
  signalExternalWorkflowExecutionDecisionAttributes:
    signalName: 'STRING_VALUE'
    workflowId: 'STRING_VALUE'
    control: 'STRING_VALUE'
    input: 'STRING_VALUE'
    runId: 'STRING_VALUE'
  startChildWorkflowExecutionDecisionAttributes:
    workflowId: 'STRING_VALUE'
    workflowType:
      name: 'STRING_VALUE'
      version: 'STRING_VALUE'
    childPolicy: 'TERMINATE | REQUEST_CANCEL | ABANDON'
    control: 'STRING_VALUE'
    executionStartToCloseTimeout: 'STRING_VALUE'
    input: 'STRING_VALUE'
    tagList: ['STRING_VALUE']
    taskList:
      name: 'STRING_VALUE'
    taskPriority: 'STRING_VALUE'
    taskStartToCloseTimeout: 'STRING_VALUE'
  startTimerDecisionAttributes:
    startToFireTimeout: 'STRING_VALUE'
    timerId: 'STRING_VALUE'
    control: 'STRING_VALUE'

sampleEventMap = [
  {
    "eventId": 1,
    "eventTimestamp": 1437385869.631,
    "eventType": "WorkflowExecutionStarted",
    "workflowExecutionStartedEventAttributes": {
      "childPolicy": "REQUEST_CANCEL",
      "executionStartToCloseTimeout": "1800000",
      "input": "{\"Echo\":{\"chunks\":[{\"message\":\"h e l l o\"}]}}",
      "parentInitiatedEventId": 0,
      "taskList": {
        "name": "ListenToYourHeart"
      },
      "taskPriority": "0",
      "taskStartToCloseTimeout": "600000",
      "workflowType": {
        "name": "ListenToYourHeart",
        "version": "1.0.0"
      }
    }
  },
  {
    "decisionTaskScheduledEventAttributes": {
      "startToCloseTimeout": "600000",
      "taskList": {
        "name": "ListenToYourHeart"
      },
      "taskPriority": "0"
    },
    "eventId": 2,
    "eventTimestamp": 1437385869.631,
    "eventType": "DecisionTaskScheduled"
  },
  {
    "decisionTaskStartedEventAttributes": {
      "identity": "ListenToYourHeart-test-decider",
      "scheduledEventId": 2
    },
    "eventId": 3,
    "eventTimestamp": 1437385871.148,
    "eventType": "DecisionTaskStarted"
  },
  {
    "decisionTaskCompletedEventAttributes": {
      "scheduledEventId": 2,
      "startedEventId": 3
    },
    "eventId": 4,
    "eventTimestamp": 1437385871.863,
    "eventType": "DecisionTaskCompleted"
  },
  {
    "activityTaskScheduledEventAttributes": {
      "activityId": "Echo",
      "activityType": {
        "name": "Echo",
        "version": "1.0.0"
      },
      "decisionTaskCompletedEventId": 4,
      "heartbeatTimeout": "30000",
      "input": "{\"chunks\":[{\"message\":\"h e l l o\"}]}",
      "scheduleToCloseTimeout": "NONE",
      "scheduleToStartTimeout": "1800000",
      "startToCloseTimeout": "600000",
      "taskList": {
        "name": "Echo"
      },
      "taskPriority": "0"
    },
    "eventId": 5,
    "eventTimestamp": 1437385871.863,
    "eventType": "ActivityTaskScheduled"
  },
  {
    "activityTaskStartedEventAttributes": {
      "identity": "Echo-test-worker",
      "scheduledEventId": 5
    },
    "eventId": 6,
    "eventTimestamp": 1437385877.548,
    "eventType": "ActivityTaskStarted"
  },
  {
    "activityTaskCompletedEventAttributes": {
      "result": "{\"chunks\":[{\"message\":\"h e l l o (reply)\"}]}",
      "scheduledEventId": 5,
      "startedEventId": 6
    },
    "eventId": 7,
    "eventTimestamp": 1437385878.277,
    "eventType": "ActivityTaskCompleted"
  },
  {
    "decisionTaskScheduledEventAttributes": {
      "startToCloseTimeout": "600000",
      "taskList": {
        "name": "ListenToYourHeart"
      },
      "taskPriority": "0"
    },
    "eventId": 8,
    "eventTimestamp": 1437385878.277,
    "eventType": "DecisionTaskScheduled"
  },
  {
    "decisionTaskStartedEventAttributes": {
      "identity": "ListenToYourHeart-test-decider",
      "scheduledEventId": 8
    },
    "eventId": 9,
    "eventTimestamp": 1437385878.987,
    "eventType": "DecisionTaskStarted"
  }
]
