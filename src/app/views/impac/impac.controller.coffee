angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $state, MnoeOrganizations, ImpacConfigSvc, ImpacDashboardsSvc, DOCK_CONFIG) ->
    'ngInject'

    vm = this
    vm.isImpacShown = false
    vm.isDockEnabled = DOCK_CONFIG.enabled

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      # Fetches the organizations using ImpacConfigSvc (and not MnoeOrganizations)
      # => Allows to make sure the ACL has already been overriden if necessary (see impac.config.coffee)
      ImpacConfigSvc.getOrganizations().then(
        (resp) ->
          selectedOrg = _.find(resp.organizations, { id: parseInt(newValue) })
          if selectedOrg.acl.related.impac.show
            # Displays Impac! and reloads dashboard if user authorised
            vm.isImpacShown = true
            ImpacDashboardsSvc.reload(true) if newValue? && oldValue? && parseInt(newValue) != parseInt(oldValue)
          else
            # Redirects the user to /apps otherwise
            $state.go('home.apps')
      ) if newValue?
    )

    return
