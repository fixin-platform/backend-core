_ = require "underscore"
Promise = require "bluebird"

MemoryLeakTester = require "../../lib/MemoryLeakTester"

describe "MemoryLeakTester", ->
  @timeout(10000000)

  patterns =

    "noop @plain":
      isLeaky: false
      options:
        maxLoops: 100000
        minLoopsWithoutIncrease: 20000
        runner: ->

    "noop @promise":
      isLeaky: false
      options:
        maxLoops: 100000
        minLoopsWithoutIncrease: 20000
        runner: ->
          Promise.resolve()

    "local var @promise":
      isLeaky: false
      options:
        maxLoops: 100000
        minLoopsWithoutIncrease: 20000
        runner: ->
          Promise.resolve()
          .then ->
            a = new Array(100000).join("*")
            null

    "global array push with periodic reset @promise":
      isLeaky: false
      options:
        maxLoops: 100000
        runner: ->
          Promise.resolve()
          .then ->
            global.array ?= []
            global.array.push new Array(10000).join("*")
            if global.array.length > 234
              global.array = []

    "global array push @promise":
      isLeaky: true
      options:
        runner: ->
          Promise.resolve()
          .then ->
            global.array ?= []
            global.array.push new Array(10000).join("*")

  for name, pattern of patterns
    do (name, pattern) ->
      it "should#{if not pattern.isLeaky then "n't" else ""} report a leak for #{name} @slow", ->
        tester = new MemoryLeakTester(pattern.options)
        promise = tester.execute()
        if not pattern.isLeaky
          promise
        else
          promise
          .then -> reject(new Error("Expected the MemoryLeakTester to report a leak, but it didn't"))
          .catch (error) -> should.exist(error)
#        tester.execute().should.be[if not pattern.isLeaky then "fulfilled" else "rejected"]
