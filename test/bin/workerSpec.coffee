#_ = require "underscore"
#fs = require "fs"
#pigato = require "pigato"
#helpers = require "../helpers"
#
#describe "bin/worker", ->
#  addr = "ipc://worker.ipc" # must be unique per suite
#  broker = undefined; client = undefined
#
#  beforeEach (setupDone) ->
#    broker = new pigato.Broker(addr)
#    client = new pigato.Client(addr)
#    setupDone()
#
#  afterEach (teardownDone) ->
#    broker.stop()
#    client.stop()
#    teardownDone()
#
#  describe "normal operation", ->
#
#    beforeEach (setupDone) ->
#      setupDone()
#
#    it "should run `echo` service", (testDone) ->
#      @slow(500)
#
#      broker.on "error", (msg) -> testDone(new Error(msg))
#      broker.start()
#
#      workerProcess = helpers.spawnWorker([
#        "--api"
#        "EchoApi"
#        "--addr"
#        addr
#        "#{process.env.ROOT_DIR}/test/ReadEcho"
#      ], (error, result) ->
#        return testDone(error) if error
#        try
#          result.code.should.be.equal(0) # normal exit code after SIGTERM
#        catch error
#          testDone(error)
#      )
#
#      onData = sinon.spy (body) ->
#        return unless body # last data frame is false (pigato workaround)
#        body.message.should.be.equal("h e l l o")
#
#      onEnd = ->
#        try
#          onData.should.have.been.calledTwice
#          workerProcess.once "exit", ->
#            testDone()
#          workerProcess.kill()
#        catch error
#          testDone(error)
#
#      client.on "error", (msg) -> testDone(new Error(msg))
#      client.start()
##      client.onMsg = _.wrap client.onMsg.bind(client), (parent, _msg) ->
##        msg = (frame.toString() for frame in _msg)
##        parent(_msg)
#      client.request "EchoApi",
#        job: "ReadEcho"
#        options: {}
#        body: {message: "h e l l o"}
#      .on "data", onData
#      .on "end", onEnd
#
#  describe "error handling", ->
