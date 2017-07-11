angular.module 'mnoEnterpriseAngular'
  .controller 'ReconcileController', ($scope, $state, MnoeOrganizations, TransacTxsDispatcher, TransacUserService, MnoeAppInstances) ->
    'ngInject'

    vm = this

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newId, oldId) ->
      # Validate access
      MnoeAppInstances.transactionEnabled().then((enabled)->
        if $state.is('home.reconcile') && !enabled
          $state.go('home.impac')
        else
          # Reload Transac!
          TransacUserService.fetch().then(-> TransacTxsDispatcher.reloadTxs()) if newId? && oldId? && parseInt(newId) != parseInt(oldId)
      )
    )

    return
