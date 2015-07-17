helpers = require "../helpers"
_ = require "underscore"
Registrar = require "../../lib/Registrar"
ReadEcho = require "../ReadEcho"
options = require "../config/registrar.json"
config = require "../config/aws.json"

describe "WorkerFactory", ->
  registrar = null;

  beforeEach ->
    registrar = new Registrar(options, config)

  describe "normal operation", ->

    beforeEach ->

    # A domain can't be deleted, so this test won't ever pass again in record mode
    it "should register `TestDomain` domain if it's not registered", ->
      @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
      new Promise (resolve, reject) ->
        nock.back "fixtures/registrar/RegisterTestDomainIfNotRegistered.json", (recordingDone) ->
          registrar.registerDomains()
          .then resolve
          .catch reject
          .finally recordingDone

    it "should register `TestDomain` domain", ->
      @timeout(10000) if process.env.NOCK_BACK_MODE is "record"
      new Promise (resolve, reject) ->
        nock.back "fixtures/registrar/SetTestDomainAttributesNotRegistered.json", (recordingDone) ->
          registrar.registerDomains()
          .then resolve
          .catch reject
          .finally recordingDone

#  describe "error handling", ->
#
#    it "should return error if message format doesn't match", (testDone) ->
#      registrar.on "error", (msg) -> testDone(new Error(msg))
#      registrar.start()
#
#      client.on "error", (msg) -> testDone(new Error(msg))
#      client.start()
#
#      worker = WorkerFactory.create(addr, "EchoApi", {}, {}, ->)
#      worker.on "error", (msg) -> testDone(new Error(msg))
#      worker.start()
#
#      client.request("EchoApi", "hello")
#      .on "error", (msg) ->
#        msg.should.be.equal("Error: Expected object, got string")
#        testDone()
#
