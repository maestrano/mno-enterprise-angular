# For backward compatibility with the mnoe backend
# Define null/default values for all the constants so that if the backend hasn't been upgraded
# to define this constants you don't get errors like:
#   Uncaught Error: [$injector:unpr] Unknown provider: INTERCOM_IDProvider <- INTERCOM_ID <- AnalyticsSvc
angular.module('mnoEnterprise.defaultConfiguration', [])
  .constant('IMPAC_CONFIG', {})
  .constant('I18N_CONFIG', {})
  .constant('PRICING_CONFIG', {enabled: true})
  .constant('PAYMENT_CONFIG', {disabled: false})
  .constant('ORGANIZATION_MANAGEMENT', {enabled: true})
  .constant('USER_MANAGEMENT', {enabled: true})
  .constant('DOCK_CONFIG', {enabled: true})
  .constant('DEVELOPER_SECTION_CONFIG', {enabled: false})
  .constant('ONBOARDING_WIZARD_CONFIG', {enabled: false})
  .constant('REVIEWS_CONFIG', {enabled: false})
  .constant('QUESTIONS_CONFIG', {enabled: false})
  .constant('MARKETPLACE_CONFIG', {enabled: true, comparison: {enabled: false}})
  .constant('AUDIT_LOG', {enabled: false})
  .constant('GOOGLE_TAG_CONTAINER_ID', null)
  .constant('APP_NAME', null)
  .constant('INTERCOM_ID', null)
  .constant('URL_CONFIG', {})
  .constant('TASKS_CONFIG', {enabled: false})
  .constant('NOTIFICATIONS_CONFIG', {enabled: false})
