_ = require "underscore"
camelize = require "underscore.string/camelize"

class WorkflowExecutionHistoryGenerator
  constructor: (options) ->
    _.extend @, options
    _.defaults @,
      tree: {}
  init: (initializer) ->
    @tree = initializer.call(@)
    Match.check @tree, [Object]
  histories: ->
    for branch of @tree
      @linearize(branch)
  linearize: ->
    []
  attributes: (eventType) ->
  Event: (event) ->
    attributes = event.attributes
    attributes.input = JSON.stringify attributes.input if attributes.input
    attributesProperty = camelize(event.eventType, true) + "EventAttributes"
    delete event.attributes
    _.defaults event,
      eventTimestamp: new Date()
      eventId: 0
      "#{attributesProperty}": attributes
    # Here should be a mega-validator of event
  WorkflowExecutionStarted: (input = {}, attributes = {}, options = {}) ->
    attributes.input = input
    @Event _.defaults options,
      eventType: "WorkflowExecutionStarted"
      attributes: attributes

module.exports = WorkflowExecutionHistoryGenerator

Event = (eventType, eventAttributes) ->
  attributes = camelize(eventType, true) + "EventAttributes"
  eventType: eventType
  "#{attributes}": eventAttributes

WorkflowExecutionStarted = -> Event "WorkflowExecutionStarted",
  input: JSON.stringify
    "FreshdeskDownloadUsers":
      avatarId: "D6vpAkoHyBXPadp4c"
      params: {}
    "3DCartDownloadOrders":
      avatarId: "T7JwArn9vCJLiKXbn"
      baseUrl: "http://store.bellefit.com"
      params: {}
    "BellefitGenerate3DCartOrdersByFreshdeskUserIdCollection":
      avatarIds:
        "Freshdesk": "D6vpAkoHyBXPadp4c"
        "3DCart": "T7JwArn9vCJLiKXbn"

ActivityTaskCompleted = (activityId) -> Event "ActivityTaskCompleted",
  activityId: activityId

ActivityTaskScheduled = (activityId) -> Event "ActivityTaskScheduled",
  activityId: activityId

tests =
  "start":
    events: [
      WorkflowExecutionStarted()
    ]
    decisions: [
      decisionType: "ScheduleActivityTask"
      scheduleActivityTaskDecisionAttributes:
        activityType:
          name: "FreshdeskDownloadUsers"
          version: "1.0.0"
        activityId: "FreshdeskDownloadUsers"
        input: JSON.stringify
          avatarId: "D6vpAkoHyBXPadp4c"
          params: {}
        ,
          decisionType: "ScheduleActivityTask"
          scheduleActivityTaskDecisionAttributes:
            activityType:
              name: "3DCartDownloadOrders"
              version: "1.0.0"
            activityId: "3DCartDownloadOrders"
            input: JSON.stringify
              avatarId: "T7JwArn9vCJLiKXbn"
              baseUrl: "http://store.bellefit.com"
              params: {}
    ]
  "FreshdeskDownloadUsersComplete":
    events: [
      WorkflowExecutionStarted()
      ActivityTaskScheduled("FreshdeskDownloadUsers")
      ActivityTaskCompleted("FreshdeskDownloadUsers")
    ]
    decisions: []
  "3DCartDownloadOrdersComplete":
    events: [
      WorkflowExecutionStarted()
      ActivityTaskScheduled("FreshdeskDownloadUsers")
      ActivityTaskCompleted("FreshdeskDownloadUsers")
      ActivityTaskScheduled("3DCartDownloadOrders")
      ActivityTaskCompleted("3DCartDownloadOrders")
    ]
    decisions: [
      decisionType: "ScheduleActivityTask"
      scheduleActivityTaskDecisionAttributes:
        activityType:
          name: "BellefitGenerate3DCartOrdersByFreshdeskUserIdCollection"
          version: "1.0.0"
        activityId: "BellefitGenerate3DCartOrdersByFreshdeskUserIdCollection"
        input: JSON.stringify
          avatarIds:
            "Freshdesk": "D6vpAkoHyBXPadp4c"
            "3DCart": "T7JwArn9vCJLiKXbn"
    ]
  "BellefitGenerate3DCartOrdersByFreshdeskUserIdCollectionComplete":
    events: [
      WorkflowExecutionStarted()
      ActivityTaskScheduled("FreshdeskDownloadUsers")
      ActivityTaskCompleted("FreshdeskDownloadUsers")
      ActivityTaskScheduled("3DCartDownloadOrders")
      ActivityTaskCompleted("3DCartDownloadOrders")
      ActivityTaskScheduled("BellefitGenerate3DCartOrdersByFreshdeskUserIdCollection")
      ActivityTaskCompleted("BellefitGenerate3DCartOrdersByFreshdeskUserIdCollection")
    ]
    decisions: [
      decisionType: "CompleteWorkflowExecution"
      completeWorkflowExecutionDecisionAttributes:
        result: JSON.stringify {success: true}
    ]