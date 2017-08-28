angular.module 'mnoEnterpriseAngular'
  .constant('URI', {
    login: '/mnoe/auth/users/sign_in',
    dashboard: '/dashboard/',
    logout: '/mnoe/auth/users/sign_out',
    signup: '/mnoe/auth/users/sign_up'
  })
  .constant('DOC_LINKS', {
    connecDoc: 'https://maestrano.atlassian.net/wiki/x/BIHLAQ'
  })
  .constant('LOCALSTORAGE', {
    appInstancesKey: 'appInstancesV2'
  })
  .constant('LOCALES', {
    'locales': [
      { id: 'en', name: 'English', flag: '' },
      { id: 'id', name: 'Indonesian', flag: '' },
      { id: 'zh', name: 'Chinese (Singapore)', flag: '' }
    ],
    'preferredLocale': 'en',
    'fallbackLanguage': 'en'
  })
