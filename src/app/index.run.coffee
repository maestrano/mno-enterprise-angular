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

  # Load the app name title
  .run(($rootScope, APP_NAME) ->
    $rootScope.app_name = APP_NAME
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

  # Display flash messages from the backend in toastr
  # They're passed this way:
  #   ?flash={"msg":"An error message.","type":"error"}
  .run (toastr, $location) ->
    if flash = $location.search().flash
      message = JSON.parse(flash)
      toastr[message.type](message.msg, _.capitalize(message.type), timeout: 10000)
      $location.search('flash', null) # remove the flash from url

  .run(($rootScope, $timeout, AnalyticsSvc) ->
    $timeout ( -> AnalyticsSvc.init() )

    $rootScope.$on('$stateChangeSuccess', ->
      AnalyticsSvc.update()
    )
  )
