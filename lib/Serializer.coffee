_ = require "underscore"
Match = require "mtr-match"
moment = require "moment"

class Serializer
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      model: Function
    _.extend @, options
    _.defaults @,
      keymap = @keymap()
      key:
        toInternal: _.compose @dereference.bind(@, keymap)
        toExternal: _.compose @dereference.bind(@, _.invert keymap)
      values: @forJSONResponse()

  toInternal: (externalObject) -> @transform(externalObject, "toInternal")

  toExternal: (internalObject) -> @transform(internalObject, "toExternal")

  # an external object identifier field may be called "id", which conflicts with our PostgreSQL "id" field
  keymap: -> throw new Error("Implement me! At the very least, map the external object identifier field and internal object _uid field")

  forJSONResponse: ->
    transformers = {}
    for column in @model.getColumns()
      if column.getColumnType() is "timestamptz"
        transformers[column.getColumnName()] =
          toInternal: @toDate.bind(@)
          toExternal: @fromDate.bind(@)
    transformers

  transform: (source, direction) ->
    destination = {}
    for sourceKey, sourceValue of source
      destinationKey = @key[direction](sourceKey)
      valueTransformer = @values[if direction is "toExternal" then sourceKey else destinationKey]
      destinationValue = if valueTransformer then valueTransformer[direction](sourceValue) else sourceValue
      destination[destinationKey] = destinationValue
    destination

  dereference: (keymap, name) -> keymap[name] or name

  toDate: (value) -> moment(value, @dateFormat()).toDate()
  fromDate: (value) -> moment(value).format(@dateFormat())
  dateFormat: -> throw new Error("Implement me!")

module.exports = Serializer
