angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations, $translate, $rootScope) ->
    'ngInject'

    # Impac! is displayed only to admin and super admin
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          # We only check the role for those states
          if $state.is('home.impac') || $state.is('home.apps')
            selectedOrg = _.find(response.organizations, {id: newValue})
            if MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)
              $state.go('home.impac')
            else
              $state.go('home.apps')
      ) if newValue?
    )

    translateUI = () ->
      $translate('language').then(
        (translation) ->
          $scope.language = translation
        (translationId) ->
          $scope.language = translationId
      )

    $rootScope.$on('$translateChangeSuccess', () ->
      console.log("Locale changed")
      translateUI()
    )
    translateUI()

    $scope.translate = $translate
    $scope.locale = $translate.use()

    $scope.changeLocale = (locale) ->
      console.log("changing locale to:", locale)
      $translate.use(locale)

    return
