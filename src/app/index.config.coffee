angular.module 'mnoEnterpriseAngular'

  .config(($logProvider, toastrConfig) ->
    'ngInject'

    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.timeOut = 5000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = true
    toastrConfig.progressBar = true
  )

  .config(($httpProvider) ->
    'ngInject'

    $httpProvider.defaults.headers.common['Accept'] = 'application/json'
    $httpProvider.defaults.headers.common['Content-Type'] = 'application/json'

    if token = $("meta[name='csrf-token']").attr("content")
      $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    return $httpProvider
  )

  .config ($httpProvider) ->
    $httpProvider.interceptors.push ($q, $window, $injector, $log) ->
      {
        responseError: (rejection) ->
          toastr = $injector.get('toastr')

          switch rejection.status
            # Unauthenticated
            when 401
              # Redirect to login page
              console.log "User is not connected!"
              $window.location.href = '/'

            # Password expired
            when 403
              if rejection.data.error && rejection.data.error == "Your password is expired. Please renew your password."
                $log.info('[PasswordExpiredInterceptor] Password Expired!')
                $window.location.href = "/mnoe/auth/users/password_expired"
                # return an empty promise to skip all chaining promises
                return $q.defer().promise
              else
                return $q.reject(rejection)

            # Redirect to an error page when MnoHub is not available
            when 429, 503
              $log.info('[MnoHubErrorInterceptor] MnoHub error, redirecting to error page')
              $window.location.href = "/mnoe/errors/#{rejection.status}"
              toastr.error("errors.#{rejection.status}.description", "errors.#{rejection.status}.title")
              return $q.defer().promise

            else
              $q.reject rejection
      }

  .config(($sceDelegateProvider) ->
    'ngInject'

    # Configure SCE to authorize the Maestrano domains
    # (see: https://docs.angularjs.org/api/ng/provider/$sceDelegateProvider)
    $sceDelegateProvider.resourceUrlWhitelist([
      # Allow same origin resource loads.
      'self'
    ])
  )

  .config(($translateProvider, LOCALES) ->
    # Path to translations files
    $translateProvider.useStaticFilesLoader({
      files: [
        {
          prefix: 'locales/',
          suffix: '.locale.json'
        },
        {
          prefix: 'locales/impac/',
          suffix: '.json'
        }
      ]
    })

    $translateProvider.fallbackLanguage(LOCALES.fallbackLanguage)
    $translateProvider.useSanitizeValueStrategy('sanitizeParameters')
    $translateProvider.useMessageFormatInterpolation()

    # TODO: Activate in "developer mode" only (spams the console and makes the application lag)
    #$translateProvider.useMissingTranslationHandlerLog()
  )
