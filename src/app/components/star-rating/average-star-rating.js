// http://angulartutorial.blogspot.com/2014/03/rating-stars-in-angular-js-using.html

angular.module("mnoEnterpriseAngular")
.directive("averageStarRating", function() {
  return {
    restrict : "EA",
    template : "<div class='average-rating-container' ng-class='{withrating: displayRating}'}>" +
               "  <ul class='rating background' class='readonly'>" +
               "    <li ng-repeat='star in stars' class='star'>" +
               "      <i class='fa fa-star'></i>" + //&#9733
               "    </li>" +
               "  </ul>" +
               "  <ul class='rating foreground' class='readonly' style='width:{{filledInStarsContainerWidth}}%'>" +
               "    <li ng-repeat='star in stars' class='star filled'>" +
               "      <i class='fa fa-star'></i>" + //&#9733
               "    </li>" +
               "  </ul>" +
               "</div>" +
               "<span ng-if='displayRating' class='badge'>{{averageRatingValue}}</span>",
    scope : {
      averageRatingValue: "=ngModel",
      displayRating: '=?', //optional: default is false
      max: "=?" //optional: default is 5
    },
    link : function(scope) {
      if (scope.displayRating == undefined) { scope.displayRating = false; }
      if (scope.max == undefined) { scope.max = 5; }

      function updateStars() {
        scope.stars = [];
        for (var i = 0; i < scope.max; i++) {
          scope.stars.push({});
        }
        var starContainerMaxWidth = 100; //%
        scope.filledInStarsContainerWidth = scope.averageRatingValue / scope.max * starContainerMaxWidth;
      }

      scope.$watch("averageRatingValue", function(oldVal, newVal) {
        if (newVal) { updateStars(); }
      });
    }
  };
});

