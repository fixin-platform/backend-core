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
    .then @ensureAllDomains
  ensureAllDomains: ->
    Promise.join(
      @listDomains({registrationStatus: "REGISTERED"}),
      @listDomains({registrationStatus: "DEPRECATED"}),
      (registeredDomains, deprecatedDomains) ->
        registeredDomains.concat(deprecatedDomains)
    )
    .bind(@)
    .then (existingDomains) ->
      existingDomainNames = _.pluck existingDomains, "name"
      Promise.all(@swf.registerDomainAsync(domain) for domain in @domains when domain.name not in existingDomainNames)
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