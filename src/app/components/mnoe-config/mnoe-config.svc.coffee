angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, DASHBOARD_CONFIG) ->
    _self = @

    @isAuditLogEnabled = () ->
      if DASHBOARD_CONFIG.audit_log?.enabled?
        DASHBOARD_CONFIG.audit_log.enabled
      else
        $log.debug("DASHBOARD_CONFIG.audit_log.enabled missing")
        false

    @isBillingEnabled = () ->
      if DASHBOARD_CONFIG.organization_management?.billing?.enabled?
        DASHBOARD_CONFIG.organization_management.billing.enabled
      else
        $log.debug("DASHBOARD_CONFIG.organization_management.billing.enabled missing")
        true

    @isDeveloperSectionEnabled = () ->
      if DASHBOARD_CONFIG.developer?.enabled?
        DASHBOARD_CONFIG.developer.enabled
      else
        $log.debug("DASHBOARD_CONFIG.developer.enabled missing")
        false

    @isDockEnabled = () ->
      if DASHBOARD_CONFIG.dock?.enabled?
        DASHBOARD_CONFIG.dock.enabled
      else
        $log.debug("DASHBOARD_CONFIG.dock.enabled missing")
        true

    @marketplaceCurrency = () ->
      if DASHBOARD_CONFIG.marketplace?.pricing?.currency?
        DASHBOARD_CONFIG.marketplace.pricing.currency
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.pricing.currency missing")
        'AUD'

    @isMarketplaceEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.enabled?
        DASHBOARD_CONFIG.marketplace.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.enabled missing")
        false

    @isMarketplaceComparisonEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.comparison?.enabled?
        DASHBOARD_CONFIG.marketplace.comparison.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.comparison.enabled missing")
        false

    @isMarketplacePricingEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.pricing?.enabled?
        DASHBOARD_CONFIG.marketplace.pricing.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.pricing.enabled missing")
        true

    @areMarketplaceReviewsEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.reviews?.enabled?
        DASHBOARD_CONFIG.marketplace.reviews.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.reviews.enabled missing")
        true

    @areMarketplaceQuestionsEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.questions?.enabled?
        DASHBOARD_CONFIG.marketplace.questions.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.questions.enabled missing")
        true

    @isOnboardingWizardEnabled = () ->
      if DASHBOARD_CONFIG.onboarding_wizard?.enabled?
        DASHBOARD_CONFIG.onboarding_wizard.enabled
      else
        $log.debug("DASHBOARD_CONFIG.onboarding_wizard.enabled missing")
        false

    @isOrganizationManagementEnabled = () ->
      if DASHBOARD_CONFIG.organization_management?.enabled?
        DASHBOARD_CONFIG.organization_management.enabled
      else
        $log.debug("DASHBOARD_CONFIG.organization_management.enabled missing")
        true

    @isPaymentEnabled = () ->
      if DASHBOARD_CONFIG.payment?.enabled?
        DASHBOARD_CONFIG.payment.enabled
      else
        $log.debug("DASHBOARD_CONFIG.payment.enabled missing")
        true

    @isProvisioningEnabled = () ->
      if DASHBOARD_CONFIG.provisioning?.enabled?
        DASHBOARD_CONFIG.provisioning.enabled
      else
        $log.debug("DASHBOARD_CONFIG.provisioning.enabled missing")
        false

    @isUserManagementEnabled = () ->
      if DASHBOARD_CONFIG.user_management?.enabled?
        DASHBOARD_CONFIG.user_management.enabled
      else
        $log.debug("DASHBOARD_CONFIG.user_management.enabled missing")
        true

    return @
