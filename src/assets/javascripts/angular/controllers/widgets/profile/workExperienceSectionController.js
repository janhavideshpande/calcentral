'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Work Exprience Section controller
 */
angular.module('calcentral.controllers').controller('WorkExperienceSectionController', function(apiService, profileFactory, $scope) {
  var initialState = {
    countries: [],
    currencies: [],
    currentObject: {},
    employFracValues: [
      {
        value: '100',
        label: 'Full Time'
      },
      {
        value: '75',
        label: '3/4 Time'
      },
      {
        value: '50',
        label: 'Half Time'
      },
      {
        value: '25',
        label: '1/4 Time'
      }
    ],
    emptyObject: {
      country: 'USA',
      currencyType: 'USD',
      payFrequency: 'M',
      startDt: '',
      endDt: ''
    },
    errorMessage: '',
    isSaving: false,
    isWorkExperience: true,
    items: {
      content: [],
      editorEnabled: false
    },
    states: [],
    typesPayFrequency: []
  };

  angular.extend($scope, initialState);
  var initialEdit = {
    state: '',
    load: false
  };
  var countryWatcher;

  /**
   * Format a specific date to the MM/DD/YYYY format
   */
  var formatDate = function(date) {
    return apiService.date.moment(date, 'YYYY-MM-DD').format('L');
  };

  /**
   * Format the dates in the work exprience API
   */
  var formatDates = function(data) {
    if (!data) {
      return;
    }
    var toFormatDates = ['payFrequency.fromDate', 'payFrequency.toDate'];

    _.map(data, function(dataElement) {
      _.each(toFormatDates, function(toFormatDate) {
        var date = _.get(dataElement, toFormatDate);
        if (date) {
          _.set(dataElement, toFormatDate, formatDate(date));
        }
      });
      return dataElement;
    });

    return data;
  };

  /**
   * We only want the City and State fields from the AddressFields
   */
  var returnCityState = function(fields) {
    if (fields.field === 'state' || fields.field === 'city') {
      return fields;
    }
    return;
  };

  var parseAddressFields = function(data) {
    $scope.currentObject.fields = _.filter(_.get(data, 'data.feed.labels'), returnCityState);
  };

  var parseCountries = function(data) {
    $scope.countries = _.sortBy(_.filter(_.get(data, 'data.feed.countries'), {
      hasAddressFields: true
    }), 'descr');
  };

  var parseCurrencies = function(data) {
    $scope.currencies = _.sortBy(_.get(data, 'data.feed.currencyCodes'), 'currencyCd');
  };

  var parseStates = function(data) {
    $scope.states = _.sortBy(_.get(data, 'data.feed.states'), 'descr');
    if ($scope.states && $scope.states.length) {
      angular.merge($scope.currentObject, {
        data: {
          state: initialEdit.state
        }
      });
      initialEdit.state = '';
    }
  };

  var parseTypesPayFrequency = function(data) {
    $scope.typesPayFrequency = _.get(data, 'data.feed.xlatvalues.values');
  };

  var parseWorkExperience = function(data) {
    var parsedData = formatDates(_.get(data, 'data.feed.workExperiences'));
    angular.extend($scope, {
      items: {
        content: parsedData
      }
    });
  };

  /**
   * Removes previous address data, we need to do this every time you change the country
   */
  var removePreviousAddressData = function() {
    $scope.currentObject.data = _.fromPairs(_.map($scope.currentObject.data, function(value, key) {
      if (['currencyType', 'country', 'employmentDescr', 'employFrac', 'endDt', 'endingPayRate', 'hoursPerWeek', 'payFrequency', 'phone', 'sequenceNbr', 'startDt', 'titleLong'].indexOf(key) === -1) {
        return [key, ''];
      } else {
        return [key, value];
      }
    }));
  };

  var countryWatch = function(countryCode) {
    if (!countryCode) {
      return;
    }
    if (!initialEdit.load) {
      removePreviousAddressData();
      apiService.profile.removeErrorMessage($scope);
    }
    $scope.currentObject.stateFieldLoading = true;
    initialEdit.load = false;
    // Get the different address fields / labels for the country
    profileFactory.getAddressFields({
      country: countryCode
    })
    .then(parseAddressFields)
    // Get the states for a certain country (if available)
    .then(function() {
      return profileFactory.getStates({
        country: countryCode
      });
    })
    .then(parseStates)
    .then(function() {
      $scope.currentObject.stateFieldLoading = false;
    });
  };

  /**
   * We need to watch when the country changes, if so, load the address fields dynamically depending on the country
   */
  var startCountryWatch = function() {
    countryWatcher = $scope.$watch('currentObject.data.country', countryWatch);
  };

  var getWorkExperience = profileFactory.getWorkExperience;
  var getCountries = profileFactory.getCountries;
  var getCurrencies = profileFactory.getCurrencies;
  var getTypesPayFrequency = profileFactory.getTypesPayFrequency;

  var loadInformation = function(options) {
    $scope.isLoading = true;

    // If we were previously watching, we need to remove that
    if (countryWatcher) {
      countryWatcher();
    }

    getWorkExperience({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parseWorkExperience)
    .then(getCountries)
    .then(parseCountries)
    .then(startCountryWatch)
    .then(getCurrencies)
    .then(parseCurrencies)
    .then(getTypesPayFrequency)
    .then(parseTypesPayFrequency)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(data) {
    apiService.profile.actionCompleted($scope, data, loadInformation);
  };

  var deleteCompleted = function(data) {
    $scope.isDeleting = false;
    actionCompleted(data);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    actionCompleted(data);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
    $scope.currentObject.data = {
      sequenceNbr: item.id,
      employmentDescr: item.employer,
      country: item.address.countryCode || 'USA',
      phone: item.phone.number,
      startDt: item.payFrequency.fromDate || '',
      endDt: item.payFrequency.toDate || '',
      titleLong: item.jobTitle,
      employFrac: item.fullTimePercentage,
      hoursPerWeek: item.weeklyHours || '',
      endingPayRate: item.payRate || '',
      currencyType: item.payCurrency.code,
      payFrequency: item.payFrequency.code,
      city: item.address.city
    };
    initialEdit.state = item.address.stateCode;
    initialEdit.load = true;
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteWorkExperience, item)
    .then(deleteCompleted);
  };

  $scope.save = function(item) {
    var merge = _.merge({
      sequenceNbr: item.sequenceNbr,
      employmentDescr: item.employmentDescr,
      country: item.country,
      phone: item.phone,
      startDt: item.startDt,
      endDt: item.endDt,
      titleLong: item.titleLong,
      employFrac: item.employFrac,
      hoursPerWeek: item.hoursPerWeek,
      endingPayRate: item.endingPayRate,
      currencyType: item.currencyType,
      payFrequency: item.payFrequency
    }, apiService.profile.matchFields($scope.currentObject.fields, item));

    apiService.profile
      .save($scope, profileFactory.postWorkExperience, merge)
      .then(saveCompleted);
  };

  loadInformation();
});
