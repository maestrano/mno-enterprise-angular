angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeFullApiSvc', (Restangular, MnoeApiSvc, inflector) ->
    return MnoeApiSvc.withConfig((RestangularProvider) ->
      RestangularProvider.setFullResponse(true)
    )
