errors = require "errors"

errors.stacks true

errors.create
  name: "RuntimeError"

errors.create
  name: "NotImplementedError"
  defaultMessage: "This method is not implemented"
  defaultExplanation: "The method is intended to be implemented by child classes"
  defaultResponse: "Go implement the method already"

errors.create
  name: "MemoryLeakError"
  defaultMessage: "This code seems to leak memory"
  defaultExplanation: """
    * Try going through https://speakerdeck.com/addyosmani/javascript-memory-management-masterclass"
    * After you identify the memory leak pattern, add it first through MemoryLeakTesterSpec (to make sure it actually leaks)
  """

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

errors.create
  name: "NullBodyData"
  defaultMessage: "The response is empty"
  defaultExplanation: "In rare cases the response has no data and it seems like a bug"
  defaultResponse: "Try again"

module.exports = errors
