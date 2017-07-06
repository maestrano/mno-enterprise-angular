angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider, URI, I18N_CONFIG, MnoeConfigProvider) ->

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

    if MnoeConfigProvider.$get().isOnboardingWizardEnabled()
      $stateProvider
        .state 'onboarding',
          abstract: true
          url: '/onboarding'
          templateUrl: 'app/views/onboarding/layout.html'
          controller: 'OnboardingController'
          controllerAs: 'onboarding'
        .state 'onboarding.step1',
          data:
            pageTitle:'Welcome'
          url: '/welcome'
          templateUrl: 'app/views/onboarding/step1.html'
          controller: 'OnboardingStep1Controller'
          controllerAs: 'vm'
        .state 'onboarding.step2',
          data:
            pageTitle:'Select your apps'
          url: '/select-apps'
          templateUrl: 'app/views/onboarding/step2.html'
          controller: 'OnboardingStep2Controller'
          controllerAs: 'vm'
        .state 'onboarding.step3',
          data:
            pageTitle:'Connect your apps'
          url: '/connect-app'
          templateUrl: 'app/views/onboarding/step3.html'
          controller: 'OnboardingStep3Controller'
          controllerAs: 'vm'

    if MnoeConfigProvider.$get().isMarketplaceEnabled()
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
            pageTitle:'Marketplace'
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

    if MnoeConfigProvider.$get().isProvisioningEnabled()
      $stateProvider
        .state 'home.provisioning',
          abstract: true
          templateUrl: 'app/views/provisioning/layout.html'
          url: '/provisioning'
        .state 'home.provisioning.order',
          data:
            pageTitle:'Purchase - Order'
          url: '/order/?nid&id'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/order.html'
            controller: 'ProvisioningOrderCtrl'
            controllerAs: 'vm'
        .state 'home.provisioning.additional_details',
          data:
            pageTitle:'Purchase - Additional details'
          url: '/details/'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/details.html'
            controller: 'ProvisioningDetailsCtrl'
            controllerAs: 'vm'
        .state 'home.provisioning.confirm',
          data:
            pageTitle:'Purchase - Confirm'
          url: '/confirm/'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/confirm.html'
            controller: 'ProvisioningConfirmCtrl'
            controllerAs: 'vm'
        .state 'home.provisioning.order_summary',
          data:
            pageTitle:'Purchase - Order summary'
          url: '/summary/'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/summary.html'
            controller: 'ProvisioningSummaryCtrl'
            controllerAs: 'vm'
        .state 'home.subscriptions',
          data:
            pageTitle:'Subscriptions summary'
          url: '/subscriptions'
          templateUrl: 'app/views/provisioning/subscriptions.html'
          controller: 'ProvisioningSubscriptionsCtrl'
          controllerAs: 'vm'

    $urlRouterProvider.otherwise ($injector, $location) ->
      unless $injector.get('MnoeConfig').isOnboardingWizardEnabled()
        $location.url('/impac')
        return

      MnoeOrganizations = $injector.get('MnoeOrganizations')
      MnoeAppInstances = $injector.get('MnoeAppInstances')

      MnoeOrganizations.getCurrentOrganisation().then(
        ->
          MnoeAppInstances.getAppInstances().then(
            (response) ->
              if _.isEmpty(response)
                $location.url('/onboarding/welcome')
              else
                $location.url('/impac')
          )
      )
