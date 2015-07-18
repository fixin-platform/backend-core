_ = require "underscore"
ActivityTask = require "../lib/Task/ActivityTask"

class Echo extends ActivityTask
  constructor: (options) ->
    _.extend @, options
  execute: ->
    Promise.bind(@)
    .then ->
      new Promise (resolve, reject) =>
        @input.on "readable", =>
          console.log "readable"
          try
            while (object = @input.read())
              console.log object
              if object.message is "Schmetterling!"
                throw new Error("Too afraid!")
              else
                @output.write(object)
            true
          catch error
            console.log error
            reject(error)
        @input.on "end", resolve
        @input.on "error", reject
      .bind(@)
      .catch (error) ->
        @input.removeAllListeners()
        throw error
    .then -> @output.end()


module.exports = Echo
