angular.module 'mnoEnterpriseAngular'
  .config(($logProvider, toastrConfig) ->
    'ngInject'

    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.allowHtml = true
    toastrConfig.timeOut = 3000
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

  .config(($sceDelegateProvider) ->
    'ngInject'

    # Configure SCE to authorize the Maestrano domains
    #$sceProvider.enabled(false);
    $sceDelegateProvider.resourceUrlWhitelist([
        # Allow same origin resource loads.
        'self'
        # Allow UAT asset server
        #'https://assets-apse1-uat-maestrano.s3.amazonaws.com/assets/**',
        # Allow UAT Cloudfront distribution
        #'https://dbu1g4tv4k5kk.cloudfront.net/web/mno/assets/**',
        # Allow PROD asset server
        #'https://assets-apse1-prd-maestrano.s3.amazonaws.com/assets/**',
        # Allow PROD Cloudfront distribution
        #'https://cdn.maestrano.com/web/mno/assets/**'
    ])
  )
