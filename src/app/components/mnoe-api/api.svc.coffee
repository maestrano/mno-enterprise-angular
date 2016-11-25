angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeApiSvc', (Restangular, inflector) ->
    return Restangular.withConfig((RestangularProvider) ->
      RestangularProvider.setBaseUrl('/mnoe/jpi/v1')
      RestangularProvider.setDefaultHeaders({Accept: "application/json"})
      # Unwrap api response
      RestangularProvider.addResponseInterceptor(
        (data, operation, what, url, response, deferred) ->
          extractedData = null
          # If the what starts with a '/', return the data as it is
          # Used if the payload is not correctly formatted
          # (eg. MnoeApiSvc.oneUrl('/marketplace'))
          if (_.startsWith(what, '/'))
            extractedData = data
          # On getList extract and restangularize the objects list
          else if (operation == 'getList')
            extractedData = data[what]
          # Extract and restangularize the object
          else if (operation == 'get' || operation == 'post' || operation == 'put')
            what = inflector.singularize(what)
            extractedData = data[what]
          else
            extractedData = data
          return extractedData
      )
    )
