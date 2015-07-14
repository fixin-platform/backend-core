_ = require "underscore"
pigato = require "pigato"
stream = require "readable-stream"
Match = require "mtr-match"

module.exports =
  create: (addr, api, conf = {}, jobs = {}, log = console.error.bind(console)) ->
    worker = new pigato.Worker(addr, api, conf)
    worker.on "request", (request, output, opts) ->
      try
        Match.check request,
          job: String
          options: Object
          body: Object
        input = new stream.Readable({objectMode: true})
        input.on "error", (error) ->
          log(error)
          output.error(error.toString())
        input._read = ->
          @push(request.body)
          @push(null)
        instance = new jobs[request.job] _.extend
          input: input
          output: output
        , request.options
        instance.run()
      catch error
        log(error)
        output.error(error.toString())
    worker

