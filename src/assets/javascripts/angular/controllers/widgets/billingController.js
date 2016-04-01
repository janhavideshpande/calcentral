'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('BillingController', function(apiService, financesFactory, $filter, $scope) {
  $scope.activityIncrement = 50;
  $scope.activityLimit = 100;
  $scope.billing = {
    data: {},
    isLoading: true,
    sort: {
      column: 'itemEffectiveDate',
      descending: true
    }
  };
  $scope.filter = {
    choice: 'balance',
    choices: [{
      value: 'balance',
      label: 'Balance'
    }, {
      value: 'transactions',
      label: 'All Transactions'
    }, {
      value: 'daterange',
      label: 'Date Range'
    }, {
      value: 'term',
      label: 'Term'
    }],
    addedTerms: [],
    terms: [{
      // ngRepeat will clear the filter if the value is undefined, so 'itemTermId' is not set here
      itemTermDescription: 'All'
    }],
    searchDates: {
      startDt: '',
      endDt: ''
    },
    parsedDates: {
      startDt: '',
      endDt: ''
    },
    searchTermId: {
      itemTermId: ''
    },
    searchStatus: 'Unpaid',
    statuses: {
      unpaid: 'Unpaid',
      allTransactions: ['Unpaid', 'Paid']
    }
  };
  $scope.search = {};

  var getTermOptions = function(billingItem) {
    if (!_.includes($scope.filter.addedTerms, billingItem.itemTermId)) {
      $scope.filter.addedTerms.push(billingItem.itemTermId);
      $scope.filter.terms.push({
        itemTermDescription: billingItem.itemTermDescription,
        itemTermId: billingItem.itemTermId
      });
    }
  };

  /**
   * Adds a searchable date format property to the billing object
   */
  var makeDatesSearchable = function(billingItem) {
    if (billingItem.itemEffectiveDate) {
      var itemEffectiveDateSearch = $filter('date')(billingItem.itemEffectiveDate, 'MM/dd/yy');
      _.set(billingItem, 'itemEffectiveDateSearch', itemEffectiveDateSearch);
    }
    if (billingItem.itemDueDate) {
      var itemDueDateSearch = $filter('date')(billingItem.itemDueDate, 'MM/dd/yy');
      _.set(billingItem, 'itemDueDateSearch', itemDueDateSearch);
    }
  };

  var parseAmounts = function(value) {
    if (_.isNumber(value)) {
      return value.toFixed(2);
    }
    return value;
  };

  var parseBillingInfo = function(data) {
    var billing = _.get(data, 'data.feed.ucSfActivity');

    billing.summary = _.mapValues(billing.summary, function(value) {
      value = parseAmounts(value);
      return value;
    });

    billing.activity = _.map(billing.activity, function(object) {
      var billingItem = _.mapValues(object, function(value) {
        value = parseIncomingDates(parseAmounts(value));
        return value;
      });
      return billingItem;
    });

    _.forEach(billing.activity, function(billingItem) {
      getTermOptions(billingItem);
      makeDatesSearchable(billingItem);
    });

    $scope.billing.data = billing;
  };

  var parseIncomingDates = function(value) {
    var regex = /^(\d{4})[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$/;
    var item = value + '';
    var match = item.match(regex);
    if (match && match[0]) {
      var parsedDate = new Date(match[1], parseInt(match[2], 10) - 1, match[3]);
      return parsedDate;
    }
    return value;
  };

  var resetSearch = function() {
    $scope.filter.searchTermId.itemTermId = '';
    $scope.filter.searchDates.startDt = '';
    $scope.filter.searchDates.endDt = '';
    $scope.filter.searchStatus = '';
  };

  var selectDefaultTerm = function(billingSummary) {
    var currentTermId = billingSummary.currentTermId;
    // When the current term actually exists in the activity list, we select it
    // Otherwise, we select the first item in the list
    if (_.includes($scope.filter.addedTerms, currentTermId)) {
      $scope.filter.searchTermId.itemTermId = currentTermId;
    } else {
      $scope.filter.searchTermId.itemTermId = $scope.filter.terms[0].itemTermId;
    }
  };

  var loadBillingInfo = function() {
    financesFactory.getCsFinances()
      .then(parseBillingInfo)
      .then(function() {
        $scope.billing.isLoading = false;
      });
  };

  $scope.choiceChange = function() {
    resetSearch();
    if ($scope.filter.choice === 'balance') {
      $scope.filter.searchStatus = $scope.filter.statuses.unpaid;
    } else if ($scope.filter.choice === 'transactions' || $scope.filter.choice === 'daterange') {
      // On default, we want to see all items, not just unpaid ones
      $scope.filter.searchStatus = $scope.filter.statuses.allTransactions;
    } else if ($scope.filter.choice === 'term') {
      $scope.filter.searchStatus = $scope.filter.statuses.allTransactions;
      selectDefaultTerm($scope.billing.data.summary);
    }
  };

  $scope.dateFilter = function(billingItem) {
    if ($scope.filter.parsedDates.startDt && $scope.filter.parsedDates.endDt) {
      return (_.gte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.startDt) && _.lte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.endDt));
    }
    if ($scope.filter.parsedDates.startDt) {
      return _.gte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.startDt);
    }
    if ($scope.filter.parsedDates.endDt) {
      return _.lte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.endDt);
    }
    return true;
  };

  $scope.parseEndDt = function(date) {
    $scope.filter.parsedDates.endDt = apiService.financials.createDateValues(date);
  };

  $scope.parseStartDt = function(date) {
    $scope.filter.parsedDates.startDt = apiService.financials.createDateValues(date);
  };

  $scope.printPage = function() {
    apiService.financials.printPage();
  };

  $scope.statusFilter = function(billingItem) {
    if (_.isArray($scope.filter.searchStatus)) {
      return (_.includes($scope.filter.searchStatus, billingItem.itemStatus));
    }
    return (_.isEqual($scope.filter.searchStatus, billingItem.itemStatus));
  };

  loadBillingInfo();
});
