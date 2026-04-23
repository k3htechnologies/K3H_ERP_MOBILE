import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
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
        category: '',
        tenderAmount: 0,
        tenderEmdAmount: 0,
        tenderPurchaseStartDate: DateTime.now(),
        projectShortName: '',
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
        reraComplitionDate: DateTime.now(),
        projectScheme: '',
        projectSubScheme: '',
        googleLocation: '',
        companyData: [],
        projectWithBankDetailsData: [],
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
      category: '',
      tenderAmount: 0,
      tenderEmdAmount: 0,
      tenderPurchaseStartDate: DateTime.now(),
      projectShortName: '',
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
      reraComplitionDate: DateTime.now(),
      projectScheme: '',
      projectSubScheme: '',
      googleLocation: '',
      companyData: [],
      projectWithBankDetailsData: [],
    );
  }
}

extension NumberFormatting on num {
  String displayFormatedAmount() {
    return NumberFormat('#,##0.00').format(this);
  }

}
