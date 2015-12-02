angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganization', ($log, $q, MnoeApiSvc ) ->
    _self = @

    organizationApi = MnoeApiSvc.all('organizations')

    getAppInstances = (organizationId) ->


    return @
