angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider, URI, I18N_CONFIG, MARKETPLACE_CONFIG) ->

    $stateProvider
      .state 'home',
        data:
          pageTitle:'Home'
        abstract: true
        url: '?dhbRefId'
        templateUrl: 'app/views/layout.html'
        controller: 'LayoutController'
        controllerAs: 'layout'
      .state 'home.apps',
        data:
          pageTitle:'Apps'
        url: '/apps'
        templateUrl: 'app/views/apps/dashboard-apps-list.html'
        controller: 'DashboardAppsListCtrl'
      .state 'home.impac',
        data:
          pageTitle:'Impac'
        url: '/impac'
        templateUrl: 'app/views/impac/impac.html'
        controller: 'ImpacController'
        controllerAs: 'vm'
      .state 'home.account',
        data:
          pageTitle:'Account'
        url: '/account'
        templateUrl: 'app/views/account/account.html'
        controller: 'DashboardAccountCtrl'
        controllerAs: 'vm'
      .state 'home.company',
        data:
          pageTitle:'Company'
        url: '/company'
        templateUrl: 'app/views/company/company.html'
        controller: 'DashboardCompanyCtrl'
        controllerAs: 'vm'
      .state 'logout',
        url: '/logout'
        controller: ($window, $http, $translate, AnalyticsSvc, URL_CONFIG) ->
          'ngInject'

          # Logout and redirect the user
          $http.delete(URI.logout).then( ->
            AnalyticsSvc.logOut()

            logout_url = URL_CONFIG.after_sign_out_url || URI.login

            if I18N_CONFIG.enabled
              if URL_CONFIG.after_sign_out_url
                $window.location.href = logout_url
              else
                $window.location.href = "/#{$translate.use()}#{URI.login}"
            else
              $window.location.href = logout_url
          )

    if MARKETPLACE_CONFIG.enabled
      $stateProvider
        .state 'home.marketplace',
          data:
            pageTitle:'Marketplace'
          url: '/marketplace'
          templateUrl: 'app/views/marketplace/marketplace.html'
          controller: 'DashboardMarketplaceCtrl'
          controllerAs: 'vm'
        .state 'home.marketplace.app',
          data:
            pageTitle:'Marketplace-App'
          url: '^/marketplace/:appId'
          views: '@home':
            templateUrl: 'app/views/marketplace/marketplace-app.html'
            controller: 'DashboardMarketplaceAppCtrl'
            controllerAs: 'vm'
        .state 'home.marketplace.compare',
          data:
            pageTitle:'Compare apps'
          url: '^/marketplace/apps/compare'
          views: '@home':
            templateUrl: 'app/views/marketplace/marketplace-compare.html'
            controller: 'DashboardMarketplaceCompareCtrl'
            controllerAs: 'vm'

    $urlRouterProvider.otherwise '/impac'
