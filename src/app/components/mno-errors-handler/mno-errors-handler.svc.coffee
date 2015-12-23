# Service to manage errors from RoR API on forms
angular.module 'mnoEnterpriseAngular'
  .factory 'MnoErrorsHandler', ($log) ->
    mnoErrorHandler = {}

    errorCache = null

    mnoErrorHandler.processServerError = (serverError, form) ->
      return if _.startsWith(serverError.data, '<!DOCTYPE html>')
      if 400 <= serverError.status <= 499 # Error in the request
        # Save the errors object in the scope
        errorCache = serverError
        # Set each error fields as not valid
        _.each errorCache.data, (errors, key) ->
          _.each errors, ->
            if form[key]?
              form[key].$setValidity 'server', false
            else
              $log.error('MnoErrorsHandler: cannot find field:' + key)

    mnoErrorHandler.errorMessage = (name) ->
      result = []
      if errorCache?
        _.each errorCache.data[name], (msg) ->
          result.push msg
      result.join ', '

    mnoErrorHandler.resetErrors = (form) ->
      if errorCache?
        _.each errorCache.data, (errors, key) ->
          _.each errors, ->
            if form[key]?
              form[key].$setValidity 'server', null
        errorCache = null

    mnoErrorHandler.onlyServerError = (form) ->
      # Check if there is errors that are not server type
      (_.every form.$error, (v, k) -> k == 'server')

    return mnoErrorHandler
