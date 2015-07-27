_ = require "underscore"
Promise = require "bluebird"
Read = require "../Read"

class OptimisticLookahead extends Read
  constructor: (input, options, streams, dependencies) ->
    _.defaults input,
      chapterSize: 10
      chapterStart: 1
    super
  execute: ->
    @count = 0
    Promise.bind(@)
    .then @acquireCredential
    .then -> new Promise (resolve, reject) =>
      @reject = reject
      @resolve = resolve
      @chapterPromises = []
      @jumpToChapter(@chapterStart)
      @readChapter()
      return null # don't leak Promise; will resolve manually
    .then -> {count: @count}
  readChapter: ->
    promises = @getChapterPromises()
    promises[0] = promises[0].spread (response, body) ->
  #      return if @isErrorEmitted # should we return here if some other promise has been rejected?
      if @shouldReadNextChapter(response, body) # the last page of current chapter was full of data, so we should read next chapter
        @jumpToChapter(@chapterStart + @chapterSize)
        @readChapter()
      else
        @end()
    @chapterPromises.push(
      Promise.all(promises).bind(@)
      .catch (error) ->
        @reject(error)
    )
  end: ->
    Promise.all(@chapterPromises).bind(@)
    .then -> @out.end()
    .then @resolve
    return null # break infinite loop
  jumpToChapter: (chapterStart) ->
    @chapterStart = chapterStart
    @chapterEnd = chapterStart + @chapterSize - 1
  getChapterPromises: ->
    @readPage(page) for page in [@chapterEnd..@chapterStart] # reverse order, for faster feedback on whether we should read the next chapter
  readPage: (page) ->
    @getPage(page).bind(@)
    .spread (response, body) ->
      for object in body
        @out.write(object)
        @count++
      [response, body]

  shouldReadNextChapter: (response, body) -> throw new Error("Implement me!")
  getPage: (page) -> throw new Error("Implement me!")

module.exports = OptimisticLookahead
