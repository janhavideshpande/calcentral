'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlAddressFields = '/api/campus_solutions/address_label';
  var urlCountries = '/api/campus_solutions/country';
  var urlDeleteLanguage = '/api/campus_solutions/language';
  // var urlLanguageCodes = '/dummy/json/language_codes.json';
  var urlLanguageCodes = '/api/campus_solutions/language_code';
  // var urlPerson = '/dummy/json/student_with_languages.json';
  var urlCurrencies = '/api/campus_solutions/currency_code';
  var urlPerson = '/api/edos/student';
  var urlStates = '/api/campus_solutions/state';
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesAddress = '/api/campus_solutions/address_type';
  var urlTypesEmail = urlTypes + '?field_name=E_ADDR_TYPE';
  var urlTypesPayFrequency = urlTypes + '?field_name=PAY_FREQ_ABBRV';
  var urlTypesPhone = urlTypes + '?field_name=PHONE_TYPE';
  var urlWorkExperience = '/api/edos/work_experience';

  var urlPostAddress = '/api/campus_solutions/address';
  var urlPostEmail = '/api/campus_solutions/email';
  var urlPostLanguage = '/api/campus_solutions/language';
  var urlPostName = '/api/campus_solutions/person_name';
  var urlPostPhone = '/api/campus_solutions/phone';
  var urlPostWorkExperience = '/api/campus_solutions/work_experience';

  // Delete
  var deleteAddress = function(options) {
    return $http.delete(urlPostAddress + '/' + options.type, options);
  };
  var deleteEmail = function(options) {
    return $http.delete(urlPostEmail + '/' + options.type, options);
  };
  var deleteLanguage = function(options) {
    return $http.delete(urlDeleteLanguage + '/' + options.languageCode, options);
  };
  var deletePhone = function(options) {
    return $http.delete(urlPostPhone + '/' + options.type, options);
  };
  var deleteWorkExperience = function(options) {
    return $http.delete(urlPostWorkExperience + '/' + options.sequenceNbr, options);
  };

  // Get - General
  var getAddressFields = function(options) {
    return apiService.http.request(options, urlAddressFields + '?country=' + options.country);
  };
  var getCountries = function(options) {
    return apiService.http.request(options, urlCountries);
  };
  var getLanguageCodes = function(options) {
    return apiService.http.request(options, urlLanguageCodes);
  };
  var getCurrencies = function(options) {
    return apiService.http.request(options, urlCurrencies);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };
  var getStates = function(options) {
    return apiService.http.request(options, urlStates + '?country=' + options.country);
  };
  var getWorkExperience = function(options) {
    return apiService.http.request(options, urlWorkExperience);
  };

  // Get - Types
  var getTypesAddress = function(options) {
    return apiService.http.request(options, urlTypesAddress);
  };
  var getTypesEmail = function(options) {
    return apiService.http.request(options, urlTypesEmail);
  };
  var getTypesPhone = function(options) {
    return apiService.http.request(options, urlTypesPhone);
  };
  var getTypesPayFrequency = function(options) {
    return apiService.http.request(options, urlTypesPayFrequency);
  };

  // Post
  var postAddress = function(options) {
    return $http.post(urlPostAddress, options);
  };
  var postEmail = function(options) {
    return $http.post(urlPostEmail, options);
  };
  var postLanguage = function(options) {
    return $http.post(urlPostLanguage, options);
  };
  var postName = function(options) {
    return $http.post(urlPostName, options);
  };
  var postPhone = function(options) {
    return $http.post(urlPostPhone, options);
  };
  var postWorkExperience = function(options) {
    return $http.post(urlPostWorkExperience, options);
  };

  return {
    deleteAddress: deleteAddress,
    deleteEmail: deleteEmail,
    deleteLanguage: deleteLanguage,
    deletePhone: deletePhone,
    deleteWorkExperience: deleteWorkExperience,
    getCountries: getCountries,
    getCurrencies: getCurrencies,
    getAddressFields: getAddressFields,
    getLanguageCodes: getLanguageCodes,
    getPerson: getPerson,
    getStates: getStates,
    getTypesAddress: getTypesAddress,
    getTypesEmail: getTypesEmail,
    getTypesPayFrequency: getTypesPayFrequency,
    getTypesPhone: getTypesPhone,
    getWorkExperience: getWorkExperience,
    postAddress: postAddress,
    postEmail: postEmail,
    postLanguage: postLanguage,
    postName: postName,
    postPhone: postPhone,
    postWorkExperience: postWorkExperience
  };
});
