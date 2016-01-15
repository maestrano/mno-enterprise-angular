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
    'Login Box': {
      '@login-box-bg-color':                 '@bg-inverse-color'
      '@login-box-padding':                  '20px'
      '@login-box-brand-logo':               '{ min-height: 61px; max-width: 160px; max-height: 130px; margin: 17px auto 5px auto; }'
      '@login-box-btn-login':                '{ width: 100%; }'
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
    }
  }
  $scope.variables = variables = angular.copy(default_variables)

  #============================================
  # View methods
  #============================================
  $scope.editor = editor = {busy: false, output: ''}

  editor.update = () ->
    editor.busy = true

    vars = mergeLessVars()

    # Timeout to not refresh ui before freezing it with the less compilation
    $timeout(
      -> less.modifyVars(vars).then(-> editor.busy = false)
    , 100)

  editor.reset = () ->
    editor.busy = true
    $scope.theme = theme = angular.copy(default_theme)
    $scope.variables = variables = angular.copy(default_variables)
    editor.update()

  editor.save = () ->
    # Gruik Gruik! Let's get the compiled css and save it to disk :D
    # style = document.getElementById('less:styles-app').innerHTML

    style = themeToLess()
    editor.busy = true
    themeEditorSvc.saveTheme(style).then(
      -> toastr.info('Theme saved')
      -> toastr.error('Error while saving theme')
    ).finally(-> editor.busy = false)

  editor.export = () ->
    # Update  the Text Area
    editor.output = output = themeToLess()

    # Create and download the less file
    anchor = angular.element('<a/>')
    anchor.css({display: 'none'}) # Make sure it's not visible
    angular.element(document.body).append(anchor) # Attach to document

    anchor.attr({
      href: 'data:attachment/csv;charset=utf-8,' + encodeURI(output),
      target: '_blank',
      download: 'theme.less'
    })[0].click()

    anchor.remove() # Clean it up afterwards

    return true

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
      _.forEach(vars, (value, key) ->
        output += "#{key}: " + value + ';\r\n'
      )
    )

    return output

  # Build a JS object than can be passed to lessjs
  mergeLessVars = ->
    lessVars = angular.extend({}, theme)
    _.forEach(variables, (vars, key) ->
      angular.extend(lessVars, vars)
    )
    return lessVars

  # Load custom theme
  loadCustomTheme = ->
    themeEditorSvc.getTheme().then(
      (data) ->
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
      (error) ->
        $log.info('No custom theme found')
    )

  # Init
  loadCustomTheme()

angular.module 'mnoEnterpriseAngular'
  .directive('themeEditor', ->
    return {
      restrict: 'EA'
      controller: ThemeEditorCtrl
      templateUrl: 'app/components/theme-editor/theme-editor.html',
    }
  )
