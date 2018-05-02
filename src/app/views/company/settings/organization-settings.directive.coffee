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
  # Initialize the data used by the directive
  $scope.initialize = (organization) ->
    angular.copy(organization, $scope.model)
    angular.copy(organization, $scope.origModel)
    $scope.isLoading = false

  # Save the current state of the organization settings
  $scope.save = ->
    $scope.isLoading = true
    # Update main address of organization
    if addressChangePresent() then saveMainAddress()
    # Update organization
    MnoeOrganizations.update($scope.model).then(
      (response) ->
        $scope.errors = ''
        angular.merge(response.organization, $scope.model)
      (errors) ->
        $scope.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.isLoading = false)

  saveMainAddress = ->
    MnoeOrganizations.updateMainAddress($scope.model.main_address).then(
      (response) ->
        $scope.errors = ''
        angular.copy(response.main_address, $scope.model.main_address)
        angular.copy(response.main_address, $scope.origModel.main_address)
        if $scope.callback
          $scope.callback()
      (errors) ->
        $scope.errors = Utilities.processRailsError(errors)
    ).finally(-> $scope.isLoading = false)

  # Check if address has changed
  addressChangePresent = ->
    !angular.equals($scope.origModel.main_address, $scope.model.main_address)

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

  $scope.isCurrencyChangeShown = ->
    if MnoeOrganizations.role.isSuperAdmin()
      $scope.getAvailableBillingCurrencies()
      true
    else
      false

  $scope.getAvailableBillingCurrencies = ->
    $scope.currencies = MnoeConfig.availableBillingCurrencies()

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
