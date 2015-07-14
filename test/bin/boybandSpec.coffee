_ = require "underscore"
fs = require "fs"
pigato = require "pigato"
helpers = require "../helpers"

describe "Boy band", ->
  addr = "ipc://boyband.ipc" # must be unique per suite
  client = undefined

  beforeEach (setupDone) ->
    client = new pigato.Client(addr)
    setupDone()

  afterEach (teardownDone) ->
    client.stop()
    teardownDone()

  describe "normal operation", ->

    beforeEach (setupDone) ->
      setupDone()

    it "should sing in unison", (testDone) ->
      @slow(1000)

      workerProcess = helpers.spawnWorker([
        "--api"
        "EchoApi"
        "--addr"
        addr
        "#{process.env.ROOT_DIR}/test/ReadEcho"
      ], (error, result) ->
        return testDone(error) if error
        try
          result.code.should.be.equal(0) # normal exit code after SIGTERM
        catch error
          testDone(error)
      )

      onData = sinon.spy (body) ->
        return unless body # last data frame is false (pigato workaround)
        body.message.should.be.equal("h e l l o")

      onEnd = ->
        try
          onData.should.have.been.calledTwice
          brokerProcess.once "exit", ->
            workerProcess.once "exit", ->
              testDone()
            workerProcess.kill()
          brokerProcess.kill()
        catch error
          testDone(error)

      client.on "error", (msg) -> testDone(new Error(msg))
      client.start()
#      client.onMsg = _.wrap client.onMsg.bind(client), (parent, _msg) ->
#        msg = (frame.toString() for frame in _msg)
#        parent(_msg)
      client.request "EchoApi",
        job: "ReadEcho"
        options: {}
        body: {message: "h e l l o"}
      .on "data", onData
      .on "end", onEnd

      # brokerProcess is intentionally started after worker and client to test unordered startup
      brokerProcess = helpers.spawnBroker([
          "--addr"
          addr
        ], (error, result) ->
        return testDone(error) if error
        try
          result.code.should.be.equal(0) # normal exit code after SIGTERM
        catch error
          testDone(error)
      )

  describe "error handling", ->
