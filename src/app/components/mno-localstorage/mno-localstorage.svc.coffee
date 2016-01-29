# -------------------------------------------------------------------------------- #
# ############################ Local Storage Service ############################# #
#
# Wrapper for existing localStorage methods, and methods providing additional functionality
# such as the ability to return a default value when getting a collection from cache.
# -------------------------------------------------------------------------------- #
angular.module 'mnoEnterpriseAngular'
  .service 'MnoLocalStorage', ($window, $log) ->

    # warning logging function
    _warning = (key) ->
      return unless key
      messages =
        parse_error: "cannot fromJson undefined values"
        setobject_error: "LocalStorage is disabled"
      $log.warn "LocalStorage Service Warning: " + messages[key]

    @set = (key, value) ->
      try
        $window.localStorage[key] = value
      catch e
        _warning('setobject_error')

    @get = (key, defaultValue) ->
      ret
      try
        ret = angular.fromJson($window.localStorage[key])
      catch e
        _warning('parse_error')
        ret = $window.localStorage[key]
      return ret or defaultValue

    @setObject = (key, value) ->
      _warning('parse_error') if typeof value == 'undefined'
      try
        $window.localStorage[key] = angular.toJson(value or {})
      catch e
        _warning('setobject_error')

    @getObject = (key, defaultValue) ->
      angular.fromJson($window.localStorage[key]) or defaultValue or {}

    @getKeys = ->
      keys = []
      i = 0
      while i < $window.localStorage.length
        keys.push $window.localStorage.getItem($window.localStorage.key(i))
        ++i
      return keys

    @removeItem = (key) ->
      $window.localStorage.removeItem key

    @clear = ->
      $window.localStorage.clear()

    return
