memwatch = require "memwatch-next"
util = require "util"

module.exports =
  memwatch: memwatch
  start: -> new memwatch.HeapDiff()
  end: (hd) -> console.log util.inspect hd.end(), {depth: null}
