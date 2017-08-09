angular.module 'mnoEnterpriseAngular'
  .service('MnoLocaleConfigSvc', ($window, $translate, I18N_CONFIG, LOCALES) ->

    @setLocale = ->
      locale = localeFromUrl()
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

    # Build our fallback stack manually to be ['language', preferredLanguage, LOCALES.fallbackLanguage]
    # eg: If the detected locale is 'fr-FR' and the preferred language 'en-GB', the fallback stack is
    # ['fr', 'en-GB', 'en']
    # This is similar to the angular-translate implementation except they push th preferredLanguage at the end
    setFallbackStack = (locale)->
      fallbackStack = []
      if found[1].length == 5
        language = found[1].slice(0,2)

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

