angular.module 'mnoEnterpriseAngular'
  .run(($log) ->
    'ngInject'
    $log.debug 'runBlock end'
  )
  .run((ImpacLinking, ImpacConfigSvc) ->
    'ngInject'

    data =
      user: ImpacConfigSvc.getUserData
      organizations: ImpacConfigSvc.getOrganizations

    ImpacLinking.linkData(data)
  )

