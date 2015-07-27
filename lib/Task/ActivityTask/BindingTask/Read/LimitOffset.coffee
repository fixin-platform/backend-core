_ = require "underscore"
Promise = require "bluebird"
Read = require "../Read"

class LimitOffset extends Read
  constructor: (input, options, dependencies) ->
    _.defaults input,
      limit: 100
      offset: 0
    super

  getTotalParams: -> throw new Error("Implement me!")
  getTotalRequest: (params) -> throw new Error("Implement me!")
  extractTotalFromResponse: (response, body) -> throw new Error("Implement me!")
  getPageParams: (limit, offset) -> throw new Error("Implement me!")
  getPageRequest: (params) -> throw new Error("Implement me!")

  execute: ->
    Promise.bind(@)
    .then @acquireCredential
    .then @getTotal
    .then @progressInit
    .then @readChapter
    .all()
    .then -> @out.end()
    .then -> {}

  readChapter: (total) ->
    offset = @offset
    pages = []
    while offset <= total
      pages.push @readPage(@limit, offset)
      offset += @limit
    pages

  getTotal: ->
    params = @getTotalParams()
    @info "LimitOffset:getTotalRequest", @details({params: params})
    @getTotalRequest(params).bind(@)
    .spread (response, body) ->
      @info "LimitOffset:getTotalResponse", @details({params: params, response: response.toJSON(), body: body})
      @extractTotalFromResponse(response, body)

  readPage: (limit, offset) ->
    params = @getPageParams(limit, offset)
    @info "LimitOffset:readPageRequest", @details({params: params})
    @getPageRequest(params).bind(@)
    .spread (response, body) ->
      @info "LimitOffset:readPageResponse", @details({params: params, response: response.toJSON(), body: body})
      @out.write(object) for object in body
      [response, body]

module.exports = LimitOffset
