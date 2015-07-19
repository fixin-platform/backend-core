_ = require "underscore"
stream = require "readable-stream"
Match = require "mtr-match"
ActivityTask = require "../ActivityTask"
Read = require "./Read"
Save = require "./Save"

class Download extends ActivityTask
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      read: Read
      save: Save
    super
    @save.input = @read.output = new stream.PassThrough({objectMode: true})
  run: ->
    @read.run()
    @save.run()

module.exports = Download
