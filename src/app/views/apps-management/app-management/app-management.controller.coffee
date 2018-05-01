angular.module 'mnoEnterpriseAngular'
  .controller('AppManagementCtrl',
    ($q, $state, $scope, toastr, $stateParams, MnoeConfig, MnoeAppInstances, MnoeProvisioning,
      MnoeOrganizations, MnoeCurrentUser, MnoeMarketplace, PRICING_TYPES, ProvisioningHelper,
      AppSettingsHelper) ->

        vm = @
        vm.isLoading = true
        vm.isOrderHistoryLoading = true
        vm.isCurrentSubscriptionLoading = true
        vm.isSubChanged = true

        # TODO: Decide how data sharing status is checked
        vm.dataSharingStatus = ->
          if vm.app.sync_status?.status
            'Connected'
          else
            'Disconnected'

        # Return true if the plan has a dollar value
        vm.pricedPlan = (plan) ->
          ProvisioningHelper.pricedPlan(plan)

        vm.toggleSubscriptionNext = (pricingId) ->
          vm.isSubChanged = vm.currentPlanId == pricingId

        vm.nextSubscription = ->
          MnoeProvisioning.setSubscription(vm.currentSubscription)
          if vm.currentSubscription.product.custom_schema?
            $state.go('home.provisioning.additional_details')
          else
            $state.go('home.provisioning.confirm')

        # ********************** Flags *********************************
        vm.providesStatus = (app) ->
          app.data_sharing || app.subscription

        vm.dataSharingEnabled = ->
          MnoeConfig.isDataSharingEnabled() && vm.app.data_sharing && vm.isAdmin

        vm.manageSubScriptionEnabled = ->
          vm.isAdmin

        vm.orderHistoryEnabled = ->
          vm.isAdmin

        vm.isAddOnSettingShown = ->
          # TODO: Might have to change this to 'product.is_connector_framework'
          #       if products are used instead of app
          AppSettingsHelper.isAddOnSettingShown(vm.app)

        # ********************** Data Load *********************************
        vm.setUserRole = ->
          vm.isAdmin = MnoeOrganizations.role.atLeastAdmin()

        vm.loadCurrentSubScription = (subscriptions) ->
          vm.currentSubscription = _.find(subscriptions, product?.nid == vm.app.app_nid)
          if vm.currentSubscription
            MnoeProvisioning.initSubscription({productNid: null, subscriptionId: vm.currentSubscription.id}).then(
              (response) ->
                vm.orgCurrency = vm.organization?.currency || MnoeConfig.marketplaceCurrency()
                vm.currentSubscription = response

                MnoeMarketplace.findProduct({id: vm.currentSubscription.product?.id, nid: null}).then(
                  (response) ->
                    vm.currentSubscription.product = response

                    # Filters the pricing plans not containing current currency
                    vm.currentSubscription.product.pricing_plans = _.filter(vm.currentSubscription.product.pricing_plans,
                      (pp) ->
                        (pp.pricing_type in PRICING_TYPES['unpriced']) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
                    )
                    vm.currentPlanId = vm.currentSubscription.product_pricing_id
                    console.log 'vm.currentPlan'
                    console.log vm.currentPlan
                )
            ).finally( -> vm.isCurrentSubscriptionLoading = false)
          else
            vm.isCurrentSubscriptionLoading = false

        vm.loadOrderHistory = ->
          MnoeProvisioning.getProductSubscriptions(vm.app.app_id).then(
            (response) ->
              vm.subscriptionsHistory = response
          ).finally( -> vm.isOrderHistoryLoading = false)

        vm.addOnSettingLauch = ->
          AppSettingsHelper.addOnSettingLauch(vm.app)

        # ********************** Initialize *********************************
        vm.init = ->
          vm.setUserRole()

          appPromise = MnoeAppInstances.getAppInstances()
          subPromise = if vm.isAdmin then MnoeProvisioning.getSubscriptions() else null
          userPromise = MnoeCurrentUser.get()

          $q.all({apps: appPromise, subscriptions: subPromise, currentUser: userPromise}).then(
            (response) ->
              vm.app = _.find(response.apps, { id: $stateParams.appId })
              unless vm.app
                toastr.error('mno_enterprise.templates.dashboard.app_management.unavailable')
                $state.go('home.apps-management')
                return

              vm.organization = _.find(response.currentUser.organizations, {id: MnoeOrganizations.selectedId})

              # Manage subscription flow
              vm.loadCurrentSubScription(response.subscriptions)

              # Order Histroy flow
              vm.loadOrderHistory() if vm.isAdmin
          ).finally(-> vm.isLoading = false)


        #====================================
        # Post-Initialization
        #====================================
        $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
          if val?
            vm.isLoading = true
            vm.init()

        return
  )
