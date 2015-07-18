_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
Actor = require "../Actor"

class Registrar extends Actor
  constructor: (options, dependencies) ->
    Match.check options,git 
      domains: [Object]
      workflowTypes: [Object]
      activityTypes: [Object]
    super
  registerAll: ->
    Promise.bind(@)
    .then @registerAllDomains
    .then @registerAllWorkflowTypes
    .then @registerAllActivityTypes
  registerAllDomains: ->
    Promise.all(@registerDomain(domain) for domain in @domains)
  registerAllWorkflowTypes: ->
    Promise.all(@registerWorkflowType(workflowType) for workflowType in @workflowTypes)
  registerAllActivityTypes: ->
    Promise.all(@registerActivityType(activityType) for activityType in @activityTypes)
  registerDomain: (domain) ->
    @swf.registerDomainAsync(domain)
    .catch ((error) -> error.code is "DomainAlreadyExistsFault"), (error) -> # noop, passthrough for other errors
  registerWorkflowType: (workflowType) ->
    @swf.registerWorkflowTypeAsync(workflowType)
    .catch ((error) -> error.code is "TypeAlreadyExistsFault"), (error) -> # noop, passthrough for other errors
  registerActivityType: (activityType) ->
    @swf.registerActivityTypeAsync(activityType)
    .catch ((error) -> error.code is "TypeAlreadyExistsFault"), (error) -> # noop, passthrough for other errors
  listDomains: (params) ->
    @swf.listDomainsAsync(params).bind(@)
    .then (data) ->
      if data.nextPageToken
        params = _clone params
        params.nextPageToken = data.nextPageToken
        promise = @listDomains(params)
      else
        promise = Promise.resolve([])
      promise
      .then (domainInfos) -> data.domainInfos.concat(domainInfos)

module.exports = Registrar