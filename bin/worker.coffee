#!/usr/bin/env coffee

path = require "path"
yargs = require "yargs"
WorkerFactory = require "../lib/WorkerFactory"

argv = yargs
  .usage('Usage: $0 [options] pathToJob1 ... pathToJobN')
  .options(
    "a":
      alias: "addr"
      type: "string"
      demand: true
      default: "tcp://localhost:55550"
    "i":
      alias: "api"
      type: "string"
      demand: true
  )
  .demand(1)
  .argv

jobs = {}
for jobPath in argv._
  name = path.parse(jobPath).name
  jobs[name] = require jobPath

worker = WorkerFactory.create(argv.addr, argv.api, {}, jobs)
worker.on "error", (msg) ->
  console.error(msg)
  switch msg
    when "ERR_MSG_TYPE_INVALID", "ERR_MSG_HEADER" # internal worker errors
      # winter is coming... don't shutdown just yet
    else
      process.exit(1) # something really bad happened, let's restart
worker.start()