class Exception extends Error # Exception is smarter than just an Error. It has *details*.
  constructor: (message, @details) ->
    super message
    for key, value of @details
      @details[key] = value.toJSON() if value.toJSON
    Error.captureStackTrace @, @constructor

module.exports = Exception
