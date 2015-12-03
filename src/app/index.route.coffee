angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'
    $stateProvider
      .state 'home',
        abstract: true
        templateUrl: 'app/views/layout.html'
        controller: 'LayoutController'
        controllerAs: 'layout'
      .state 'home.app-list',
        url: '/apps'
        templateUrl: 'app/views/dashboard-apps-list/dashboard-apps-list.html'
        controller: 'DashboardAppsListCtrl'
      .state 'home.impac',
        url: '/impac'
        templateUrl: 'app/views/impac/impac.html'
        controller: 'ImpacController'
      .state 'home.account',
        url: '/account'
        templateUrl: 'app/views/account/account.html'
        controller: 'DashboardAccountCtrl'
      .state 'home.company',
        url: '/company'
        templateUrl: 'app/views/company/company.html'
        controller: 'DashboardCompanyCtrl'
      .state 'home.marketplace',
        url: '/marketplace'
        templateUrl: 'app/views/marketplace/marketplace.html'
        controller: 'DashboardMarketplaceCtrl'
        controllerAs: 'vm'

    $urlRouterProvider.otherwise '/apps'
