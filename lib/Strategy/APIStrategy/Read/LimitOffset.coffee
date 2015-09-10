_ = require "underscore"
Promise = require "bluebird"
Read = require "../Read"

# It seems like this algorithm hangs for a while, then dump all downloaded info, but under heavy load, it dumps steadily, so most probably it's just some issue with stdout flush delay (caching or something)
class LimitOffset extends Read
  constructor: (input, dependencies) ->
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
    .then @readChapter

  readChapter: (total) ->
    offset = @offset
    pages = []
    while offset <= total
      pages.push [@limit, offset]
      offset += @limit
    Promise.resolve(pages).bind(@)
    .map (args) ->
      @readPage(args...)
    , {concurrency: 10}

  getTotal: ->
    params = @getTotalParams()
    @verbose "LimitOffset:getTotalRequest", @details({params: params})
    @getTotalRequest(params).bind(@)
    .spread (response, body) ->
      @verbose "LimitOffset:getTotalResponse", @details({params: params, response: response.toJSON(), body: body})
      total = @extractTotalFromResponse(response, body)
      @emit("total", total)
      .thenReturn(total)

  readPage: (limit, offset) ->
    params = @getPageParams(limit, offset)
    @verbose "LimitOffset:readPageRequest", @details({params: params})
    @getPageRequest(params).bind(@)
    .spread (response, body) ->
      @verbose "LimitOffset:readPageResponse", @details({params: params, response: response.toJSON(), body: body})
      Promise.all(@emit("object", object) for object in body)
      .thenReturn([response, body])

module.exports = LimitOffset
