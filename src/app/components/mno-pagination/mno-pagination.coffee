#
# Pagination Directive
#
angular.module 'mnoEnterpriseAngular'
  .constant('ITEMS_PER_PAGE', [5, 10, 20, 50, 100])

angular.module 'mnoEnterpriseAngular'
  .directive('mnoPagination', (ITEMS_PER_PAGE) ->
    restrict: 'AE'
    scope: {
      totalItems: '=',
      onChangeCb: '&',
      nbItemsValues: '=?',
      nbItems: '=',
      page: '=',
      isLoading: '=?'
    },
    templateUrl: 'app/components/mno-pagination/mno-pagination.html',

    link: (scope) ->
      scope.pagination =
        maxPages: 7

      if !scope.nbItemsValues
        scope.nbItemsValues = ITEMS_PER_PAGE

      scope.onPageChange = () ->
        scope.onChangeCb({nbItems: scope.nbItems, page: scope.page})
)
