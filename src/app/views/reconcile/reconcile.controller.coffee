angular.module 'mnoEnterpriseAngular'
  .controller 'ReconcileController', ($scope, DOCK_CONFIG, MnoeOrganizations, MnoeCurrentUser, TransacTxsDispatcher, TransacUserService) ->
    'ngInject'

    vm = this
    vm.isDockEnabled = DOCK_CONFIG.enabled

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          selectedOrg = _.find(response.organizations, {id: parseInt(newValue)})
          # Reload Transac!
          TransacUserService.fetch().then(-> TransacTxsDispatcher.reloadTxs()) if newValue? && oldValue? && parseInt(newValue) != parseInt(oldValue)

      ) if newValue?
    )

    return
