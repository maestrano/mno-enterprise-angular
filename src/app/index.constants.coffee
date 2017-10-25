angular.module 'mnoEnterpriseAngular'
  .constant('URI', {
    login: '/login',
    dashboard: '/dashboard/',
    signup: '/mnoe/auth/users/sign_up',
    api_root: '/mnoe/jpi/v1',
    logout: '/logout'
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
