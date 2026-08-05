import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

ProjectModel getProject() {
  try {
    final localStorage = LocalStorageManager();
    final selectedProjectString = localStorage.getString(
      StorageKey.selectedProject,
    );
    if (selectedProjectString != null) {
      return ProjectModel.fromJson(jsonDecode(selectedProjectString));
    } else {
      return ProjectModel(
        projectId: 0,
        uniquekey: "",
        projectName: "No Project Selected",
        projectLocation: "",
        projectPhotoUrl: "",
        companyId: "",
        ctsNumber: "",
        employeeId: "0",
        numberOfEmployee: 0,
        isRedevelopment: false,
        notificationCount: 0,
        clientRegistrationId: 0,
        createdById: 0,
        createdBy: "",
        createdDate: DateTime.now(),
        modifiedById: 0,
        modifiedBy: "",
        modifiedDate: DateTime.now(),
        category: '',
        bussinessCategory: '',
        fileNumber: '',
        liasoningArchitectName: '',
        liasoningArchitectMobileNumber: '',
        designingArchitectName: '',
        designingArchitectMobileNumber: '',
        rccConsultantName: '',
        rccConsultantMobileNumber: '',
        tenderAmount: 0,
        tenderEmdAmount: 0,
        tenderPurchaseStartDate: DateTime.now(),
        countryMasterId: 0,
        countryName: '',
        districtMasterId: 0,
        districtName: '',
        stateMasterId: 0,
        stateName: '',
        cityMasterId: 0,
        cityName: '',
        villageMasterId: 0,
        villageName: "",
        zipCode: '',
        projectScope: '',
        projectEstimateCost: 0,
        projectAreaInSqft: '',
        onGoingBudgetCost: '',
        surveyDate: DateTime.now(),
        expectedStartDate: DateTime.now(),
        executionStartDate: DateTime.now(),
        siteContactMobileNumber: '',
        siteContactName: '',
        projectStatus: '',
        reraNumber: '',
        reraCertificateDate: DateTime.now(),
        projectScheme: '',
        projectSubScheme: '',
        googleLocation: '',
        companyData: [],
        projectWithBankDetailsData: [],
        tenderAmountPaymentMode: '',
        tenderAmountChequeNumber: '',
        tenderAmountChequeNumberUrl: '',
        tenderAmountPayorderRemark: '',
        tenderEmdPaymentMode: '',
        tenderEmdChequeNumber: '',
        tenderEmdChequeNumberUrl: '',
        tenderEmdPayorderRemark: '',
        siteContactDesignation: '',
        siteContact2MobileNumber: '',
        siteContact2Name: '',
        siteContact2Designation: '',
        siteContact3MobileNumber: '',
        siteContact3Name: '',
        siteContact3Designation: '',
        isFederation: false,
        federationAmount: 0,
      );
    }
  } catch (e) {
    return ProjectModel(
      projectId: 0,
      uniquekey: "",
      projectName: "Default",
      projectLocation: "",
      projectPhotoUrl: "",
      companyId: "",
      ctsNumber: "",
      employeeId: "0",
      numberOfEmployee: 0,
      isRedevelopment: false,
      notificationCount: 0,
      clientRegistrationId: 0,
      createdById: 0,
      createdBy: "",
      createdDate: DateTime.now(),
      modifiedById: 0,
      modifiedBy: "",
      modifiedDate: DateTime.now(),
      category: '',
      bussinessCategory: '',
      fileNumber: '',
      liasoningArchitectName: '',
      liasoningArchitectMobileNumber: '',
      designingArchitectName: '',
      designingArchitectMobileNumber: '',
      rccConsultantName: '',
      rccConsultantMobileNumber: '',
      tenderAmount: 0,
      tenderEmdAmount: 0,
      tenderPurchaseStartDate: DateTime.now(),
      countryMasterId: 0,
      countryName: '',
      districtMasterId: 0,
      districtName: '',
      stateMasterId: 0,
      stateName: '',
      cityMasterId: 0,
      cityName: '',
      villageMasterId: 0,
      villageName: "",
      zipCode: '',
      projectScope: '',
      projectEstimateCost: 0,
      projectAreaInSqft: '',
      onGoingBudgetCost: '',
      surveyDate: DateTime.now(),
      expectedStartDate: DateTime.now(),
      executionStartDate: DateTime.now(),
      siteContactMobileNumber: '',
      siteContactName: '',
      projectStatus: '',
      reraNumber: '',
      reraCertificateDate: DateTime.now(),
      projectScheme: '',
      projectSubScheme: '',
      googleLocation: '',
      companyData: [],
      projectWithBankDetailsData: [],
      tenderAmountPaymentMode: '',
      tenderAmountChequeNumber: '',
      tenderAmountChequeNumberUrl: '',
      tenderAmountPayorderRemark: '',
      tenderEmdPaymentMode: '',
      tenderEmdChequeNumber: '',
      tenderEmdChequeNumberUrl: '',
      tenderEmdPayorderRemark: '',
      siteContactDesignation: '',
      siteContact2MobileNumber: '',
      siteContact2Name: '',
      siteContact2Designation: '',
      siteContact3MobileNumber: '',
      siteContact3Name: '',
      siteContact3Designation: '',
      isFederation: false,
      federationAmount: 0,
    );
  }
}

List<Map<String, dynamic>> get projectList {
  final projectsJson = LocalStorageManager().getString(StorageKey.projectList);

  if (projectsJson == null || projectsJson.isEmpty) {
    return [];
  }

  final List<dynamic> decodedList = jsonDecode(projectsJson);

  return decodedList.map<Map<String, dynamic>>((e) {
    final project = ProjectModel.fromJson(e);

    return {
      "zAttributesId": project.projectId,
      "DisplayName": project.projectName,
    };
  }).toList();
}

UserModel getCurrentUser() {
  var userJson = jsonDecode(
    LocalStorageManager().getString(StorageKey.currentUser) ?? "",
  );
  return UserModel.fromJson(userJson);
}

Future<void> loadAndSelectProjectById(int projectId) async {
  // GET PROJECT LIST FROM LOCAL STORAGE
  final projectsJson = LocalStorageManager().getString(StorageKey.projectList);

  if (projectsJson == null || projectsJson.isEmpty) {
    return;
  }

  // DECODE JSON TO LIST OF PROJECTS
  final List<dynamic> decodedList = jsonDecode(projectsJson);

  final List<ProjectModel> projects =
      decodedList.map((e) => ProjectModel.fromJson(e)).toList();

  // FIND THE PROJECT WITH THE GIVEN ID
  final ProjectModel? selectedProject = projects
      .cast<ProjectModel?>()
      .firstWhere(
        (project) => project?.projectId == projectId,
        orElse: () => null,
      );

  // IF FOUND, SAVE TO LOCAL STORAGE AS SELECTED PROJECT
  if (selectedProject != null) {
    LocalStorageManager().setString(
      StorageKey.selectedProject,
      jsonEncode(selectedProject.toJson()),
    );
  }
}

// <---- UPDATE ROUTE AUTHORIZATION
Future<void> updateRouteAuthorization(List<ModuleModel> moduleData) async {
  // UPDATE THE MAP IN ISOLATE
  final updatedRouteMap = await compute(
    _processRouteAuthorizationModules,
    moduleData,
  );

  final defaultMap = Authorization.routeAuthorizationMap;

  Authorization.routeAuthorizationMap = {...defaultMap, ...updatedRouteMap};
}

Map<String, AuthorizationModel> _processRouteAuthorizationModules(
  List<ModuleModel> modules,
) {
  final updatedMap = <String, AuthorizationModel>{};

  for (var module in modules) {
    for (var subModule in module.subModuleData) {
      updatedMap[subModule.path] = AuthorizationModel(
        isAccess: true,
        isAction: subModule.isAction,
        isExport: subModule.isExport,
        isView: subModule.isView,
      );
      if (subModule.subSubModuleData.isNotEmpty) {
        for (var subSubModule in subModule.subSubModuleData) {
          updatedMap[subSubModule.path] = AuthorizationModel(
            isAccess:
                subSubModule.isAction ||
                subSubModule.isExport ||
                subSubModule.isView,
            isAction: subSubModule.isAction,
            isExport: subSubModule.isExport,
            isView: subSubModule.isView,
          );
        }
      }
    }
  }

  return updatedMap;
}
