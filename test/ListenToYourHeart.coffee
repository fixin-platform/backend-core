_ = require "underscore"
DecisionTask = require "../lib/DecisionTask"

class ListenToYourHeart extends DecisionTask
  WorkflowExecutionStarted: (event) ->
    @decisions.push
      decisionType: "ScheduleActivityTask"
      scheduleActivityTaskDecisionAttributes:
        activityType:
          name: "Echo"
          version: "1.0.0"
        activityId: "Echo"
        input: JSON.stringify({message: "h e l l o"})

module.exports = ListenToYourHeart
