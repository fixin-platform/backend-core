_ = require "underscore"
Promise = require "bluebird"
errors = require "../../helper/errors"
Match = require "mtr-match"
Actor = require "../Actor"

class Worker extends Actor
  constructor: (options, config) ->
    Match.check options,
      domain: String
      taskList:
        name: String
      identity: String
      taskCls: Function # ActivityTask
    super
  start: ->
    process.nextTick =>
      Promise.bind(@)
      .then @poll
      .then @start
  poll: ->
    Promise.bind(@)
    .then ->
      @swf.pollForActivityTaskAsync
        domain: @domain
        taskList: @taskList
        identity: @identity
    .then (options) ->
      new Promise (resolve, reject) =>
        inputArray = JSON.parse(options.input)
        outputArray = []
        Match.check(inputArray, [Object])
        input = new stream.Readable({objectMode: true})
        input.on "error", reject
        input._read = -> true while @push inputArray.shift() or null
        output = new stream.Writable({objectMode: true})
        output.on "error", reject
        output._write = (chunk, encoding, callback) ->
          outputArray.push chunk
          callback()
        task = new @taskCls _.extend {}, options,
          worker: @
          input: input
          output: output
        task.execute()
        .then -> resolve(outputArray)
        .catch reject
      .then (outputArray) ->
        @swf.respondActivityTaskCompletedAsync
          taskToken: options.taskToken
          result: JSON.stringify outputArray
      .catch (error) ->
        error = errors.errorToJSON(error)
        @swf.respondActivityTaskFailedAsync
          taskToken: options.taskToken
          reason: error.name
          details: JSON.stringify error


module.exports = Worker