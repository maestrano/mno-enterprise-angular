angular.module 'mnoEnterpriseAngular'
  .config ($stateProvider, $urlRouterProvider, URI, I18N_CONFIG, MnoeConfigProvider) ->

    $stateProvider
      .state 'public',
        abstract: true
        templateUrl: 'app/views/public/public.html'
        controller: 'PublicController'
        controllerAs: 'layout'
        public: true
        onEnter: ($rootScope) ->
          $rootScope.publicPage = true
        onExit: ($rootScope) ->
          $rootScope.publicPage = false
      .state 'public.landing',
        data:
          pageTitle: "Webstore Preview"
        url: '/landing'
        templateUrl: 'app/views/public/landing/landing.html'
        controller: 'LandingCtrl'
        controllerAs: 'vm'
        public: true
      .state 'public.product',
        data:
          pageTitle: "Product Preview"
        url: '/product/:appId'
        templateUrl: 'app/components/mno-apps/mno-app.html'
        controller: 'mnoApp'
        controllerAs: 'vm'
        resolve: {
          isPublic: -> true
          parentState: -> 'public.landing'
        }
        public: true
      .state 'public.local_product',
        data:
          pageTitle: "Reseller's Product Preview"
        url: '/localproduct/:productId'
        templateUrl: 'app/components/mno-local-products/mno-local-product.html',
        controller: 'mnoLocalProduct'
        controllerAs: 'vm'
        resolve: {
          isPublic: -> true
          parentState: -> 'public.landing'
        }
        public: true
      .state 'home',
        data:
          pageTitle:'Home'
        abstract: true
        url: '?dhbRefId'
        templateUrl: 'app/views/layout.html'
        controller: 'LayoutController'
        controllerAs: 'layout'
        resolve:
          loginRequired: (MnoeCurrentUser) ->
            MnoeCurrentUser.loginRequired()
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
          resolve:
            loginRequired: (MnoeCurrentUser) ->
              MnoeCurrentUser.loginRequired()
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
            templateUrl: 'app/components/mno-apps/mno-app.html',
            controller: 'mnoApp'
            controllerAs: 'vm'
            resolve: {
              isPublic: -> false
              parentState: -> 'home.marketplace'
            }
        .state 'home.marketplace.local_product',
          data:
            pageTitle: "Marketplace"
          url: '^/marketplace/localproduct/:productId'
          views: '@home':
            templateUrl: 'app/components/mno-local-products/mno-local-product.html',
            controller: 'mnoLocalProduct'
            controllerAs: 'vm'
            resolve: {
              isPublic: -> false
              parentState: -> 'home.marketplace'
            }
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
          url: '/order/?nid&id&editing'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/order.html'
            controller: 'ProvisioningOrderCtrl'
            controllerAs: 'vm'
        .state 'home.provisioning.additional_details',
          data:
            pageTitle:'Purchase - Additional details'
          url: '/details/?nid&id'
          views: '@home.provisioning':
            templateUrl: 'app/views/provisioning/details.html'
            controller: 'ProvisioningDetailsCtrl'
            controllerAs: 'vm'
        .state 'home.provisioning.confirm',
          data:
            pageTitle:'Purchase - Confirm'
          url: '/confirm/?nid&id'
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
        .state 'home.subscription',
          data:
            pageTitle:'Subscription details'
          url: '/subscriptions/:id'
          templateUrl: 'app/views/provisioning/subscription.html'
          controller: 'ProvisioningSubscriptionCtrl'
          controllerAs: 'vm'

    $urlRouterProvider.otherwise ($injector, $location) ->
      MnoeConfig = $injector.get('MnoeConfig')
      MnoeCurrentUser = $injector.get('MnoeCurrentUser')
      MnoeOrganizations = $injector.get('MnoeOrganizations')
      MnoeAppInstances = $injector.get('MnoeAppInstances')
      $window = $injector.get('$window')

      MnoeCurrentUser.get().then(
        (response) ->
          # Same as MnoeCurrentUser.loginRequired
          unless response.logged_in
            if MnoeConfig.arePublicApplicationsEnabled()
              $location.url('/landing')
            else
              $window.location = URI.login
          else
            if MnoeConfig.isOnboardingWizardEnabled()
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
            else
              $location.url('/impac')
      )
