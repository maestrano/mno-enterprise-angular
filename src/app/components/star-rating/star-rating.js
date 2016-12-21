// http://angulartutorial.blogspot.com/2014/03/rating-stars-in-angular-js-using.html

angular.module("mnoEnterpriseAngular")
.directive("starRating", function() {
  return {
    restrict : "EA",
    template : "<ul class='rating' ng-class='{readonly: readonly}'>" +
               "  <li ng-repeat='star in stars' ng-class='star' ng-click='toggle($index)'>" +
               "    <i class='fa fa-star'></i>" + //&#9733
               "  </li>" +
               "</ul>",
    scope : {
      ratingValue : "=ngModel",
      max : "=?", //optional: default is 5
      onRatingSelected : "&?",
      readonly: "=?",
      hasClicked: '='
    },

    link : function(scope) {
      if (scope.max == undefined) { scope.max = 5; }

      scope.readonly = true

      scope.toggle = function(index) {
        if (scope.hasClicked == undefined || scope.hasClicked == false) {
          scope.hasClicked = true;
          scope.readonly = false;
        };
        if (scope.readonly == undefined || scope.readonly == false){
          scope.ratingValue = index + 1;
          if (scope.onRatingSelected) {
            scope.onRatingSelected({
              rating: index + 1
            });
          }
        }
      };

      function updateStars() {
        scope.stars = [];
        for (var i = 0; i < scope.max; i++) {
          scope.stars.push({
            filled : (i < scope.ratingValue)
          });
        }
      }

      scope.$watch("ratingValue", function(oldVal, newVal) {
        if (newVal) { updateStars(); }
      });
    }
  };
})

