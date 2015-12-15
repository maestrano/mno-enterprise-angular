angular.module 'mnoEnterpriseAngular'
  .service 'themeEditorSvc', ($log, $http) ->
    _self = @

    @saveTheme = (theme) ->
      # Define a boundary, I stole this from IE but you can use any string AFAIK
      boundary = "---------------------------7da24f2e50046"
      body = '--' + boundary + '\r\n'
      # Parameter name is "file" and local filename is "temp.txt"
      body += 'Content-Disposition: form-data; name="file";' + 'filename="temp.txt"\r\n'
      # Add the file's mime-type
      body += 'Content-type: plain/text\r\n\r\n'
      # Add your data
      body +=  '/****** Live Theme ****/' + '\r\n'
      body += theme + '\r\n'
      body += '--'+ boundary + '--'

      uploadUrl = '/mnoe_theme_previewer'

      $http.post(uploadUrl, body, {
        transformRequest: angular.identity,
        headers: {'Content-Type': "multipart/form-data; boundary="+boundary}
      })
      .success(-> $log.debug('success'))
      .error(-> $log.debug('error'))

    return @

themeEditorCtrl = ($scope, $log, $timeout, themeEditorSvc) ->
  $scope.editor = editor = {busy: false, output: ''}

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

  # Length of longest key (for padding purpose)
  key_length = _.max(_.keys(default_theme), (k) -> k.length).length + 2

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

  editor.update = () ->
    editor.busy = true
    # Timeout to not refresh ui before freezing it with the less compilation
    $timeout(
      -> less.modifyVars(theme).then(-> editor.busy = false)
    , 100)

  editor.reset = () ->
    editor.busy = true
    $scope.theme = theme = angular.copy(default_theme)
    editor.update()

  editor.save = () ->
    # Gruik Gruik! Let's get the compiled css and save it to disk :D
    style = document.getElementById('less:styles-app').innerHTML
    themeEditorSvc.saveTheme(style)


  editor.export = () ->
    # Update  the Text Area
    output = ""
    _.forEach(theme, (value, key) ->
      variable = "#{key}: "
      output += _.padRight(variable, key_length) + value + ';\r\n'
    )
    editor.output  = output

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

angular.module 'mnoEnterpriseAngular'
  .directive('themeEditor', ->
    return {
      restrict: 'EA'
      controller: themeEditorCtrl
      templateUrl: 'app/components/theme-editor/theme-editor.html',
    }
  )
