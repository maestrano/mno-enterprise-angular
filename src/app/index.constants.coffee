angular.module 'mnoEnterpriseAngular'
  .constant('URI', {
    login: '/mnoe/auth/users/sign_in',
    logout: '/mnoe/auth/users/sign_out'
  })
  .constant('LOCALSTORAGE', {
    appInstancesKey: 'appInstances'
  })
  .constant('LOCALES', {
    'locales': [
      { id: 'en_US', name: 'English', flag: '' },
      { id: 'id_ID', name: 'Indonesian', flag: '' },
      { id: 'zh_SG', name: 'Chinese (Singapore)', flag: '' }
    ],
    'preferredLocale': 'en_US',
    'fallbackLanguage': 'en_US'
  })
