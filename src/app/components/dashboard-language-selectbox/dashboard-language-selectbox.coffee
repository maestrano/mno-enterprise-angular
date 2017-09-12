
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardLanguageSelectbox', ->
    return {
      restrict: 'EA'
      template: '''
        <span class="selector-line form-inline form-group form-group-sm">
          <label class="control-label" for="language-select">{{'mno_enterprise.templates.components.language_selectbox.language' | translate}}</label>
          <select id="language-select" class="form-control" ng-model="selectedLangKey" ng-change="changeLanguage()" ng-options="locale.id as locale.name for locale in locales">
          </select>
        </span>
      '''
      controller: ($scope, $translate, $window, $uibModal, MnoConfirm, I18N_CONFIG, URI, MnoeCurrentUser) ->

        $scope.locales = I18N_CONFIG.available_locales
        $scope.selectedLangKey = $translate.use()

        # Save the previous value of the list
        $scope.$watch('selectedLangKey', (newVal, oldVal) ->
          $scope.previousLocale = oldVal
        )

        # Triggered when the locale change, locale can be reverted using $scope.previousLocale
        $scope.changeLanguage = () ->
          locale = _.findWhere(I18N_CONFIG.available_locales, { id: $scope.selectedLangKey })

          modalOptions =
            closeButtonText: 'mno_enterprise.templates.components.language_selectbox.cancel'
            actionButtonText: 'mno_enterprise.templates.components.language_selectbox.change_language'
            headerText: 'mno_enterprise.templates.components.language_selectbox.confirm_header'
            bodyText: 'mno_enterprise.templates.components.language_selectbox.confirm'
            localeName: locale.name
            actionCb: -> MnoeCurrentUser.update(settings: {locale: $scope.selectedLangKey})

          MnoConfirm.showModal(modalOptions).then(
            ->
              # Success
              $translate.use($scope.selectedLangKey)
              $window.location.href = "/#{$scope.selectedLangKey}#{URI.dashboard}"
            ->
              # Error
              $scope.selectedLangKey = $scope.previousLocale
          )
    }
  )
