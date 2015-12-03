angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($timeout, toastr, MnoeCurrentUser) ->
    'ngInject'

    layout = this

    MnoeCurrentUser.get().then(
      (response) ->
        layout.currentUser = response
    )

    MnoeCurrentUser.get().then(
      (response) ->
        layout.currentUser2 = response
    )

    return
