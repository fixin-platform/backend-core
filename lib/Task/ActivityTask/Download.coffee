_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
Match = require "mtr-match"
ActivityTask = require "../ActivityTask"
Read = require "../../Strategy/APIStrategy/Read"
Save = require "../../Strategy/DBStrategy/Save"

class Download extends ActivityTask
  constructor: (input, options, dependencies) ->
    super
    @knex = dependencies.knex

  execute: ->
    @knex.transaction (transaction) =>
      read = @createReadStrategy()
      save = @createSaveStrategy()
      read.on "object", save.insert.bind(save)
      read.on "total", @progressBarSetTotal.bind(@)
      save.on "insert", @progressBarIncCurrent.bind(@, 1)
      Promise.bind(@)
      .then -> @progressBarIncCurrent(0)
      .then -> save.start(transaction)
      .then -> read.execute()
      .then -> save.finish()

  createReadStrategy: -> throw new Error("Implement me!")
  createSaveStrategy: -> throw new Error("Implement me!")


#    read.execute()
#      save: save.execute()
#    readLinks = new Read()
#    readReferers = new Read()
#    saveLink = new Save(
#      bufferTableName: "BitlyLinkUpsertData"
#    )
#    saveReferers = new Save(
#      bufferTableName: "BitlyReferersUpsertData"
#    )
#    readLinks.mapObject = (link) ->
#      Promise.join(
#        @binding.getClicks(link.id).then (clicks) ->
#          link.clicks = clicks
#          saveLink.execute(link)
#      ,
#        @binding.getReferers(link)
#      ,
#        (linkId, referers) ->
#          referer.linkId = linkId for referer in referers
#          saveReferers.execute(referers)
#      )
#
#    readLinks.execute()

module.exports = Download
