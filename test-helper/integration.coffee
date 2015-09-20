_ = require "underscore"
Promise = require "bluebird"
exec = require "../../core/test-helper/exec"

functions = {}

functions.createTestWorkflow = (swf, workflowId, name, input) ->
  swf.startWorkflowExecutionAsync(
    domain: "Test"
    workflowId: workflowId
    workflowType:
      name: name
      version: "1.0.0"
    input: JSON.stringify input
  )

functions.terminateWorkflow = (swf, domain, workflowId) ->
  Promise.bind(@)
  .then -> swf.terminateWorkflowExecutionAsync({domain: domain, workflowId: workflowId})
  .catch ((error) -> error.code is "UnknownResourceFault"), ((error) ->) # workflow may have not been started yet

functions.terminateTestWorkflow = _.partial(functions.terminateWorkflow, _, "Test")

functions.createProcess = (execution, settingsPath, path) ->
  Promise.bind(@)
  .then -> exec execution,
    settings: settingsPath
    maxLoops: 1
  , path
  .spread (stdout, stderr, code) ->
    stderr.should.be.equal("")
    code.should.be.equal(0)

functions.createDecider = functions.createProcess.bind(@, "swf/bin/decider")
functions.createWorker = functions.createProcess.bind(@, "swf/bin/worker")

functions.checkProgressBar = (Commands, commandId, name, parameters) ->
  Commands.findOne(commandId).then (command) ->
    progressBar = _.find command.progressBars, (progressBar) -> progressBar.activityId is name
    progressBar.should.be.deep.equal parameters

functions.checkCompletedProgressBar = (Commands, commandId, name, parameters) ->
  functions.checkProgressBar(Commands, commandId, name, _.defaults(parameters, {isStarted: true, isCompleted: true, isFailed: false, activityId: name}))

functions.checkCompletedCommand = (Commands, commandId) ->
  Commands.findOne(commandId).then (command) ->
    command.isStarted.should.be.true
    command.isCompleted.should.be.true
    command.isFailed.should.be.false

module.exports = functions
