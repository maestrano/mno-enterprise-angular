angular.module 'mnoEnterpriseAngular'
  .component('dashboardCompanyDeletion', {
    restrict: 'EA'
    templateUrl: 'app/components/dashboard-company-deletion/dashboard-company-deletion.html',
    controllerAs: "DashboardCompanyDeletionCtrl"
    controller:  ($log, $stateParams, $uibModal, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances, MnoConfirm) ->
      vm = this
      vm.isDeletionOpen = true
      vm.requestDeletion =  () ->
        $uibModal.open({component: "dashboardDeletionConfirm"})

      return
      })
