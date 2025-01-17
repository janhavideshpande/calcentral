'use strict';

var angular = require('angular');

/**
 * Configure the routes for CalCentral
 */
angular.module('calcentral.config').config(function($routeProvider) {
  // List all the routes
  $routeProvider.when('/', {
    templateUrl: 'splash.html',
    controller: 'SplashController',
    isPublic: true
  }).
  when('/academics', {
    templateUrl: 'academics.html',
    controller: 'AcademicsController'
  }).
  when('/academics/semester/:semesterSlug', {
    templateUrl: 'academics_semester.html',
    controller: 'AcademicsController'
  }).
  when('/academics/semester/:semesterSlug/class/:classSlug', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController'
  }).
  when('/academics/semester/:semesterSlug/class/:classSlug/:sectionSlug', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController'
  }).
  when('/academics/booklist/:semesterSlug', {
    templateUrl: 'academics_booklist.html',
    controller: 'AcademicsController'
  }).
  when('/academics/teaching-semester/:teachingSemesterSlug/class/:classSlug', {
    templateUrl: 'academics_classinfo.html',
    controller: 'AcademicsController'
  }).
  when('/calcentral_update', {
    templateUrl: 'calcentral_update.html',
    controller: 'CalCentralUpdateController'
  }).
  when('/campus/:category?', {
    templateUrl: 'campus.html',
    controller: 'CampusController'
  }).
  when('/dashboard', {
    templateUrl: 'dashboard.html',
    controller: 'DashboardController',
    fireUpdatedFeeds: true
  }).
  when('/delegate_welcome', {
    templateUrl: 'delegate_welcome.html',
    controller: 'DelegateWelcomeController'
  }).
  when('/finances', {
    templateUrl: 'myfinances.html',
    controller: 'MyFinancesController'
  }).
  when('/finances/details', {
    templateUrl: 'cars_details.html',
    controller: 'MyFinancesController'
  }).
  when('/finances/finaid/:finaidYearId?', {
    templateUrl: 'finaid.html',
    controller: 'MyFinancesController'
  }).
  when('/finances/finaid/awards/:finaidYearId?', {
    templateUrl: 'finaid_awards_term.html',
    controller: 'MyFinancesController'
  }).
  when('/oec', {
    templateUrl: 'oec.html',
    controller: 'OecController'
  }).
  when('/profile/:category?', {
    templateUrl: 'profile.html',
    controller: 'ProfileController'
  }).
  when('/toolbox', {
    templateUrl: 'toolbox.html',
    controller: 'MyToolboxController'
  }).
  when('/uid_error', {
    templateUrl: 'uid_error.html',
    controller: 'uidErrorController',
    isPublic: true
  }).
  when('/canvas/embedded/rosters', {
    templateUrl: 'canvas_embedded/roster.html',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/site_creation', {
    templateUrl: 'canvas_embedded/site_creation.html',
    controller: 'CanvasSiteCreationController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/site_mailing_lists', {
    templateUrl: 'canvas_embedded/site_mailing_list.html',
    controller: 'CanvasSiteMailingListController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/create_course_site', {
    templateUrl: 'canvas_embedded/create_course_site.html',
    controller: 'CanvasCreateCourseSiteController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/create_project_site', {
    templateUrl: 'canvas_embedded/create_project_site.html',
    controller: 'CanvasCreateProjectSiteController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/user_provision', {
    templateUrl: 'canvas_embedded/user_provision.html',
    controller: 'CanvasUserProvisionController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/course_add_user', {
    templateUrl: 'canvas_embedded/course_add_user.html',
    controller: 'CanvasCourseAddUserController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/course_mediacasts', {
    templateUrl: 'canvas_embedded/course_mediacasts.html',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/course_manage_official_sections', {
    templateUrl: 'canvas_embedded/course_manage_official_sections.html',
    controller: 'CanvasCourseManageOfficialSectionsController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/embedded/course_grade_export', {
    templateUrl: 'canvas_embedded/course_grade_export.html',
    controller: 'CanvasCourseGradeExportController',
    isBcourses: true,
    isEmbedded: true
  }).
  when('/canvas/rosters/:canvasCourseId', {
    templateUrl: 'canvas_embedded/roster.html',
    isBcourses: true
  }).
  when('/canvas/site_creation', {
    templateUrl: 'canvas_embedded/site_creation.html',
    controller: 'CanvasSiteCreationController',
    isBcourses: true
  }).
  when('/canvas/create_course_site', {
    templateUrl: 'canvas_embedded/create_course_site.html',
    controller: 'CanvasCreateCourseSiteController',
    isBcourses: true
  }).
  when('/canvas/create_project_site', {
    templateUrl: 'canvas_embedded/create_project_site.html',
    controller: 'CanvasCreateProjectSiteController',
    isBcourses: true
  }).
  when('/canvas/course_manage_official_sections/:canvasCourseId', {
    templateUrl: 'canvas_embedded/course_manage_official_sections.html',
    controller: 'CanvasCourseManageOfficialSectionsController',
    isBcourses: true
  }).
  when('/canvas/course_grade_export/:canvasCourseId', {
    templateUrl: 'canvas_embedded/course_grade_export.html',
    controller: 'CanvasCourseGradeExportController',
    isBcourses: true
  }).
  when('/canvas/site_mailing_list', {
    templateUrl: 'canvas_embedded/site_mailing_list.html',
    controller: 'CanvasSiteMailingListController',
    isBcourses: true
  }).
  when('/canvas/user_provision', {
    templateUrl: 'canvas_embedded/user_provision.html',
    controller: 'CanvasUserProvisionController',
    isBcourses: true
  }).
  when('/canvas/course_add_user/:canvasCourseId', {
    templateUrl: 'canvas_embedded/course_add_user.html',
    controller: 'CanvasCourseAddUserController',
    isBcourses: true
  }).
  when('/canvas/course_mediacasts/:canvasCourseId', {
    templateUrl: 'canvas_embedded/course_mediacasts.html',
    isBcourses: true
  }).
  // Redirect to a 404 page
  otherwise({
    templateUrl: '404.html',
    controller: 'ErrorController',
    isPublic: true
  });
});
