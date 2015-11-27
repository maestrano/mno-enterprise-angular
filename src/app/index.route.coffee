angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'
    $stateProvider
      .state 'home',
        abstract: true
        templateUrl: 'app/views/layout.html'
        controller: 'LayoutController'
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

    $urlRouterProvider.otherwise '/apps'
