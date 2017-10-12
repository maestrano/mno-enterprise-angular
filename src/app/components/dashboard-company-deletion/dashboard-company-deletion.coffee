angular.module 'mnoEnterpriseAngular'
  .component('dashboardCompanyDeletion', {
    restrict: 'EA'
    templateUrl: 'app/components/dashboard-company-deletion/dashboard-company-deletion.html',
    controllerAs: "DashboardCompanyDeletionCtrl"
    controller:  ($log, $uibModal, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances, MnoConfirm) ->
      vm = this
      vm.isDeletionOpen = true

      vm.proceed = (reason, password) ->
        MnoeOrganizations.freeze(reason, password)

      vm.requestDeletion =  () ->
        modalInstance = $uibModal.open(
          component: "dashboardDeletionConfirm",
          size: "lg",
          resolve:
            actionCb: () ->  vm.proceed
          )
        modalInstance.result.then(
          (x) -> $log.log("LOL OK"),
          (y) -> $log.log("LOL PAS OK"))

      return
      })
