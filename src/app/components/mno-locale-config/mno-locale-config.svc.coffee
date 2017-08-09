angular.module 'mnoEnterpriseAngular'
  .service('MnoLocaleConfigSvc', (
    $window, $translate,
    MnoeCurrentUser,
    I18N_CONFIG, LOCALES
  ) ->

    @configure = ->
      if l = localeFromUrl()
        console.log("Using locale from URL")
        return setLocale(l)

      # TODO: do we want to edit the URL
      # when getting the language from the user?
      MnoeCurrentUser.get().then(
        ->
          if l = localeFromUser()
            console.log("Using locale from User")
            setLocale(l)
      )

    setLocale = (locale) ->
      setFallbackStack(locale)
      $translate.use(locale)

    # Try to determine the locale from the URL
    localeFromUrl = ->
      # Get current path (eg. "/en/dashboard/" or "/dashboard/")
      path = $window.location.pathname

      # Extract the language code if present
      re = /^\/([A-Za-z]{2}(-[A-Z]{2})?)\/dashboard\//i
      found = path.match(re)

      # Ex found: ["/en/dashboard/", "en", index: 0, input: "/en/dashboard/"]
      return found[1] if found?

    # Find the locale from the User#settings
    localeFromUser = ->
      MnoeCurrentUser.user.settings?.locale

    # Build our fallback stack manually to be ['language', preferredLanguage, LOCALES.fallbackLanguage]
    # eg: If the detected locale is 'fr-FR' and the preferred language 'en-GB', the fallback stack is
    # ['fr', 'en-GB', 'en']
    # This is similar to the angular-translate implementation except they push th preferredLanguage at the end
    setFallbackStack = (locale)->
      fallbackStack = []
      if locale?.length == 5
        language = locale.slice(0,2)

        # Start with the language code
        fallbackStack.push(language)

      # Then the preferred language
      prefLanguage = $translate.preferredLanguage()
      if (angular.isString(prefLanguage) && prefLanguage not in fallbackStack)
        fallbackStack.push(prefLanguage)

      # Then the framework default ('en')
      if (angular.isString(LOCALES.fallbackLanguage) && LOCALES.fallbackLanguage not in fallbackStack)
        fallbackStack.push(LOCALES.fallbackLanguage)

      $translate.fallbackLanguage(fallbackStack)

    return @
)

