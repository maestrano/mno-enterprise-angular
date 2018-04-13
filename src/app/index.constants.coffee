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
    'EDIT': 'mno_enterprise.templates.dashboard.provisioning.subscription.edit',
    'CHANGE': 'mno_enterprise.templates.dashboard.provisioning.subscription.change',
    'RENEW': 'mno_enterprise.templates.dashboard.provisioning.subscription.renew',
    'SUSPEND': 'mno_enterprise.templates.dashboard.provisioning.subscription.suspend',
    'REACTIVATE': 'mno_enterprise.templates.dashboard.provisioning.subscription.reactivate'
    })
