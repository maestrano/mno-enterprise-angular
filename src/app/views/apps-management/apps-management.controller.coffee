angular.module 'mnoEnterpriseAngular'
  .controller('AppsManagementCtrl',
    ($q, $scope, MnoeConfig, MnoeProductInstances, MnoeProvisioning, MnoeOrganizations) ->

      vm = @
      vm.isLoading = true

      vm.providesStatus = (product) ->
        vm.dataSharingEnabled(product) || product.subscription

      vm.dataSharingEnabled = (product) ->
        MnoeConfig.isDataSharingEnabled() && product.data_sharing

      vm.dataSharingStatus = (product) ->
        if product.sync_status?.attributes?.status
          'Connected'
        else
          'Disconnected'

      vm.subscriptionStatus = (product) ->
        return product.subscription.status if product.subscription

      vm.appActionUrl = (product) ->
        "/mnoe/launch/#{product.uid}"

      vm.init = ->
        productPromise = MnoeProductInstances.getProductInstances()
        subPromise = if MnoeOrganizations.role.atLeastAdmin() then MnoeProvisioning.getSubscriptions() else null

        $q.all({products: productPromise, subscriptions: subPromise}).then(
          (response) ->
            vm.products = _.each(response.products,
              (product) ->
                product.subscription = _.find(response.subscriptions, product?.nid == product.product_nid)
                product
            )
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
