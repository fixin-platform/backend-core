_ = require "underscore"
DecisionTask = require "../lib/Task/DecisionTask"

class ListenToYourHeart extends DecisionTask
  WorkflowExecutionStarted: (event) ->
    @decisions.push
      decisionType: "ScheduleActivityTask"
      scheduleActivityTaskDecisionAttributes:
        activityType:
          name: "Echo"
          version: "1.0.0"
        activityId: "Echo"
        input: event.workflowExecutionStartedEventAttributes.input
  ActivityTaskCompleted: (event) ->
    @decisions.push
      decisionType: "CompleteWorkflowExecution"
      completeWorkflowExecutionDecisionAttributes:
        result: event.activityTaskCompletedEventAttributes.result
  ActivityTaskFailed: (event) ->
    @decisions.push
      decisionType: "FailWorkflowExecution"
      failWorkflowExecutionDecisionAttributes:
        reason: event.activityTaskFailedEventAttributes.reason
        details: event.activityTaskFailedEventAttributes.details

module.exports = ListenToYourHeart
