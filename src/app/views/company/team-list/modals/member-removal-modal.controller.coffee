angular.module 'mnoEnterpriseAngular'
  .controller('MemberRemovalModalCtrl',
  (MnoeTeams, $uibModalInstance, Utilities, team, user) ->
    'ngInject'

    vm = this
    vm.team = team
    vm.user = user
    vm.isLoading = false

    vm.onSubmit = () ->
      vm.isLoading = true
      MnoeTeams.removeUser(vm.team.id, vm.user).then(
        (users) ->
          vm.errors = ''
          $uibModalInstance.close()
        (errors) ->
          vm.errors = Utilities.processRailsError(errors)
      ).finally(
        ->
          vm.isLoading = false
      )

    vm.onCancel = () ->
      $uibModalInstance.dismiss('cancel')

    return
  )
