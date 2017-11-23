angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $state) ->
    'ngInject'

    # After the layout is loaded, redirects to Impac! controller
    # => If the user doesn't have access to Impac!, it will redirect him to /apps
    $state.go('home.impac')

    return
