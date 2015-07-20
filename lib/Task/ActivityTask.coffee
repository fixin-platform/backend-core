_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Task = require "../Task"

class ActivityTask extends Task
  constructor: (options, dependencies) ->
    Match.check dependencies, Match.ObjectIncluding
      input: Match.Where (stream) -> Match.test(stream.read, Function) # stream.Readable or stream.Duplex
      output: Match.Where (stream) -> Match.test(stream.write, Function) # stream.Writable or stream.Duplex
    super
  execute: -> throw new Error("Implement me!")

module.exports = ActivityTask