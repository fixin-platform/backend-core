_ = require "underscore"
Match = require "mtr-match"

class Serializer
  constructor: (options) ->
    Match.check options, Match.ObjectIncluding
      model: Function
    _.extend(@, options)

  toInternal: (externalObject) -> @transform(externalObject, "toInternal")

  toExternal: (internalObject) -> @transform(internalObject, "toExternal")

  forJSONResponse: ->
    transformers = {}
    for column in @model.getColumns()
      if column.getColumnType() is "timestamptz"
        transformers[column.getColumnName()] =
          toInternal: @toDate
          toExternal: @fromDate
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

  toDate: (value) -> new Date(value)
  fromDate: (value) -> value.toISOString()

module.exports = Serializer
