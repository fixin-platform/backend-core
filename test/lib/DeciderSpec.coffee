helpers = require "../helpers"
_ = require "underscore"
Registrar = require "../../lib/Actor/Registrar"
Decider = require "../../lib/Actor/Decider"
ListenToYourHeart = require "../ListenToYourHeart"
options = require "../config/registrar.json"
config = require "../config/aws.json"

describe "Decider", ->
  @timeout(10000) if process.env.NOCK_BACK_MODE is "record"

  registrar = null; decider = null; workflowType = null;

  beforeEach ->
    registrar = new Registrar(options, config)
    decider = new Decider(
      domain: "TestDomain"
      taskList:
        name: "ListenToYourHeart"
      taskCls: ListenToYourHeart
      identity: "ListenToYourHeart-test-decider"
    , config)
    workflowType = _.findWhere registrar.workflowTypes, {name: "ListenToYourHeart"}
    workflowType = _.pick workflowType, "name", "version"

  describe "domains", ->

    # a domain can't be deleted, so this test won't ever pass again in record mode
    it "should run `ListenToYourHeart` decision task", ->
      new Promise (resolve, reject) ->
        nock.back "test/fixtures/decider/ListenToYourHeart.json", (recordingDone) ->
          Promise.resolve()
          .then -> registrar.registerAll()
          .then -> decider.swf.startWorkflowExecutionAsync( # Normally, workflow execution should be started by frontend code
            domain: decider.domain
            workflowId: "ListenToYourHeart-test-workflow"
            workflowType: workflowType
            taskList: decider.taskList
          )
          .then -> decider.poll()
          .then resolve
          .catch reject
          .finally recordingDone


  describe "error handling", ->

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
