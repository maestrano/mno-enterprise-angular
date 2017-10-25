# For backward compatibility with the mnoe backend
# Define null/default values for all the constants so that if the backend hasn't been upgraded
# to define this constants you don't get errors like:
#   Uncaught Error: [$injector:unpr] Unknown provider: INTERCOM_IDProvider <- INTERCOM_ID <- AnalyticsSvc
angular.module('mnoEnterprise.defaultConfiguration', [])
  .constant('IMPAC_CONFIG', {})
  .constant('I18N_CONFIG', {})
  .constant('DASHBOARD_CONFIG', {})
  .constant('ADMIN_PANEL_CONFIG', {})
  .constant('GOOGLE_TAG_CONTAINER_ID', null)
  .constant('APP_NAME', null)
  .constant('INTERCOM_ID', null)
  .constant('URL_CONFIG', {})
  .constant('DEVISE_CONFIG', {})
