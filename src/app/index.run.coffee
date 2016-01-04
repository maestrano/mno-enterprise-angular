angular.module 'mnoEnterpriseAngular'
  .run((ImpacLinking, ImpacConfigSvc) ->
    data =
      user: ImpacConfigSvc.getUserData
      organizations: ImpacConfigSvc.getOrganizations

    ImpacLinking.linkData(data)
  )
  .run((editableOptions) ->
    editableOptions.theme = 'bs3'
  )
