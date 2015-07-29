_ = require "underscore"

module.exports = (target, source) ->
  _.extend {}, target, _.pick(source, [
    "commandId"
    "stepId"
    "userId"
    "avatarId"
  ])