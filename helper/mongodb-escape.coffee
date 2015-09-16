_ = require "underscore"

mongodbEscape = (object) ->
  object = _.clone(object)
  if _.isObject(object)
    for oldKey, value of object
      newKey = oldKey.replace(/\./g, "__dot__").replace(/\$/g, "__dollar__")
      delete object[oldKey] if newKey isnt oldKey
      object[newKey] = mongodbEscape(value)
  else if _.isArray(object)
    for element, i in object
      object[i] = mongodbEscape(element)
  object

module.exports = mongodbEscape
