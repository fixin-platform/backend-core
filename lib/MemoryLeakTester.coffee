_ = require "underscore"
Match = require "mtr-match"

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
      minLoopsWithoutIncrease: 1000
  execute: ->
    new Promise (resolve, reject) =>
      @resolve = resolve
      @reject = reject
      setTimeout(@loop.bind(@))
  loop: ->
    @runner()
    @currentRss = process.memoryUsage().rss
    if @currentRss > @previousRss
#      console.log @currentLoopsWithoutIncrease
      @previousRss = @currentRss
      @currentLoopsWithoutIncrease = 0
    else
      @currentLoopsWithoutIncrease++
      if @currentLoopsWithoutIncrease > @minLoopsWithoutIncrease
        return @resolve(@currentLoops)
    @currentLoops++
    if @currentLoops > @maxLoops
      return @reject(new Error("Most probably, this code leaks memory"))
    else
      # each loop needs to be done on separate Node.js event loop iteration, to free memory allocated by console.log
      setTimeout(@loop.bind(@))

module.exports = MemoryLeakTester
