_ = require "underscore"

class ReadEcho
  constructor: (options) ->
    _.extend @, options
  run: ->
    @input.on "data", (chunk) =>
      @output.write(chunk)
    @input.on "end", =>
      @output.end(false)

#    also works
#    @output.end(@input.read())

#    doesn't work
#    stream = fs.createReadStream("#{process.env.ROOT_DIR}/test/config.json")
#    stream.pipe(@output)

#    doesn't work
#    @input.pipe(@output, {end: false})
#    @output.end('')


module.exports = ReadEcho
