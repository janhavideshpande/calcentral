'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Status controller
 */
angular.module('calcentral.controllers').controller('StatusController', function(activityFactory, apiService, badgesFactory, financesFactory, holdsFactory, $scope, $q) {
  // Keep track on whether the status has been loaded or not
  var hasLoaded = false;

  var loadStudentInfo = function(data) {
    if (!data.studentInfo || !apiService.user.profile.roles.student) {
      return;
    }

    $scope.studentInfo = data.studentInfo;

    if (_.get(data, 'studentInfo.regStatus.code')) {
      $scope.hasRegistrationData = true;
    }
    if (_.get(data, 'studentInfo.regStatus.needsAction') && apiService.user.profile.features.regstatus) {
      $scope.count++;
      $scope.hasAlerts = true;
    }
    if (data.studentInfo.regBlock.activeBlocks) {
      $scope.count += data.studentInfo.regBlock.activeBlocks;
      $scope.hasAlerts = true;
    } else if (data.studentInfo.regBlock.errored) {
      $scope.count++;
      $scope.hasWarnings = true;
    }
  };

  var loadFinances = function(data) {
    if (!data.summary) {
      return;
    }

    if (data.summary.totalPastDueAmount > 0) {
      $scope.count++;
      $scope.hasAlerts = true;
    } else if (data.summary.minimumAmountDue > 0) {
      $scope.count++;
      $scope.hasWarnings = true;
    }
    $scope.totalPastDueAmount = data.summary.totalPastDueAmount;
    $scope.minimumAmountDue = data.summary.minimumAmountDue;
    $scope.hasBillingData = ($scope.minimumAmountDue !== null);
  };

  var loadActivity = function(data) {
    if (data.activities) {
      $scope.countUndatedFinaid = data.activities.filter(function(element) {
        return element.date === '' && element.emitter === 'Financial Aid' && element.type === 'alert';
      }).length;
      if ($scope.countUndatedFinaid) {
        $scope.count += $scope.countUndatedFinaid;
        $scope.hasAlerts = true;
      }
    }
  };

  var loadHolds = function(data) {
    if (!apiService.user.profile.features.csHolds ||
      !(apiService.user.profile.roles.student || apiService.user.profile.roles.applicant)) {
      return;
    }
    $scope.holds = _.get(data, 'data.feed');
    var numberOfHolds = _.get($scope, 'holds.serviceIndicators.length');
    if (numberOfHolds) {
      $scope.count += numberOfHolds;
      $scope.hasAlerts = true;
    } else if (_.get(data, 'data.errored')) {
      $scope.holds = {
        errored: true
      };
      $scope.count++;
      $scope.hasWarnings = true;
    }
  };

  var finishLoading = function() {
    // Hides the spinner
    $scope.statusLoading = '';
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && !hasLoaded) {
      // Make sure to only load this once
      hasLoaded = true;

      // Set the error count to 0
      $scope.count = 0;
      $scope.hasAlerts = false;
      $scope.hasWarnings = false;

      // We use this to show the spinner
      $scope.statusLoading = 'Process';

      // Get all the necessary data from the different factories
      var getBadges = badgesFactory.getBadges().success(loadStudentInfo);
      var getFinances = financesFactory.getFinances().success(loadFinances);
      var getFinaidActivityOld = activityFactory.getFinaidActivityOld().then(loadActivity);
      var getHolds = holdsFactory.getHolds().then(loadHolds);

      // Make sure to hide the spinner when everything is loaded
      $q.all(getBadges, getFinances, getFinaidActivityOld, getHolds).then(finishLoading);
    }
  });
});
