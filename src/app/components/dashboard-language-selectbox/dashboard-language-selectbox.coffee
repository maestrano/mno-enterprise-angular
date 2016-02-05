
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
      controller: ($scope, $translate, LOCALES) ->

        $scope.locales = LOCALES.locales
        $scope.selectedLangKey = $translate.use()

        $scope.changeLanguage = () ->
          $translate.use($scope.selectedLangKey)

    }
  )
