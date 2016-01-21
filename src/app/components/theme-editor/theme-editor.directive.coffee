ThemeEditorCtrl = ($scope, $log, $timeout,  toastr, themeEditorSvc) ->
  'ngInject'

  #============================================
  # Theme Config
  #============================================
  default_theme = {
    # Main colors
    '@bg-main-color':        "#aeb5bf"
    '@decorator-main-color': "#758192"
    '@decorator-alt-color':  "#977bf0"
    '@text-strong-color':    "#17262d"

    # Inverse colors
    '@bg-inverse-color':               "#ffffff"
    '@bg-on-bg-inverse-color':         "#cacfd6"
    '@bg-inverse-intense-color':       "#17262d"
    '@decorator-inverse-color':        "#977bf0"
    '@text-inverse-color':             "#17262d"

    # Color used in small/isolated elements
    '@elem-positive-color':            "#d1e55c"
    '@elem-positive-flash-color':      "#47ff00"
    '@elem-cozy-color':                "#977bf0"
  }

  $scope.theme = theme = angular.copy(default_theme)

  $scope.labels = {
    # Main colors
    '@bg-main-color':          "Dashboard background color"
    '@decorator-main-color':   "Elements placed on top of bg-main-color"
    '@decorator-alt-color':    "Elements placed on top of bg-main-color (secondary)"
    '@text-strong-color':      "Used for text used in the context of bg-main-color"
    # Inverse colors
    '@bg-inverse-color':       "Background color used for dashboard side menu. top banners, inverse modals"
    '@bg-on-bg-inverse-color': "Background color for elements displayed on top of inverse elements"
    '@bg-inverse-intense-color':       "Background color used for elements on top of bg-inverse-color"
    '@decorator-inverse-color':        "Design elements (lines, borders) on top of bg-inverse-color"
    '@text-inverse-color':             "Text used on top of bg-inverse-color such as inverse modals"

    # Color used in small/isolated elements
    '@elem-positive-color':            "used to reflect a positive action or point (e.g: tick icon)"
    '@elem-positive-flash-color':      "stronger version of elem-positive-color (barely used)"
    '@elem-cozy-color':                "used for regular design element - fits well with both main and inverse backgrounds"
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
      '@brand-success':                  '@elem-positive-color'
      '@brand-warning':                  '@decorator-alt-color'
      '@brand-info':                     '@text-inverse-color'
      '@brand-danger':                   '@text-inverse-color'
      '@brand-primary':                  '@text-inverse-color'
    },

    'Forms': {
      '@input-bg': '@elem-cozy-color'
      '@input-color': '@text-inverse-color'
      '@input-color-placeholder': '@input-color'

      '@input-label-color': '@text-inverse-color'
    }

    'Public Page Header': {
      '@public-page-header-bg-color':        '@bg-inverse-color'
      '@public-page-header-padding':         '10px'
      '@public-page-header-logo':            '{ min-height: 61px; max-width: 160px; max-height: 130px; margin: 17px auto 5px auto; }'
    },


    'Login Page': {
      '@login-bg-color':                     '@bg-main-color'
      '@login-box-bg-color':                 '@bg-inverse-color'
      '@login-box-padding':                  '20px'
      '@login-box-brand-logo':               '{ min-height: 61px; max-width: 160px; max-height: 130px; margin: 17px auto 5px auto; }'
      '@login-box-btn-login':                '{ width: 100%; }'
      '@login-box-grid-position':            '{ margin-top: 80px; .make-sm-column(4); .make-sm-column-offset(4); }'

      '@login-box-title-color':              '@decorator-main-color'
      '@login-box-title':                    '{ text-transform: uppercase; }'
      '@login-box-title-display-box-arrow':  'false'
    },

    'Dashboard Layout': {
      '@dashboard-bg-color':                            '@bg-main-color'

      '@dashboard-section-title-color':                 '@text-strong-color'
      '@dashboard-section-title-alignment':             'center'
      '@dashboard-section-title-display-subline':       'false'
    },

    'Dashboard Side Menu': {
      '@dashboard-side-menu-padding': '30px 0px 0px 14px'
      '@dashboard-side-menu-bg-color': '@bg-inverse-color'
      '@dashboard-side-menu-brand-logo': '{ background-size: 204px; width: 51px; margin-left: 5px; }'
      '@dashboard-side-menu-brand-logo-expanded': '{ width: 201px; background-size: 100%; }'

      '@dashboard-side-menu-link-color':               '@text-inverse-color'
      '@dashboard-side-menu-link-bg-color':            '@dashboard-side-menu-bg-color'
      '@dashboard-side-menu-link-hover-color':         '@dashboard-side-menu-bg-color'
      '@dashboard-side-menu-link-hover-bg-color':      'lighten(@bg-main-color,15%)'
      '@dashboard-side-menu-link-active-color':        '@dashboard-side-menu-bg-color'
      '@dashboard-side-menu-link-active-bg-color':     '@bg-main-color'
    },

    'Dashboard Company Select Box': {
      '@dashboard-cpy-select-bg-color':                 '@bg-inverse-color'
      '@dashboard-cpy-select-border-radius':            '0px'
      '@dashboard-cpy-select-padding':                  '15px 25px'

      '@dashboard-cpy-select-header-text-color':        '@text-inverse-color'
      '@dashboard-cpy-select-header-text-size':         '13px'

      '@dashboard-cpy-select-link-color':               '@dashboard-cpy-select-header-text-color'

      '@dashboard-cpy-select-link-hover-color':         '@dashboard-cpy-select-link-color'
      '@dashboard-cpy-select-link-hover-bg-color':      'lighten(@dashboard-cpy-select-bg-color,10%)'

      '@dashboard-cpy-select-link-create-color':        '@decorator-alt-color'
      '@dashboard-cpy-select-link-admin-color':         '@elem-positive-color'

      '@dashboard-cpy-select-switch-btn-color':         '@dashboard-cpy-select-header-text-color'
      '@dashboard-cpy-select-switch-btn-bg-color':      '@dashboard-cpy-select-bg-color'
    },

    'Dashboard Loader': {
      '@dashboard-loader-color':                        '@bg-inverse-color'
      '@dashboard-loader-icon':                         '{ .icon-fa(refresh); .fa-2x; .fa-spin; }'
    },

    'Apps Section': {
      '@dashboard-apps-tile-bg-color':                  '@bg-inverse-color'
      '@dashboard-apps-tile-text-color':                '@text-inverse-color'

      '@dashboard-apps-tile-logo-border-size':          '0px'
      '@dashboard-apps-tile-logo-border-color':         '@decorator-main-color'

      '@dashboard-apps-tile-settings-color':            '@dashboard-apps-tile-text-color'
      '@dashboard-apps-tile-settings-bg-color':         '@dashboard-apps-tile-bg-color'

      '@dashboard-apps-tile-settings-hover-color':      '@dashboard-apps-tile-bg-color'
      '@dashboard-apps-tile-settings-hover-bg-color':   '@dashboard-apps-tile-text-color'

      '@dashboard-apps-tile-add-color':                 '@dashboard-apps-tile-bg-color'
      '@dashboard-apps-tile-add-bg-color':              '@dashboard-apps-tile-bg-color'
    },

    'Company Section': {
      '@dashboard-cpy-tabs-bg-color':                    '@bg-inverse-color'
      '@dashboard-cpy-tabs-text-color':                  '@text-inverse-color'
      '@dashboard-cpy-tabs-border-radius':               '2px'

      '@dashboard-cpy-tabs-subline-size':                '0px'
      '@dashboard-cpy-tabs-subline-color':               'transparent'

      '@dashboard-cpy-tabs-active-text-color':           '@elem-positive-color'
      '@dashboard-cpy-tabs-active-bg-color':             '@bg-inverse-color'

      '@dashboard-cpy-tabs-hover-text-color':            '@elem-positive-color'
      '@dashboard-cpy-tabs-hover-bg-color':              '@bg-inverse-color'

      '@dashboard-cpy-tabcontent-bg-color':              '@dashboard-cpy-tabs-bg-color'
    },

    'Company Team Section': {
      '@dashboard-cpy-teams-matrix-bg-color':            '@bg-inverse-color'
      '@dashboard-cpy-teams-matrix-border-color':        'lighten(@bg-main-color,30%)'
    },

    'Impac Dashboard': {
      '@impac-dashboard-padding-top':                   '33px'
      '@impac-dashboard-margin-left':                   '0px'

      '@impac-dashboard-title-label-color':             '@text-strong-color'
      '@impac-dashboard-title-color':                   '@elem-cozy-color'
      '@impac-dashboard-source-color':                  '@impac-dashboard-title-label-color'
      '@impac-dashboard-buttons-border-radius':         '4px'

      '@impac-placeholder-border':                      '2px dashed @bg-inverse-color'
      '@impac-padding-between-widgets':                 '12px'
      '@impac-minimum-widget-size':                     '258px'
    },

    'Impac Widgets': {
      # Global
      '@impac-widget-background-color':                 '@bg-inverse-color'
      '@impac-widget-text-color':                       '@text-inverse-color'
      '@impac-widget-text-color-light':                 'lighten(@impac-widget-text-color,70%)'
      '@impac-widget-borders-color':                    'lighten(@impac-widget-text-color-light,10%)'
      '@impac-widget-link-color':                       '@decorator-inverse-color'

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
      '@impac-widget-price-positive-color':             '@elem-positive-color'
      '@impac-widget-price-negative-color':             '@elem-cozy-color'
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
      '@dashboard-marketplace-search-text-color':             '@bg-inverse-color'
      '@dashboard-marketplace-search-border-color':           '@bg-inverse-intense-color'

      '@dashboard-marketplace-tile-bg-color':                 '@bg-inverse-color'
      '@dashboard-marketplace-tile-text-color':               '@text-inverse-color'
      '@dashboard-marketplace-tile-img-border-color':         '@dashboard-marketplace-tile-bg-color'

      '@dashboard-marketplace-tile-hover-bg-color':           '@decorator-main-color'
      '@dashboard-marketplace-tile-hover-text-color':         '@dashboard-marketplace-tile-text-color'
      '@dashboard-marketplace-tile-hover-img-border-color':   'darken(@decorator-main-color,10%)'
      '@dashboard-marketplace-tile-hover-arrow-color':        '@text-strong-color'

      '@dashboard-marketplace-show-header-text-color':        '@bg-inverse-color'

      '@dashboard-marketplace-app-card':                      '{ display: block; padding: 10px; height: 120px; margin-bottom: 10px; font-weight: 300; }'
    },
  }
  $scope.variables = variables = angular.copy(default_variables)

  #============================================
  # View methods
  #============================================
  $scope.editor = editor = {busy: false, output: ''}

  editor.update = () ->
    return true if editor.updating
    editor.busy = true
    vars = mergeLessVars()

    # Apply style
    less.modifyVars(vars).then ->
      editor.busy = false
      $scope.$apply()

  editor.reset = (opts = {published:false}) ->
    editor.busy = true
    if opts.published
      themeEditorSvc.resetToPublishedTheme()
        .then(-> loadLastSavedTheme())
        .then(-> editor.update())
    else
      $scope.theme = theme = angular.copy(default_theme)
      $scope.variables = variables = angular.copy(default_variables)
      editor.update()

  editor.local_save = ->
    default_theme = angular.copy($scope.theme)
    default_variables = angular.copy($scope.variables)

  editor.save = (opts = {publish: false}) ->
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
    loadThemeData(angular.fromJson(editor.output))
    editor.update().then ->
      editor.busy = false
      toastr.info('Theme has been imported')

  editor.updateLogo = () ->
    logo = angular.element($('#theme-main-logo'))[0].files[0]
    themeEditorSvc.saveLogo(logo).then(->
      toastr.info('Logo updated, please refresh the page')
    )

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
    console.log(variables)
    _.forEach(variables, (vars, key) ->
      console.log(lessVars)
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
    console.log(data)

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
  toastr.info("Scroll down to start editing the dashboard style",null,{timeOut: 6000})

angular.module 'mnoEnterpriseAngular'
  .directive('themeEditor', ->
    return {
      restrict: 'EA'
      controller: ThemeEditorCtrl
      templateUrl: 'app/components/theme-editor/theme-editor.html',
    }
  )
