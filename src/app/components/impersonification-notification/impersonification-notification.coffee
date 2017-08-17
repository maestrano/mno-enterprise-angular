ImpersonificationNotificationCtrl = (toastr, MnoErrorsHandler, MnoeConfig, MnoeUserAccessRequests) ->
  'ngInject'
  vm = this
  vm.isEnabled = MnoeConfig.isImpersonationConsentRequired()
  vm.isLoading = true

  vm.initialize = (result) ->
    vm.requests = result
    vm.isLoading = false

  vm.requesterName = (request) ->
    request.requester.name + ' ' + request.requester.surname

  vm.denyAccess = (request, index) ->
    vm.isLoading = true
    MnoeUserAccessRequests.deny(request.id).then(
      () ->
        vm.requests.splice(index, 1)
        toastr.success('mno_enterprise.templates.impac.impersonification_notification.deny.success_toastr', {extraData: {name: vm.requesterName(request)}})
      (errors) ->
        MnoErrorsHandler.processServerError(errors)
        toastr.error('mno_enterprise.templates.impac.impersonification_notification.deny.error_toastr', {extraData: {name: vm.requesterName(request)}})
    ).finally(-> vm.isLoading = false)

  vm.approveAccess = (request, index) ->
    vm.isLoading = true
    MnoeUserAccessRequests.approve(request.id).then(
      () ->
        vm.requests.splice(index, 1)
        toastr.success('mno_enterprise.templates.impac.impersonification_notification.approve.success_toastr', {extraData: {name: vm.requesterName(request)}})
      (errors) ->
        MnoErrorsHandler.processServerError(errors)
        toastr.error('mno_enterprise.templates.impac.impersonification_notification.approve.error_toastr', {extraData: {name: vm.requesterName(request)}})
    ).finally(-> vm.isLoading = false)

  MnoeUserAccessRequests.list().then(
    (requests) ->
      vm.initialize(requests)
    (errors) ->
      MnoErrorsHandler.processServerError(errors)
  )

  return vm

angular.module 'mnoEnterpriseAngular'
  .component('impersonificationNotification', {
    controller: ImpersonificationNotificationCtrl,
    controllerAs: 'vm'
    templateUrl: 'app/components/impersonification-notification/impersonification-notification.html',
  })
