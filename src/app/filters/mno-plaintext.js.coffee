# Usage:
# {{some_text | htmlToPlaintext}}

angular.module 'mnoEnterpriseAngular'
  .filter('htmlToPlaintext', -> (text) ->

    angular.element(text).text()
  )
