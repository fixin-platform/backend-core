typecast = require "typecast"

typecast.integer = (value) -> parseInt(value, 10) or 0
typecast.float = (value) -> parseFloat(value) or 0

module.exports = typecast