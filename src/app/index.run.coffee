angular.module 'mnoEnterpriseAngular'

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

  # Override the default toastr template to use angular-translate
  .run(($templateCache) ->
    $templateCache.put('directives/toast/toast.html', '''
      <div class="{{toastClass}} {{toastType}}" ng-click="tapToast()">
        <div ng-switch on="allowHtml">
          <div ng-switch-default ng-if="title" class="{{titleClass}}" aria-label="{{title | translate}}">{{title | translate:extraData}}</div>
          <div ng-switch-default class="{{messageClass}}" aria-label="{{message | translate:extraData}}">{{message | translate:extraData}}</div>
          <div ng-switch-when="true" ng-if="title" class="{{titleClass}}" ng-bind-html="title | translate:extraData"></div>
          <div ng-switch-when="true" class="{{messageClass}}" ng-bind-html="message | translate:extraData"></div>
        </div>
        <progress-bar ng-if="progressBar"></progress-bar>
      </div>
      '''
    )
  )

  # Display flash messages from the backend in toastr
  # They're passed this way:
  #   ?flash={"msg":"An error message.","type":"error"}
  .run((toastr, $location) ->
    if flash = $location.search().flash
      message = JSON.parse(flash)
      toastr[message.type](message.msg, _.capitalize(message.type), timeout: 10000)
      $location.search('flash', null) # remove the flash from url
  )

  .run(($rootScope, $timeout, AnalyticsSvc) ->
    $timeout ( -> AnalyticsSvc.init() )

    $rootScope.$on('$stateChangeSuccess', ->
      AnalyticsSvc.update()
    )
  )
  .run(($timeout, MnoeConfig, Notifications) ->
    if MnoeConfig.isNotificationsEnabled()
      $timeout ( -> Notifications.init() )
  )
  # App initialization: Retrieve current user and current organization, then preload marketplace
  .run(($rootScope, $q, $location, $stateParams, MnoeCurrentUser, MnoeOrganizations, MnoeMarketplace, MnoeAppInstances) ->

    _self = this

    # Hide the layout with a loader
    $rootScope.isLoggedIn = false

    # Load the current user
    userPromise = MnoeCurrentUser.get()

    # Load the current organization if defined (url param, cookie or first)
    _self.appInstancesDeferred = $q.defer()
    orgPromise = MnoeOrganizations.getCurrentOrganisation().then(
      (response) ->
        # App instances needs to be run after fetching the organization (At least the first call)
        MnoeAppInstances.getAppInstances().then(
          (appInstances) ->
            _self.appInstancesDeferred.resolve(appInstances)
        )

        response
    )

    $q.all([userPromise, orgPromise, _self.appInstancesDeferred.promise]).then(
      ->
        # Display the layout
        $rootScope.isLoggedIn = true

        # Pre-load the market place
        MnoeMarketplace.getApps()
    ).catch(
      ->
        # Display the layout
        $rootScope.isLoggedIn = true

        # Display no organisation message
        $rootScope.hasNoOrganisations = true
    )
  )
