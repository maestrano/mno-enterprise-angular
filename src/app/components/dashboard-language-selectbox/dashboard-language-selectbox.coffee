
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardLanguageSelectbox', ->
    return {
      restrict: 'EA'
      template: '''
        <span class="selector-line form-inline form-group form-group-sm">
          <label class="control-label" for="language-select">Language</label>
          <select id="language-select" class="form-control" ng-model="selectedLangKey" ng-change="changeLanguage()" ng-options="locale.id as locale.name for locale in locales">
          </select>
        </span>
      '''
      controller: ($scope, $translate, $window, $uibModal, MnoConfirm, LOCALES, URI) ->

        $scope.locales = LOCALES.locales
        $scope.selectedLangKey = $translate.use()

        # Save the previous value of the list
        $scope.$watch('selectedLangKey', (newVal, oldVal) ->
          $scope.previousLocale = oldVal
        )

        # Triggered when the locale change, locale can be reverted using $scope.previousLocale
        $scope.changeLanguage = () ->
          locale = _.findWhere(LOCALES.locales, { id: $scope.selectedLangKey })
          console.log locale

          modalOptions =
            closeButtonText: 'Cancel'
            actionButtonText: 'Change language'
            headerText: "Change language to #{locale.name}?"
            bodyText: "Are you sure you want to change language to #{locale.name}?"

          MnoConfirm.showModal(modalOptions).then(
            ->
              # Success
              $translate.use($scope.selectedLangKey)
              moment.locale($scope.selectedLangKey)
              $window.location.href = "/#{$scope.selectedLangKey}#{URI.dashboard}"
            ->
              # Error
              $scope.selectedLangKey = $scope.previousLocale
          )
    }
  )
