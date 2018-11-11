
DashboardOrganizationCreditCardCtrl = ($scope, $window, toastr, MnoeOrganizations, MnoConfirm, VALID_COUNTRIES, Utilities) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.forms = {}
  $scope.model = {}
  $scope.origModel = {}
  $scope.config = {
    validTitles: ['Mr.', 'Ms.', 'Mrs.', 'Miss', 'Dr.', 'Sir.', 'Prof.']
    validMonths: [1..12]
    validYears: [d = (new Date).getFullYear()..d+20]
    validCountries: VALID_COUNTRIES
    validCCTypes: ['visa', 'mastercard', 'amex', 'jcb']
  }

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  $scope.initialize = (creditCard) ->
    angular.copy(creditCard, $scope.model)
    angular.copy(creditCard, $scope.origModel)

    if restrictedCCTypes = MnoeOrganizations.selected.organization.payment_restriction
      $scope.config.validCCTypes = _.intersection($scope.config.validCCTypes, restrictedCCTypes)

    $scope.isLoading = false

  # Save the current state of the credit card
  $scope.save = ->
    $scope.isLoading = true

    modalOptions =
      closeButtonText: 'mno_enterprise.templates.dashboard.organization.credit_card.confirm_modal.cancel'
      actionButtonText: 'mno_enterprise.templates.dashboard.organization.credit_card.confirm_modal.confirm'
      headerText: 'mno_enterprise.templates.dashboard.organization.credit_card.confirm_modal.header'
      bodyText: 'mno_enterprise.templates.dashboard.organization.credit_card.confirm_modal.disclaimer'
      bodyNgClass: 'text-danger'
      type: 'primary'

    MnoConfirm.showModal(modalOptions).then(
      ->
        # Success
        MnoeOrganizations.updateCreditCard($scope.model).then(
          (response) ->
            $scope.errors = ''
            angular.copy(response.credit_card, $scope.model)
            angular.copy(response.credit_card, $scope.origModel)
            if $scope.callback
              $scope.callback()
            MnoeOrganizations.reloadCurrentOrganization().then(
              ->
                toastr.success('mno_enterprise.templates.dashboard.organization.credit_card.success_toastr')
            )
          (errors) ->
            $scope.errors = Utilities.processRailsError(errors)
        )
      ->
        # Cancel
        false
    ).finally(-> $scope.isLoading = false )

  # Cancel the temporary changes made by the
  # user
  $scope.cancel = ->
    angular.copy($scope.origModel, $scope.model)
    $scope.errors = ''

  # Check if the user has started editing the
  # CreditCard
  $scope.isChanged = ->
    !angular.equals($scope.model, $scope.origModel)

  # Check whether we should display the cancel
  # button or not
  $scope.isCancelShown = ->
    $scope.isChanged()

  # Should we enable the save button
  $scope.isSaveEnabled = ->
    f = $scope.forms
    $scope.isChanged() && f.billingAddress.$valid && f.creditCard.$valid

  # Is the Credit Card accepted?
  $scope.isAcceptedCardType = ->
    ccType = $scope.getType()
    ccType == "" || ccType in $scope.config.validCCTypes

  # Enable/Disable the credit card icons
  $scope.classForIconType = (ccType) ->
    self = $scope
    currentCcType = self.getType()
    # Do not disable logo if the CardType is not accepted
    if ccType == currentCcType || currentCcType == "" || !$scope.isAcceptedCardType()
      return "enabled"
    else
      return "disabled"

  # Return the credit card type (visa/mastercard/amex/jcb)
  $scope.getType = () ->
    self = $scope
    number = self.model.number
    if number != null && number != undefined
      re = new RegExp("^X")
      if (number.match(re) != null) then return ""

      re = new RegExp("^4")
      if (number.match(re) != null) then return "visa"

      re = new RegExp("^(34|37)")
      if (number.match(re) != null) then return "amex"

      re = new RegExp("^5[1-5]")
      if (number.match(re) != null) then return "mastercard"

      re = new RegExp("^6(?:011|5[0-9]{2})")
      if (number.match(re) != null) then return "discover"

      re = new RegExp("(?:2131|1800|35[0-9]{3})")
      if (number.match(re) != null) then return "jcb"

      re = new RegExp("^3(?:0[0-5]|[68][0-9])")
      if (number.match(re) != null) then return "dinersclub"

      # Last resort we assume that it is a Mastercard if
      # the number is long enough
      # See:
      #http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
      if number.length > 4
        return "mastercard"
      else
        return ""

    return ""

  # Open the godaddy site seal in a popup
  $scope.openGodaddySslSeal = () ->
    bgHeight = "779"
    bgWidth = "593"
    url = "https://seal.godaddy.com/verifySeal?sealID=RsNWG4eDd3ctNJWJfbeSBjJ6OWCtE3j0OwSXRDYF1WlMAGMqqmX5Kp"
    options = "menubar=no,toolbar=no,personalbar=no,location=yes,status=no,resizable=yes,fullscreen=no,scrollbars=no,width=#{bgWidth},height=#{bgHeight}"
    $window.open(url,'SealVerfication',options)

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    if val?
      $scope.initialize(MnoeOrganizations.selected.credit_card)


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationCreditCard', ->
    return {
      restrict: 'A',
      scope: {
        callback:'&'
      },
      templateUrl: 'app/views/company/credit-card/organization-credit-card.html',
      controller: DashboardOrganizationCreditCardCtrl
    }
  )
