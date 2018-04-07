angular.module 'mnoEnterpriseAngular'
  .constant('URI', {
    login: '/mnoe/auth/users/sign_in',
    dashboard: '/dashboard/',
    logout: '/mnoe/auth/users/sign_out',
    signup: '/mnoe/auth/users/sign_up',
    api_root: '/mnoe/jpi/v1'
  })
  .constant('DOC_LINKS', {
    connecDoc: 'https://maestrano.atlassian.net/wiki/x/BIHLAQ'
  })
  .constant('LOCALSTORAGE', {
    appInstancesKey: 'appInstancesV2'
  })
  .constant('LOCALES', {
    'fallbackLanguage': 'en'
  })
  .constant('PRICING_TYPES', {
    'unpriced': ['free', 'payg']
  })
  .constant('EDIT_ACTIONS', {
    'NEW': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.new'
    'EDIT': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.edit',
    'CHANGE': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.change',
    'RENEW': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.renew',
    'SUSPEND': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.suspend',
    'REACTIVATE': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.reactivate'
  })
