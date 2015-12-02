angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeApiSvc', (Restangular) ->
    return Restangular.withConfig((RestangularProvider) ->
      RestangularProvider.setBaseUrl('/mnoe/jpi/v1')
      RestangularProvider.setDefaultHeaders({Accept: "application/json"})

      # Unwrap api response
      RestangularProvider.addResponseInterceptor(
        (data, operation, what, url, response, deferred) ->
          extractedData = null
          if (operation == 'getList' || operation == 'get')
            extractedData = data[what]
          else if (operation == 'put' || operation == 'post')
            what = inflector.singularize(what)
            extractedData = data[what]
          else
            extractedData = data
          return extractedData
      )
    )
