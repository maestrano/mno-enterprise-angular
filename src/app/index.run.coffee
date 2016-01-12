angular.module 'mnoEnterpriseAngular'
  # Impac configuration
  .run((ImpacLinking, ImpacConfigSvc) ->
    data =
      user: ImpacConfigSvc.getUserData
      organizations: ImpacConfigSvc.getOrganizations

    ImpacLinking.linkData(data)
  )

  # xeditable-anugular configuration
  .run((editableOptions) ->
    # bootstrap3 theme. Can be also 'bs2', 'default'
    editableOptions.theme = 'bs3'
  )

  # Force the page to scroll to top when a view change
  .run(($rootScope) ->
    $rootScope.$on('$viewContentLoaded', ->
      window.scrollTo(0, 0)
    )
  )
