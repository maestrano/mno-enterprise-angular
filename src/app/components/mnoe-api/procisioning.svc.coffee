# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', () ->
    _self = @

    provisioningApi = MnoeApiSvc.all('provisioning')


    return
