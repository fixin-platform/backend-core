_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Task = require "../Task"
errors = require "../../helper/errors"

class ActivityTask extends Task
  constructor: (input, options, streams, dependencies) ->
    Match.check input, Object
    Match.check streams, Match.ObjectIncluding
      in: Match.Where (stream) -> Match.test(stream.read, Function) # stream.Readable or stream.Duplex
      out: Match.Where (stream) -> Match.test(stream.write, Function) # stream.Writable or stream.Duplex
    super(options, dependencies)
    commonKeys = _.intersection(_.keys(input), _.keys(options), _.keys(streams), _.keys(dependencies))
    throw new errors.RuntimeError(
      message: "The keys of `options`, `options.input`, `dependencies` can't overlap"
      explanation: "Most probably, you've defined some keys on `options.input` that already exist either on `options` or `dependencies`"
      response: "Rename conflicting keys in `options.input`"
      commonKeys: commonKeys
    ) if commonKeys.length
    _.extend @, input, streams
  execute: -> throw new Error("Implement me!")
  # temp progress stubs
  progressInit: (total) -> Promise.resolve().thenReturn(total)
  progressInc: (inc) -> Promise.resolve().thenReturn(inc)
  progressFinish: -> Promise.resolve()

module.exports = ActivityTask