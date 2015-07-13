#!/usr/bin/env coffee

{EventEmitter} = require "events"

class MyEmitter extends EventEmitter
  constuctor: ->
  do: (arg) ->
    @emit("hey", arg)

emitter = new MyEmitter()
emitter.do("one")
emitter.on "hey", (arg) ->
  console.log arg
emitter.do("two")