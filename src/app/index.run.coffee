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

  # Configure angular translate depending on the locale used in the path
  .run(($window, $translate, LOCALES) ->
    # Get current path (eg. "/en/dashboard/" or "/dashboard/")
    path = $window.location.pathname

    # Extract the language code if present
    re = /^\/([A-Za-z]{2})\/dashboard\//i
    found = path.match(re)

    if found?
      # Ex found: ["/en/dashboard/", "en", index: 0, input: "/en/dashboard/"]
      locale = found[1]
    else
      # Default language
      locale = LOCALES.preferredLocale

    $translate.use(locale)
  )
