
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardLanguageSelectbox', ->
    return {
      restrict: 'EA'
      template: '''
        <select ng-model="selectedLangKey" ng-change="changeLanguage()" ng-options="locale.id as locale.name for locale in locales track by locale.id">
        </select>
      '''
      controller: ($scope, $translate, LOCALES) ->

        $scope.locales = LOCALES.locales
        $scope.selectedLangKey = _.find(LOCALES.locales, {id: $translate.use()})

        $scope.changeLanguage = () ->
          $translate.use($scope.selectedLangKey)

    }
  )
