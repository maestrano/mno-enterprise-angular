angular.module 'mnoEnterpriseAngular'
  .controller('MemberAddModalCtrl',
  (MnoeTeams, $uibModalInstance, Utilities, team, availableUsers) ->
    'ngInject'

    vm = this
    vm.team = team
    vm.availableUsers = availableUsers
    vm.selectedUsers = []
    vm.isLoading = false

    vm.toggleUser = (user) ->
      if user in vm.selectedUsers then vm.selectedUsers.splice(vm.selectedUsers.indexOf(user), 1) else vm.selectedUsers.push(user)

    vm.onSubmit = () ->
      vm.isLoading = true
      MnoeTeams.addUsers(vm.team.id, vm.selectedUsers).then(
        (users) ->
          vm.errors = ''
          $uibModalInstance.close()
        (errors) ->
          vm.errors = Utilities.processRailsError(errors)
      ).finally(
        ->
          vm.selectedUsers = []
          vm.isLoading = false
      )

    vm.onCancel = () ->
      vm.selectedUsers = []
      $uibModalInstance.dismiss('cancel')

    return
  )
