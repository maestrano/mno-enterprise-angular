angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, AUDIT_LOG, ORGANIZATION_MANAGEMENT, NOTIFICATIONS_CONFIG) ->
    _self = @

    @isAuditLogEnabled = () ->
      if AUDIT_LOG
        AUDIT_LOG.enabled
      else
        false

    @isBillingEnabled = () ->
      if ORGANIZATION_MANAGEMENT? && ORGANIZATION_MANAGEMENT.billing?
        ORGANIZATION_MANAGEMENT.billing.enabled
      else
        true

    @isNotificationsEnabled = () ->
      if NOTIFICATIONS_CONFIG
        NOTIFICATIONS_CONFIG.enabled
      else
        false

    return @
