angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeAuthSvc', (Restangular, inflector) ->
    return Restangular.withConfig((RestangularProvider) ->
      RestangularProvider.setBaseUrl('/mnoe/auth')
      RestangularProvider.setDefaultHeaders({Accept: "application/json"})
    )
