errors = require "errors"

errors.stacks true

errors.create
  name: "EventHandlerNotImplementedError"
  defaultExplanation: "The implementor of this decision task hasn't anticipated such event type"
  defaultResponse: "Find out who implemented this decision task via `git log` and talk to him - OR - figure it out yourself"

errors.create
  name: "NoDecisionsError"
  defaultMessage: "The task didn't produce any decisions"
  defaultExplanation: "The task is coded incorrectly"
  defaultResponse: "Find out who implemented this decision task via `git log` and talk to him - OR - figure it out yourself"

errors.create
  name: "RateLimitReachedError"
  defaultMessage: "The request was rejected by API server"
  defaultExplanation: "The rate limit for prodived credentials was reached"
  defaultResponse: "Try again later - OR - Ask the API developer to increase the limit"


module.exports = errors