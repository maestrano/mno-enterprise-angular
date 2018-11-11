angular.module 'mnoEnterpriseAngular'
  .service 'OrgAccountHelper', (MnoeConfig) ->
    _self = @

    # Check configuration and selected organization to
    # determine if the account is able to make
    # purchases and manage subscriptions.
    #
    # Expected argument is MnoeOrganizations.selected
    # as credit card information may be required for
    # this check.
    @isAccountValid = (selectedOrg) ->
      # Is an up to date account required to allow app management and is the account past due?
      paymentRequired = MnoeConfig.isCurrentAccountRequired() && selectedOrg.organization.in_arrears
      # Are billing details required and are they present?
      detailsRequired = MnoeConfig.areBillingDetailsRequired() && _.isEmpty(selectedOrg.credit_card)
      # Billing details need to be updated if payment or billing details are required
      # This is only enforced if payment is enabled (allows end user to add/update billing details)
      (paymentRequired || detailsRequired) && MnoeConfig.isPaymentEnabled()

    return @
