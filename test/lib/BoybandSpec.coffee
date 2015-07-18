helpers = require "../helpers"
_ = require "underscore"
createLogger = require "../../helper/logger"
createSWF = require "../../helper/swf"
Registrar = require "../../lib/Actor/Registrar"
Decider = require "../../lib/Actor/Decider"
Worker = require "../../lib/Actor/Worker"
ListenToYourHeart = require "../ListenToYourHeart"
Echo = require "../Echo"
registrarOptions = require "../config/registrar.json"
dependenciesOptions = require "../config/dependencies.json"

describe "Boyband: Decider & Worker", ->
  @timeout(30000) if process.env.NOCK_BACK_MODE is "record"

  registrar = null; decider = null; worker = null;

  dependencies =
    logger: createLogger(dependenciesOptions.logger)
    swf: createSWF(dependenciesOptions.swf)

  beforeEach ->
    registrar = new Registrar(registrarOptions, dependencies)
    decider = new Decider(
      domain: "TestDomain"
      taskList:
        name: "ListenToYourHeart"
      taskCls: ListenToYourHeart
      identity: "ListenToYourHeart-test-decider"
    , dependencies)
    worker = new Worker(
      domain: "TestDomain"
      taskList:
        name: "Echo"
      taskCls: Echo
      identity: "Echo-test-worker"
    , dependencies)

  clean = ->
    registrar.swf.listOpenWorkflowExecutionsAsync
      domain: "TestDomain"
      startTimeFilter:
        oldestDate: 0
      typeFilter:
        name: "ListenToYourHeart"
        version: "1.0.0"
    .then (response) ->
      Promise.all(
        for executionInfo in response.executionInfos
          registrar.swf.terminateWorkflowExecutionAsync
            domain: "TestDomain"
            workflowId: executionInfo.execution.workflowId
      )

  generateWorkflowExecutionParams = (workflowId, message) ->
    domain: "TestDomain"
    workflowId: workflowId
    workflowType:
      name: "ListenToYourHeart"
      version: "1.0.0"
    taskList:
      name: "ListenToYourHeart"
    input: JSON.stringify [{message: message}]

  describe "domains", ->

    it "should run through `ListenToYourHeart` workflow multiple times", ->
      new Promise (resolve, reject) ->
        nock.back "test/fixtures/decider/ListenToYourHeartMultiple.json", (recordingDone) ->
          Promise.resolve()
#          .then -> registrar.registerAll()
          .then clean
          # Normally, workflow execution should be started by frontend code
#          .then -> decider.swf.startWorkflowExecutionAsync(
#            generateWorkflowExecutionParams("ListenToYourHeart-test-workflow-1", "h e l l o")
#          )
          .then -> decider.swf.startWorkflowExecutionAsync(
            generateWorkflowExecutionParams("ListenToYourHeart-test-workflow-2", "Schmetterling!")
          )
#          .then -> decider.poll() # ScheduleActivityTask 1
          .then -> decider.poll() # ScheduleActivityTask 2
          .then -> worker.poll() # Echo 1 Completed
          .then -> decider.poll() # CompleteWorkflowExecution
          .then -> worker.poll() # Echo 2 Failed
          .then -> decider.poll() # FailWorkflowExecution
          .then -> decider.swf.startWorkflowExecutionAsync(
            generateWorkflowExecutionParams("ListenToYourHeart-test-workflow-3", "Knock, knock, Neo")
          )
          .then -> worker.poll() # Echo 1 Completed
          .then -> decider.poll() # CompleteWorkflowExecution
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
