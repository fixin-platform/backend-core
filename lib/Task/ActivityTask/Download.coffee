_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
Match = require "mtr-match"
ActivityTask = require "../ActivityTask"
Read = require "./Read"
Save = require "./Save"

class Download extends ActivityTask
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      read: Read
      save: Save
    dependencies.save.input = dependencies.read.output = new stream.PassThrough({objectMode: true})
    super

  execute: ->
    Promise.join(@read.execute(), @save.execute())

module.exports = Download
