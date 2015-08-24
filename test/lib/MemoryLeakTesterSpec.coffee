_ = require "underscore"
Promise = require "bluebird"

MemoryLeakTester = require "../../lib/MemoryLeakTester"

describe "MemoryLeakTester", ->
  @timeout(60000)

  tests =

    "noop":
      isLeaky: false
      runner: ->

    "local var":
      isLeaky: false
      runner: ->
        a = new Array(100000).join("*")

    "global array push with periodic reset":
      isLeaky: false
      runner: ->
        global.array ?= []
        global.array.push new Array(10000).join("*")
        if global.array.length > 234
          global.array = []

    "global array push":
      isLeaky: true
      runner: ->
        global.array ?= []
        global.array.push new Array(10000).join("*")

  for name, test of tests
    do (name, test) ->
      it "should#{if not test.isLeaky then "n't" else ""} report a leak for \"#{name}\"", ->
        tester = new MemoryLeakTester(
          runner: test.runner
        )
        tester.execute().should.be[if not test.isLeaky then "fulfilled" else "rejected"]
