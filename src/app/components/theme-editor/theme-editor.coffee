themeEditorCtrl = ($scope, $log) ->
  $scope.editor = editor = {}

  $scope.theme = theme = {
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
    less.modifyVars(
      theme
    )

angular.module 'mnoEnterpriseAngular'
  .directive('themeEditor', ->
    return {
      restrict: 'EA'
      controller: themeEditorCtrl
      templateUrl: 'app/components/theme-editor/theme-editor.html',
    }
  )
