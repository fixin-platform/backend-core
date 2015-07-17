helpers = require "../helpers"
_ = require "underscore"
Registrar = require "../../lib/Registrar"
ReadEcho = require "../ReadEcho"
options = require "../config/registrar.json"
config = require "../config/aws.json"

describe "WorkerFactory", ->
  @timeout(10000) if process.env.NOCK_BACK_MODE is "record"

  registrar = null;

  beforeEach ->
    registrar = new Registrar(options, config)

  describe "normal operation", ->

    beforeEach ->

    # a domain can't be deleted, so this test won't ever pass again in record mode
    it "should register `TestDomain` domain if it's not registered", ->
      new Promise (resolve, reject) ->
        nock.back "test/fixtures/registrar/RegisterTestDomainIfNotRegistered.json", (recordingDone) ->
          registrar.ensureAllDomains()
          .then resolve
          .catch reject
          .finally recordingDone

    # you might have already registered some other domains, so if you re-record the fixture, it'll be different (and I think it's OK)
    it "should skip `TestDomain` domain if it's already registered", ->
      new Promise (resolve, reject) ->
        nock.back "test/fixtures/registrar/SkipTestDomainIfAlreadyRegistered.json", (recordingDone) ->
          registrar.ensureAllDomains()
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
