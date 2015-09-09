_ = require "underscore"
Promise = require "bluebird"
Match = require "mtr-match"
errors = require "../helper/errors"

class MemoryLeakTester
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      runner: Function
    _.extend @, options
    _.defaults @,
      previousRss: 0
      currentRss: 0
      currentLoops: 0
      maxLoops: 10000
      currentLoopsWithoutIncrease: 0
      minLoopsWithoutIncrease: 1000 # an empty Promise memory leak has only manifested after ~800 measurements
    _.bindAll @, "loop", "measure"
  execute: ->
    new Promise (resolve, reject) =>
      @resolve = resolve
      @reject = reject
      setTimeout(@loop)
  loop: ->
    result = @runner()
    if result?.then
      result.then @measure
    else
      @measure()
    null
  measure: ->
    memoryUsage = process.memoryUsage()
    @currentRss = memoryUsage.rss
#    console.log @currentRss, @previousRss
    if @currentRss > @previousRss
      console.log @currentLoopsWithoutIncrease
      console.log memoryUsage
      @previousRss = @currentRss
      @currentLoopsWithoutIncrease = 0
    else
      @currentLoopsWithoutIncrease++
      if @currentLoopsWithoutIncrease > @minLoopsWithoutIncrease
        return @resolve(@currentLoops)
    @currentLoops++
    if @currentLoops > @maxLoops - @minLoopsWithoutIncrease # not enough loops left to satisfy the @minLoopsWithoutIncrease condition
      return @reject(new errors.MemoryLeakError())
    else
      # each loop needs to be done on separate Node.js event loop iteration, to free memory allocated by console.log
      setTimeout(@loop)
    null

module.exports = MemoryLeakTester
