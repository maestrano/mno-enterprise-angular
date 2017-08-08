ImpersonificationNotificationCtrl = ($scope, $log, toastr, MnoeUserAccessRequests) ->
  'ngInject'

  $scope.isLoading = true

  $scope.initialize = (requests) ->
    $scope.requests = requests
    $scope.isLoading = false

  $scope.requesterName = (request) ->
    request.requester.name + ' ' + request.requester.surname

  $scope.denyAccess = (index, request) ->
    $scope.isLoading = true
    MnoeUserAccessRequests.deny(request.id).then(
      () ->
        $scope.requests.splice(index, 1)
        toastr.success('mno_enterprise.templates.impac.impersonification_notification.deny.success_toastr', {extraData: {name: $scope.requesterName(request)}})
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.impac.impersonification_notification.deny.error_toastr', {extraData: {name: $scope.requesterName(request)}})
    ).finally(-> $scope.isLoading = false)

  $scope.approveAccess = (index, request) ->
    $scope.isLoading = true
    MnoeUserAccessRequests.approve(request.id).then(
      () ->
        $scope.requests.splice(index, 1)
        toastr.success('mno_enterprise.templates.impac.impersonification_notification.approve.success_toastr', {extraData: {name: $scope.requesterName(request)}})
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.impac.impersonification_notification.approve.error_toastr', {extraData: {name: $scope.requesterName(request)}})
    ).finally(-> $scope.isLoading = false)

  MnoeUserAccessRequests.list().then(
    (requests) ->
      $scope.initialize(requests)
    (errors) ->
      $log.error(errors)
  )

angular.module 'mnoEnterpriseAngular'
  .directive('impersonificationNotification', ->
    return {
      restrict: 'EA'
      controller: ImpersonificationNotificationCtrl
      templateUrl: 'app/components/impersonification-notification/impersonification-notification.html',
    }
  )
