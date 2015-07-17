_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Actor = require "../Actor"

class Decider extends Actor
  constructor: (options, config) ->
    Match.check options,
      domain: String
      taskList:
        name: String
      identity: String
      taskCls: Function # DecisionTask
    super
  start: ->
    process.nextTick =>
      Promise.bind(@)
      .then @poll
      .then @start
  poll: ->
    Promise.bind(@)
    .then ->
      @swf.pollForDecisionTaskAsync
        domain: @domain
        taskList: @taskList
        identity: @identity
    .then (options) ->
      task = new @taskCls(options)
      task.execute()
      promises = []
      promises.push @swf.respondDecisionTaskCompletedAsync({taskToken: options.taskToken, decisions: task.decisions})
      promises.push @updateCommand(options.workflowExecution.workflowId, task.modifier) unless _.isEmpty task.modifier
      Promise.all(promises)
  updateCommand: ->

module.exports = Decider