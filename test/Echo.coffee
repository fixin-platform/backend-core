_ = require "underscore"
ActivityTask = require "../lib/Task/ActivityTask"

class Echo extends ActivityTask
  constructor: (options) ->
    _.extend @, options
  execute: ->
    new Promise (resolve, reject) =>
      @input.on "readable", =>
        while (object = @input.read())
          if object.message is "Schmetterling!"
            throw new Error("Too afraid!")
          else
            @output.write(object)
        true
      @input.on "end", resolve
      @input.on "error", reject
    .then -> @output.end()

module.exports = Echo
