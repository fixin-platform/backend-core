_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
Match = require "mtr-match"
stamp = require "../../../helper/stamp"
ActivityTask = require "../ActivityTask"
Read = require "./BindingTask/Read"
Save = require "./Save"

class Download extends ActivityTask
  constructor: (input, options, streams, dependencies) ->
    super
    Match.check @read, Read
    Match.check @save, Save
    @save.in = @read.out = new stream.PassThrough({objectMode: true})
    @read.progressBarSetTotal = @progressBarSetTotal.bind(@)
    @read.progressBarIncCurrent = (inc) -> Promise.resolve(inc) # essentially noop
    @save.progressBarSetTotal = (total) -> Promise.resolve(total) # essentially noop
    @save.progressBarIncCurrent = @progressBarIncCurrent.bind(@)

  execute: ->
    Promise.join(@read.execute(), @save.execute())

  arguments: (parentInput, activityId) ->
    input = stamp parentInput[activityId].input, parentInput
    options = _.omit(parentInput[activityId], "input")
    input: input
    options: _.extend options, activityId: activityId

module.exports = Download
