angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, DASHBOARD_CONFIG) ->
    _self = @

    @isAuditLogEnabled = () ->
      if DASHBOARD_CONFIG.audit_log?.enabled?
        DASHBOARD_CONFIG.audit_log.enabled
      else
        false

    @isBillingEnabled = () ->
      if DASHBOARD_CONFIG.organization_management?.billing?.enabled?
        DASHBOARD_CONFIG.organization_management.billing.enabled
      else
        true

    return @
