DashboardOrganizationSettingsCtrl = ($scope, $window, MnoeOrganizations, Utilities, MnoeConfig) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.model = {}
  $scope.origModel = {}
  $scope.forms = {}
  $scope.currencies = []

  #====================================
  # Scope Management
  #====================================
  # Feature flags
  $scope.currencies = MnoeConfig.availableBillingCurrencies()
  $scope.currencySelection = MnoeConfig.isBillingCurrencySelectionEnabled()
  $scope.mainAddressRequired = MnoeOrganizations.mainAddressRequired()
  $scope.currencySelectionDisabledTooltip = if $scope.currencySelection then '' else 'mno_enterprise.templates.dashboard.organization.settings.billing_currency_disabled_tooltip'

  # Initialize the data used by the directive
  $scope.initialize = (organization) ->
    angular.copy(organization, $scope.model)
    angular.copy(organization, $scope.origModel)
    $scope.isLoading = false

  # Save the current state of the organization settings
  $scope.save = ->
    $scope.isLoading = true
    # Update organization
    MnoeOrganizations.update($scope.model).then(
      (response) ->
        $scope.errors = ''
        angular.copy(response.organization, $scope.model)
        angular.copy($scope.model, $scope.origModel)
      (errors) ->
        $scope.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.isLoading = false)

  # Cancel the temporary changes made by the
  # user
  $scope.cancel = ->
    angular.copy($scope.origModel, $scope.model)
    $scope.errors = ''

  # Check if the user has started editing the
  # form
  $scope.isChanged = ->
    !angular.equals($scope.model, $scope.origModel)

  # Check whether we should display the cancel
  # button or not
  $scope.isCancelShown = ->
    $scope.isChanged()

  # Should we enable the save button
  $scope.isSaveEnabled = ->
    f = $scope.forms
    $scope.isChanged() && f.settings.$valid

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch(MnoeOrganizations.getSelected, (newValue) ->
    $scope.isLoading = true
    if newValue?
      $scope.initialize(MnoeOrganizations.selected.organization)
  )

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationSettings', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/settings/organization-settings.html',
      controller: DashboardOrganizationSettingsCtrl
    }
  )
