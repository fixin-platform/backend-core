class WorkflowExecutionHistoryGenerator
  linearize: (tree) ->

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