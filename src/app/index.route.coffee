angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider, URI) ->

    $stateProvider
      .state 'home',
        abstract: true
        url: '?dhbRefId'
        templateUrl: 'app/views/layout.html'
        controller: 'LayoutController'
        controllerAs: 'layout'
      .state 'home.apps',
        url: '/apps'
        templateUrl: 'app/views/apps/dashboard-apps-list.html'
        controller: 'DashboardAppsListCtrl'
      .state 'home.impac',
        url: '/impac'
        templateUrl: 'app/views/impac/impac.html'
        controller: 'ImpacController'
      .state 'home.account',
        url: '/account'
        templateUrl: 'app/views/account/account.html'
        controller: 'DashboardAccountCtrl'
        controllerAs: 'vm'
      .state 'home.company',
        url: '/company'
        templateUrl: 'app/views/company/company.html'
        controller: 'DashboardCompanyCtrl'
        controllerAs: 'vm'
      .state 'home.marketplace',
        url: '/marketplace'
        templateUrl: 'app/views/marketplace/marketplace.html'
        controller: 'DashboardMarketplaceCtrl'
        controllerAs: 'vm'
      .state 'home.marketplace.app',
        url: '^/marketplace/:appId'
        views: '@home':
          templateUrl: 'app/views/marketplace/marketplace-app.html'
          controller: 'DashboardMarketplaceAppCtrl'
          controllerAs: 'vm'
      .state 'logout',
        url: '/logout'
        controller: ($window, $http, $translate) ->
          'ngInject'

          # Logout and redirect the user
          $http.delete(URI.logout).then( ->
            $window.location.href = "/#{$translate.use()}#{URI.login}"
          )

    $urlRouterProvider.otherwise '/apps'
