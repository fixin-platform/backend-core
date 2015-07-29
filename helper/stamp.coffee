_ = require "underscore"

module.exports = (target, source) ->
  _.defaults {}, target, _.pick(source, [
    "commandId"
    "stepId"
    "userId"
    "avatarId"
  ])
