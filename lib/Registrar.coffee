_ = require "underscore"
Promise = require "bluebird"
AWS = require "aws-sdk"
Match = require "mtr-match"

class Registrar
  constructor: (options, config) ->
    _.extend @, options
    Match.check config,
      accessKeyId: String
      secretAccessKey: String
      region: String
    @swf = Promise.promisifyAll new AWS.SWF _.extend
      apiVersion: "2012-01-25"
    , config
  ensureAll: ->
    Promise.bind(@)
    .then @registerAllDomains
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