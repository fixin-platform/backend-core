_ = require "underscore"
pigato = require "pigato"
{spawn} = require "child_process"

spawnWorkerProcess = (args, callback) ->
  process = spawn("#{__dirname}/../../bin/worker", args)

  output = ""
  recordOutput = (data) ->
    output += data

  process.stdout.on 'data', recordOutput
  process.stderr.on 'data', recordOutput
  process.on 'error', callback
  process.on 'close', (code) ->
    callback null,
      output: output.split('\n').join('\n')
      code: code
  process

describe "bin/worker", ->
  addr = "ipc://test.ipc"
  broker = undefined; client = undefined

  beforeEach (setupDone) ->
    broker = new pigato.Broker(addr)
    client = new pigato.Client(addr)
    setupDone()

  afterEach (teardownDone) ->
    broker.stop()
    client.stop()
    teardownDone()

  describe "normal operation", ->

    beforeEach (setupDone) ->
      setupDone()

    it "should run `echo` service", (testDone) ->
      @slow(500)

      broker.on "error", (msg) -> testDone(new Error(msg))
      broker.start()

      spawnWorkerProcess([
        "--api EchoApi"
        "--addr #{addr}"
        "#{__dirname}/../ReadEcho"
      ], testDone)

      client.on "error", (msg) -> testDone(new Error(msg))
      client.start()
#      client.onMsg = _.wrap client.onMsg.bind(client), (parent, _msg) ->
#        msg = (frame.toString() for frame in _msg)
#        parent(_msg)
      client.request "EchoApi",
        job: "ReadEcho"
        options: {}
        body: {message: "h e l l o"}
      .on "data", (body) ->
        console.log body
        return unless body # last data frame is false (pigato workaround)
        body.message.should.be.equal("h e l l o")
      .on "end", testDone

  describe "error handling", ->
