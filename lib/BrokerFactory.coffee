_ = require "underscore"
pigato = require "pigato"

module.exports =
  create: (addr, conf = {}) ->
    broker = new pigato.Broker(addr, conf)
    broker

