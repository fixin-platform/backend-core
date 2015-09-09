_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
stamp = require "../../helper/stamp"
Task = require "../Task"
errors = require "../../helper/errors"

class ActivityTask extends Task
  constructor: (input, options, dependencies) ->
    Match.check input, Match.ObjectIncluding
      commandId: String
    super(options, dependencies)
    commonKeys = _.intersection(_.keys(input), _.keys(options), _.keys(dependencies))
    throw new errors.RuntimeError(
      message: "The keys of `options`, `options.input`, `dependencies` can't overlap"
      explanation: "Most probably, you've defined some keys on `options.input` that already exist either on `options` or `dependencies`"
      response: "Rename conflicting keys in `options.input`"
      commonKeys: commonKeys
    ) if commonKeys.length
    _.extend @, input
    @mongodb = dependencies.mongodb
    Match.check @mongodb, Match.Any

  progressBarSetTotal: (total) -> Promise.resolve(@mongodb.collection("Commands").update({_id: @commandId, "progressBars.activityId": @activityId}, {$set: {"progressBars.$.total": total}})).thenReturn(total)
  progressBarIncCurrent: (inc) -> Promise.resolve(@mongodb.collection("Commands").update({_id: @commandId, "progressBars.activityId": @activityId}, {$inc: {"progressBars.$.current": inc}})).thenReturn(inc)
  # NOTE: progressBarIncCurrent shouldn't be called for each object, because it will result in a flood of DB writes; instead, progressBarIncCurrent should be called in batches (e.g. for each page)

  execute: -> throw new Error("Implement me!")

module.exports = ActivityTask
