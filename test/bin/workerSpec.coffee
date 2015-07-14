_ = require "underscore"
fs = require "fs"
pigato = require "pigato"
{spawn} = require "child_process"

spawnWorkerProcess = (args, callback) ->
  path = "#{process.env.ROOT_DIR}/bin/worker"
  fs.chmodSync(path, 0o0755) # prop up for Wallaby
  workerProcess = spawn(path, args)

  output = ""
  recordOutput = (data) ->
    output += data

  workerProcess.stdout.on 'data', recordOutput
  workerProcess.stderr.on 'data', recordOutput
  workerProcess.on 'error', callback
  workerProcess.on 'close', (code) ->
    console.log output
    callback null,
      output: output.split('\n').join('\n')
      code: code
  workerProcess

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

      workerProcess = spawnWorkerProcess([
        "--api"
        "EchoApi"
        "--addr"
        addr
        "#{process.env.ROOT_DIR}/test/ReadEcho"
      ], (error, result) ->
        return testDone(error) if error
        try
          result.code.should.be.equal(0) # normal exit code after SIGTERM
          testDone()
        catch error
          testDone(error)
      )

      onData = sinon.spy (body) ->
        return unless body # last data frame is false (pigato workaround)
        body.message.should.be.equal("h e l l o")

      onEnd = ->
        try
          onData.should.have.been.calledTwice
          workerProcess.kill()
          # testDone is called in workerProcess close callback
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

  describe "error handling", ->
