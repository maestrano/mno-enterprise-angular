ThemeEditorCtrl = ($scope, $window, $log, $timeout,  toastr, themeEditorSvc) ->
  'ngInject'

  #============================================
  # Theme Config
  #============================================
  default_theme = {
    # Main colors
    '@bg-main-color':                  "#aeb5bf"
    '@decorator-main-color':           "#758192"
    '@text-strong-color':              "#977bf0"
    '@text-inverse-strong-color':      "#17262d"

    # Inverse colors
    '@bg-inverse-color':               "#ffffff"
    '@bg-on-bg-inverse-color':         "#cacfd6"
    '@decorator-inverse-color':        "#977bf0"
    '@text-inverse-color':             "#17262d"

    # Color used in small/isolated elements
    '@decorator-touch-color':          "#d1e55c"
  }

  $scope.theme = theme = angular.copy(default_theme)

  $scope.labels = {
    # Main colors
    '@bg-main-color':                   "Dashboard background color"
    '@decorator-main-color':            "Elements placed on top of bg-main-color"
    '@text-strong-color':               "Used for text used in the context of bg-main-color"
    '@text-inverse-strong-color':       "Used for text used in the context of inverse bg-main-color"

    # Inverse colors
    '@bg-inverse-color':                "Background color used for dashboard side menu. top banners, inverse modals"
    '@bg-on-bg-inverse-color':          "Background color for elements displayed on top of inverse elements"
    '@decorator-inverse-color':         "Design elements (lines, borders) on top of bg-inverse-color"
    '@text-inverse-color':              "Text used on top of bg-inverse-color such as inverse modals"

    # Color used in small/isolated elements
    '@decorator-touch-color':           "Color used as a decoration on small icons or specific text"
  }

  # Length of longest key (for padding purpose)
  key_length = _.max(_.keys(default_theme), (k) -> k.length).length + 2

  default_variables = {
    'Fonts & Text': {
      '@font-family-sans-serif':           'Arial, "Helvetica Neue", Helvetica, sans-serif'
      '@font-family-base':                 '@font-family-sans-serif'
      '@small':                            '11px'
      '@normal':                           '13px'
    },

    'General Colors': {
      '@brand-success':                  '#33d375'
      '@brand-warning':                  '#F2B469'
      '@brand-info':                     '#8CBEB2'
      '@brand-danger':                   '#EE6163'
      '@brand-primary':                  '#8CBEB2'
    },

    'Public Page Header': {
      '@public-page-header-bg-color':        '@bg-inverse-color'
      '@public-page-header-padding':         '10px'

      '@public-page-header-logo':            '{ min-height: 61px; max-width: 160px; max-height: 130px; margin: 17px auto 5px auto; }'
    },

    'Login Page': {
      '@login-bg-img':                       '"mno_enterprise/login-background.jpg"'
      '@login-bg-color':                     '@bg-main-color'
      '@login-box-grid-position':            '{ margin-top: 80px; .make-sm-column(4); .make-sm-column-offset(4); }'

      '@login-box-corners':                  '0'
      '@login-box-title-color':              '@text-inverse-color'
      '@login-box-title':                    '{ text-transform: uppercase; }'
      '@login-box-title-display-box-arrow':  'false'

      '@login-box-bg-color':                 '@bg-inverse-color'
      '@login-box-padding':                  '20px'
      '@login-box-brand-logo':               '{ max-width: 300px; max-height: 200px; margin: 16px auto 16px auto; }'
      '@login-box-btn-login':                '{ width: 100%; }'

      '@login-box-sso-intuit-logo':           'mno_enterprise/logo-intuit.png'
      '@login-box-oauth-text-color':          '#fff'
      '@login-box-oauth-bg-color-facebook':   '#3b5998'
      '@login-box-oauth-bg-color-google':     '#dd4b39'
      '@login-box-oauth-bg-color-linkedin':   '#0074C4'
      '@login-box-oauth-bg-color-intuit':     '#fff'
    },

    'Dashboard Layout': {
      '@dashboard-bg-color':                            '@bg-main-color'

      '@dashboard-section-title-color':                 '@text-strong-color'
      '@dashboard-section-title-alignment':             'center'
      '@dashboard-section-title-display-subline':       'false'
    },

    'Dashboard Loader': {
      '@dashboard-loader-color':                        '@text-strong-color'
      '@dashboard-loader-icon':                         '{ .icon-fa(refresh); .fa-2x; .fa-spin; }'
    },

    'User Without Organisation Screen': {
      '@without-organisation-well-bg':                  '@bg-inverse-color'
      '@without-organisation-text-color':               '@text-inverse-color'
    },

    'Dashboard Side Menu': {
      '@dashboard-side-menu-padding':                  '30px 0px 0px 14px'
      '@dashboard-side-menu-bg-color':                 '@bg-inverse-color'

      '@dashboard-side-menu-brand-logo':               '{ max-width: 50px; max-height: 50px; margin: 0; transition: max-width .25s ease, max-height .25s ease; }'
      '@dashboard-side-menu-brand-logo-expanded':      '{ max-width: 200px; max-height: 130px; }'
      '@dashboard-side-menu-link-color':               '@text-inverse-color'
      '@dashboard-side-menu-link-bg-color':            '@dashboard-side-menu-bg-color'

      '@dashboard-side-menu-link-hover-color':         '@dashboard-side-menu-bg-color'
      '@dashboard-side-menu-link-hover-bg-color':      'lighten(@bg-main-color,15%)'

      '@dashboard-side-menu-link-active-color':        '@dashboard-side-menu-bg-color'
      '@dashboard-side-menu-link-active-bg-color':     '@bg-main-color'
    },

    'Dashboard Company Select Box': {
      '@dashboard-cpy-select-width':                    '280px'
      '@dashboard-cpy-select-pic-width':                '50px'
      '@dashboard-cpy-select-bg-color':                 '@bg-inverse-color'
      '@dashboard-cpy-select-border-radius':            '0 0 0 6px'
      '@dashboard-cpy-select-padding':                  '15px 25px'
      '@dashboard-cpy-select-border-color':             '@text-inverse-color'
      '@dashboard-cpy-select-list-border-color':        'lighten(@bg-inverse-color, 10%)'

      '@dashboard-cpy-select-header-title-color':       '@text-inverse-color'
      '@dashboard-cpy-select-header-company-color':     '@decorator-inverse-color'
      '@dashboard-cpy-select-header-text-size':         '13px'

      '@dashboard-cpy-select-link-text-color':          '@link-color'
      '@dashboard-cpy-select-link-icon-color':          '@decorator-touch-color'

      '@dashboard-cpy-select-link-color':               '@text-inverse-strong-color'
      '@dashboard-cpy-select-link-hover-color':         '@text-strong-color'
      '@dashboard-cpy-select-link-hover-bg-color':      '@text-inverse-strong-color'
    },

    'Onboarding': {
      '@onboarding-header-height':                 '60px'
      '@onboarding-header-background-color':       '@bg-inverse-color'
      '@onboarding-header-font-color':             '@text-inverse-color'
      '@onboarding-subheader-height':              '50px'
      '@onboarding-subheader-background-color':    '@decorator-main-color'
      '@onboarding-subheader-font-color':          '@text-strong-color'
      '@onboarding-breadcrumb-badge-color':        '@text-inverse-strong-color'
      '@onboarding-breadcrumb-badge-color-active': '@text-inverse-strong-color'
      '@onboarding-breadcrumb-badge-bg':           '@bg-inverse-color'
      '@onboarding-breadcrumb-badge-bg-active':    '@decorator-touch-color'
      '@onboarding-breadcrumb-link-color':         '@text-strong-color'
      '@onboarding-content-panel-bg':              '@bg-inverse-color'
      '@onboarding-content-panel-color':           '@bg-on-bg-inverse-color'
      '@onboarding-content-panel-border-radius':   '4px'

      '@onboarding-app-features-border':           '1px solid @text-strong-color'
      '@onboarding-app-features-color':            '@text-strong-color'
      '@onboarding-app-features-checked':          '@brand-success'
      '@onboarding-app-features-unchecked':        '@text-strong-color'

      '@onboarding-app-selector-title':            '@text-strong-color'
      '@onboarding-app-selector-info':             '@text-strong-color'
      '@onboarding-app-selector-check-color':      'rgba(red(@brand-success), green(@brand-success), blue(@brand-success), 0.3)'

      '@onboarding-app-card-bg-color':             'white'
      '@onboarding-app-card-text-color':           '@text-strong-color'
      '@onboarding-app-card-padding':              '10px'

      '@onboarding-fetching-apps-loader-color':    'white'

      '@onboarding-app-entities-checked':          '@brand-success'
      '@onboarding-app-entities-unchecked':        '@brand-danger'

      '@onboarding-app-connect-check':             '@brand-success'
      '@onboarding-app-connect-loader':            '@decorator-main-color'
    },

    'Apps Section': {
      '@dashboard-apps-tile-bg-color':                  '@bg-inverse-color'
      '@dashboard-apps-tile-text-color':                '@text-inverse-color'

      '@dashboard-apps-tile-logo-border-size':          '0px'
      '@dashboard-apps-tile-logo-border-color':         '@decorator-main-color'

      '@dashboard-apps-tile-settings-color':            '@dashboard-apps-tile-text-color'
      '@dashboard-apps-tile-settings-bg-color':         '@dashboard-apps-tile-bg-color'

      '@dashboard-apps-tile-settings-hover-color':      '@dashboard-apps-tile-text-color'
      '@dashboard-apps-tile-settings-hover-bg-color':   '@dashboard-apps-tile-bg-color'

      '@dashboard-apps-tile-add-color':                 '@dashboard-apps-tile-text-color'
      '@dashboard-apps-tile-add-bg-color':              '@dashboard-apps-tile-bg-color'
    },

    'My account Section': {
      '@dashboard-account-tabs-bg-color':                    '@bg-on-bg-inverse-color'
      '@dashboard-account-tabs-text-color':                  '@text-inverse-color'
      '@dashboard-account-panel-header-bg-color':            '@bg-inverse-color'
      '@dashboard-account-panel-header-text-color':          '@text-inverse-color'
      '@dashboard-account-panel-body-bg-color':              '@bg-on-bg-inverse-color'
      '@dashboard-account-panel-text-color':                 '@text-strong-color'
      '@dashboard-account-inline-text-color-checked':        '@brand-success'
      '@dashboard-account-inline-text-color-unchecked':      '@decorator-inverse-color'
    },

    'Company Section': {
      '@dashboard-cpy-tabs-bg-color':                    '@decorator-main-color'
      '@dashboard-cpy-tabs-text-color':                  '@text-strong-color'
      '@dashboard-cpy-tabs-border-radius':               '2px'

      '@dashboard-cpy-tabs-subline-size':                '0px'
      '@dashboard-cpy-tabs-subline-color':               'transparent'

      '@dashboard-cpy-tabs-active-text-color':           '@decorator-main-color'
      '@dashboard-cpy-tabs-active-bg-color':             '@bg-inverse-color'

      '@dashboard-cpy-tabs-hover-text-color':            '@decorator-main-color'
      '@dashboard-cpy-tabs-hover-bg-color':              '@bg-inverse-color'

      '@dashboard-cpy-tabcontent-header-bg-color':         '@bg-inverse-color'
      '@dashboard-cpy-tabcontent-body-bg-color':           '@bg-on-bg-inverse-color'
      '@dashboard-cpy-tabcontent-bg-color':                '@bg-inverse-color'
      '@dashboard-cpy-tabcontent-text-color':              '@text-inverse-strong-color'

      '@dashboard-cpy-teams-matrix-bg-color':              '@bg-inverse-color'
      '@dashboard-cpy-teams-matrix-border-color':          '@bg-inverse-color'
      '@dashboard-cpy-teams-matrix-text-color':            '@text-inverse-color'
      '@dashboard-cpy-teams-matrix-text-hover-color':      '@text-inverse-color'
      '@dashboard-cpy-teams-matrix-text-edit-color':       '@text-strong-color'
    },

    'Impac Dashboard': {
      '@impac-dashboard-padding-top':                   '33px'
      '@impac-dashboard-margin-left':                   '0px'

      '@impac-dashboard-title-label-color':             '@text-strong-color'
      '@impac-dashboard-title-color':                   '@decorator-inverse-color'
      '@impac-dashboard-source-color':                  '@impac-dashboard-title-label-color'
      '@impac-dashboard-buttons-border-radius':         '4px'

      '@impac-placeholder-border':                      '2px dashed @bg-inverse-color'
      '@impac-padding-between-widgets':                 '12px'
      '@impac-minimum-widget-size':                     '258px'
    },

    'Impac Widgets': {
      # Global
      '@impac-widget-background-color':                 '@bg-on-bg-inverse-color'
      '@impac-widget-text-color':                       'black'
      '@impac-widget-text-color-light':                 '@text-strong-color'
      '@impac-widget-borders-color':                    'lighten(@impac-widget-text-color, 80%)'
      '@impac-widget-link-color':                       '@decorator-inverse-color'
      '@impac-widget-top-buttons-color':                'lighten(@impac-widget-text-color, 70%)'

      # Title
      '@impac-widget-title-text-color':                 'darken(@impac-widget-text-color,5%)'
      '@impac-widget-title-bg':                         '@impac-widget-background-color'
      '@impac-widget-title-border':                     'solid 1px @impac-widget-borders-color'
      '@impac-widget-title-text-transform':             'uppercase'
      '@impac-widget-title-text-size':                  '12px'
      '@impac-widget-title-border-radius':              '5px 5px 0px 0px'

      # Content
      '@impac-widget-content-border-radius':            '0px 0px 5px 5px'
      '@impac-widget-lines-container-max-height': 			'210px'

      # Hist Mode Choser
      '@impac-widget-hist-text-transform':              'uppercase'
      '@impac-widget-hist-text-size':                   '12px'
      '@impac-widget-hist-text-color':                  '@impac-widget-text-color-light'

      # Price
      '@impac-widget-price-color':                      '@impac-widget-text-color'
      '@impac-widget-price-positive-color':             '@brand-success'
      '@impac-widget-price-negative-color':             '@brand-danger'
      '@impac-widget-currency-color':                   '@impac-widget-text-color-light'
      '@impac-widget-legend-color':                     'lighten(@impac-widget-text-color,30%)'

      # Edit settings
      '@impac-widget-sub-bg-color':                     'darken(@impac-widget-background-color,10%)'
      '@impac-widget-sub-bg-color-light':               'lighten(@impac-widget-sub-bg-color,5%)'

      # Invoices list
      '@impac-widget-line-hover-bg':                    'lighten(@bg-inverse-color,10%)'
      '@impac-widget-line-hover-text':                  '@text-inverse-color'

      # Accounts Comparison
      '@impac-big-widget-size':                         '581px'
      '@impac-big-widget-bottom-padding':               '30px'
      '@impac-widget-accounts-comparison-lines-container-max-height': '250px'
    },

    'Marketplace Section': {
      '@dashboard-marketplace-search-text-color':             '@text-strong-color'
      '@dashboard-marketplace-search-border-color':           '@text-strong-color'

      '@dashboard-marketplace-tile-bg-color':                 '@bg-on-bg-inverse-color'
      '@dashboard-marketplace-tile-text-color':               '@text-strong-color'
      '@dashboard-marketplace-tile-name-color':               '@bg-inverse-color'
      '@dashboard-marketplace-tile-img-border-color':         '@decorator-main-color'

      '@dashboard-marketplace-tile-hover-bg-color':           '@decorator-main-color'
      '@dashboard-marketplace-tile-hover-text-color':         '@dashboard-marketplace-tile-text-color'
      '@dashboard-marketplace-tile-hover-img-border-color':   'darken(@decorator-main-color,10%)'
      '@dashboard-marketplace-tile-hover-arrow-color':        '@text-strong-color'

      '@dashboard-marketplace-show-header-text-color':        '@text-strong-color'
      '@dashboard-marketplace-show-sections-bg-color':        '@bg-on-bg-inverse-color'
      '@dashboard-marketplace-show-sections-text-color':      '@text-strong-color'

      '@dashboard-marketplace-product-card':                      '{ display: block; padding: 10px; height: 120px; margin-bottom: 10px; font-weight: 300; }'
    },

    'Reviews & Comments Section': {
      '@no-review-bg-panel-color':       'darken(@bg-on-bg-inverse-color, 5%)'

      '@comment-bg':                     '@bg-main-color'
      '@comment-text-color':             '@text-strong-color'
      '@comment-attributes-color':       '@bg-inverse-color'

      '@no-question-bg-panel-color':     'darken(@bg-on-bg-inverse-color, 5%)'
      '@question-search-btn-bg':         '@bg-inverse-color'
      '@question-search-btn-color':      '@text-inverse-color'
      '@question-search-border':          '1px solid @bg-inverse-color'
      '@question-bg':                    '@bg-on-bg-inverse-color'
      '@question-ribbon-bg':             '@bg-on-bg-inverse-color'
    },

    'Forms': {
      '@input-bg':                '@bg-on-bg-inverse-color'
      '@input-color':             '@text-inverse-color'
      '@input-color-placeholder': '@input-color'
      '@input-label-color':       '@text-inverse-color'
    }
  }
  $scope.variables = variables = angular.copy(default_variables)

  #============================================
  # View methods
  #============================================
  $scope.editor = editor = {busy: false, output: ''}

  editor.update = (opts = {publish: false, default: false, save: false}) ->
    return true if editor.updating
    editor.busy = true
    vars = mergeLessVars()

    # Apply style
    less.modifyVars(vars).then ->
      editor.busy = false
      theme_action = if opts.published
        "published style"
      else if opts.default
        "default style"
      else if opts.save
        "last saved style"
      toastr.info("Theme reset to #{theme_action}") if theme_action
      $scope.$apply()

  editor.reset = (opts = {published: false, default: false, save: false}) ->
    editor.busy = true
    if opts.published || opts.default
      promise = if opts.published
        themeEditorSvc.resetToPublishedTheme()
      else
        themeEditorSvc.resetToDefaultTheme()

      promise.then(-> loadLastSavedTheme())
        .then(-> editor.update(opts))
        .finally(-> editor.busy = false)
    else
      $scope.theme = theme = angular.copy(default_theme)
      $scope.variables = variables = angular.copy(default_variables)
      editor.update(opts)

  editor.local_save = ->
    default_theme = angular.copy($scope.theme)
    default_variables = angular.copy($scope.variables)

  editor.save = (opts = {publish: false}) ->
    action = if opts.publish then "publish" else "save"
    answer = confirm("Do you really want to #{action} these changes?")
    return if (!answer)

    #style = themeToLess()
    body = themeToHash()
    editor.busy = true
    theme_action = if opts.publish then "published" else "saved"
    themeEditorSvc.saveTheme(body,opts).then(
      ->
        editor.local_save()
        toastr.info("Theme #{theme_action}")
      -> toastr.error('Error while saving theme')
    ).finally(-> editor.busy = false)

  editor.export = () ->
    # Update the Text Area
    # editor.output = output = themeToLess()
    editor.output = output = angular.toJson(themeToHash(),true)

    # Create and download the less file
    if $window.navigator.msSaveBlob
      blobObject = new Blob([editor.output], {type: 'data:attachment/csv;charset=utf-8'})
      $window.navigator.msSaveBlob(blobObject, 'live-previewer.json') # Now the user will have the option of clicking the Save button and the Open button.
    else
      anchor = angular.element('<a/>')
      anchor.css({display: 'none'}) # Make sure it's not visible
      angular.element(document.body).append(anchor) # Attach to document
      anchor.attr({
        href: 'data:attachment/csv;charset=utf-8,' + encodeURI(output),
        target: '_blank',
        download: 'live-previewer.json'
      })[0].click()

    anchor.remove() # Clean it up afterwards

    return true

  editor.import = ->
    editor.busy = true
    #loadThemeData(themeEditorSvc.parseLessVars(editor.output))
    loadThemeData(angular.fromJson([editor.output]))
    editor.update().then ->
      editor.busy = false
      toastr.info('Theme has been imported')

  editor.updateLogo = () ->
    editor.isUpdatingLogo = true
    logo = angular.element($('#theme-main-logo'))[0].files[0]
    themeEditorSvc.saveLogo(logo).then(->
      toastr.info('Logo updated, please refresh the page')
    ).finally(-> editor.isUpdatingLogo = false)

  #============================================
  # Private method
  #============================================
  # Convert the theme JS object to a less String
  themeToLess = ->
    output = "/****** Live Theme ****/\r\n/* Theme */ \r\n"
    _.forEach(theme, (value, key) ->
      variable = "#{key}: "
      output += _.padRight(variable, key_length) + value + ';\r\n'
    )

    output += "\r\n/* Variables */ \r\n"
    _.forEach(variables, (vars, section) ->
      output += "// #{section}\r\n"
      _.forEach(vars, (value, key) ->
        output += "#{key}: " + value + ';\r\n'
      )
      output += "\r\n"
    )

    return output

  themeToHash = ->
    return {
      branding: theme,
      variables: variables
    }

  # Build a JS object than can be passed to lessjs
  mergeLessVars = ->
    lessVars = angular.extend({}, theme)
    _.forEach(variables, (vars, key) ->
      angular.extend(lessVars, vars)
    )
    return lessVars

  # Load custom theme
  loadLastSavedTheme = ->
    themeEditorSvc.getTheme().then(
      (data) ->
        loadThemeData(data)
        editor.local_save()
      (error) ->
        $log.info('No custom theme found')
    )

  loadThemeData = (lessVars) ->
    data = flattenObject(lessVars)

    _.forEach(theme, (value, key) ->
      if data[key]
        theme[key] = data[key]
    )

    _.forEach(variables, (vars, section) ->
      _.forEach(vars, (value, key) ->
        if data[key]
          variables[section][key] = data[key]
      )
    )

  # Flatten an object with nested objects into
  # a single depth object
  flattenObject = (ob) ->
    flatObj = {}
    for i of ob
      continue unless ob.hasOwnProperty(i)
      if (typeof ob[i]) is "object"
        flatObject = flattenObject(ob[i])
        for x of flatObject
          continue unless flatObject.hasOwnProperty(x)
          flatObj[x] = flatObject[x]
      else
        flatObj[i] = ob[i]
    return flatObj

  # Init
  loadLastSavedTheme()

  # Handle unsaved changes notifications
  unsavedChanges = () ->
    !angular.equals($scope.variables, default_variables) || !angular.equals($scope.theme, default_theme)

  $window.onbeforeunload = (e) ->
    if unsavedChanges()
      true
    else
      undefined

  $scope.$on('$destroy', () ->
    $window.onbeforeunload = undefined
  )

angular.module 'mnoEnterpriseAngular'
  .directive('themeEditor', ->
    return {
      restrict: 'EA'
      controller: ThemeEditorCtrl
      templateUrl: 'app/components/theme-editor/theme-editor.html',
    }
  )
