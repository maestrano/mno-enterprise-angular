angular.module 'mnoEnterpriseAngular'
  .constant('URI', {
    login: '/mnoe/auth/users/sign_in',
    dashboard: '/dashboard/',
    logout: '/mnoe/auth/users/sign_out',
    connecDoc: 'https://maestrano.atlassian.net/wiki/display/UKB/How+Connec%21+shares+data+between+apps'
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
