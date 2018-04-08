angular.module 'mnoEnterpriseAngular'
  .controller 'EditSubscriptionController', ($uibModalInstance, $state, MnoeProvisioning, subscription) ->

    vm = this
    vm.subscription = subscription

    vm.closeModal = () ->
      $uibModalInstance.dismiss('cancel')

    vm.changePlan = (editAction) ->
      # Reset subscription, so that the correct subscription is fetched.
      MnoeProvisioning.setSubscription({})
      vm.closeModal()
      params = {id: vm.subscription.id, orgId: vm.subscription.organization_id, editAction: editAction}
      switch editAction
        when 'CHANGE'
          $state.go('home.provisioning.order', params)
        else
          $state.go('home.provisioning.additional_details', params)

    vm.editActionAvailable = (editAction) ->
      if vm.subscription.available_edit_actions
        editAction in vm.subscription.available_edit_actions
      else
        false

    return
