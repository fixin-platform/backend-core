_ = require "underscore"
Promise = require "bluebird"
stream = require "readable-stream"
Match = require "mtr-match"
ActivityTask = require "../ActivityTask"
Read = require "../../Strategy/APIStrategy/Read"
Save = require "../../Strategy/DBStrategy/Save"

class Download extends ActivityTask
  execute: ->
    read = @createReadStrategy()
    save = @createSaveStrategy()
    save.on "ready", read.execute.bind(read)
    read.on "object", save.insert.bind(save)
    save.on "insert", @progressBarIncCurrent.bind(@, 1)
    read.on "total", @progressBarSetTotal.bind(@)
    Promise.bind(@)
    .then -> @progressBarIncCurrent(0)
    .then -> save.execute()

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
