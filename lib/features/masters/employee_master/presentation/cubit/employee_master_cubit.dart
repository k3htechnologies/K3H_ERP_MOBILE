import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/branch.model.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_experience_details.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_document.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/repository/branch_association_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'employee_master_state.dart';

class EmployeeMasterCubit extends Cubit<EmployeeMasterState> {
  EmployeeMasterCubit() : super(EmployeeMasterState.initial());

  EmployeeMasterRepository employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  CompanyMasterRepository companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();
  DepartmentMasterRepository departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();
  DesignationMasterRepository designationRepository =
      serviceLocator<DesignationMasterRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final BranchAssociationMasterRepository _branchAssociationMasterRepository =
      serviceLocator<BranchAssociationMasterRepository>();

  // <---- SEARCH EMPLOYEE ---->
  Future searchEmployee(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, employeeMasterList: []));
    await getEmployeeMasterList(context, 1);
  }

  void onTabChanged(BuildContext context, int index, int employeeId) {
    if (index == 1) {
      getEmployeeEducationDetailsList(context, 1, 100, employeeId);
    }
    if (index == 2) {
      getEmployeeExperienceDetailsList(context, 1, 100, employeeId);
    }
    if (index == 3) {
      getBranchAssociationList(context, 1, 100, employeeId);
    }
    if (index == 4) {
      getEmployeeDocumentList(context, 1, 100, employeeId);
    }
    if (index == 5) {
      getEmployeeAssetList(context, 1, 100, employeeId);
    }
    if (index == 6) {
      getEmployeeProjects(employeeId);
    }
    if (index == 7) {
      getShiftManagementList(context, 1, 100, employeeId);
    }
    if (index == 8) {
      getWeekOffMappingList(context, 1, 100, employeeId);
    } else {
      return;
    }
  }

  Future applyFilterAndSort({
    required BuildContext context,
    required String employeeCode,
    required String companyName,
    required String reportingPersonName,
    required String departmentName,
    required String designationName,
    required String mobileNumber,
    required String branchName,
    DateTime? filterDOBFrom,
    DateTime? filterDOBTo,
    String? filterIsProbation,
    String? filterIdCardIssue,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterEmployeeCode: employeeCode,
        filterCompanyName: companyName,
        filterReportPersonName: reportingPersonName,
        filterDepartmentName: departmentName,
        filterDesignationName: designationName,
        filterMobileNumber: mobileNumber,
        filterBranchName: branchName,
        filterDOBFrom: filterDOBFrom,
        filterDOBTo: filterDOBTo,
        filterIsProbation: filterIsProbation ?? state.filterIsProbation,
        filterIdCardIssue: filterIdCardIssue ?? state.filterIdCardIssue,
        clearFilterDOBFrom: filterDOBFrom == null,
        clearFilterDOBTo: filterDOBTo == null,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        employeeMasterList: [],
        currentPage: 1,
      ),
    );

    await getEmployeeMasterList(context, 1);
  }

  // <---- CLEAR DEPARTMENT LIST ---->
  void clearDepartmentList() {
    emit(state.copyWith(departmentList: [], departmentTotalCount: 0));
  }

  // <---- CLEAR DEPARTMENT LIST ---->
  void clearCompanyNameList() {
    emit(state.copyWith(departmentList: [], departmentTotalCount: 0));
  }

  // <---- CLEAR DESIGNATION LIST ---->
  void clearDesignationList() {
    emit(state.copyWith(departmentList: [], departmentTotalCount: 0));
  }

  // <---- CLEAR BRANCH LIST ---->
  void clearBranchList() {
    emit(state.copyWith(departmentList: [], departmentTotalCount: 0));
  }

  // <---- GET EMPLOYEE MASTER LIST ---->
  Future getEmployeeMasterList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final queryParams = <String, dynamic>{
      "EmployeeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ReportPersonName": state.filterReportPersonName,
      "CompanyName": state.filterCompanyName,
      "EmployeeCode": state.filterEmployeeCode,
      "DepartmentName": state.filterDepartmentName,
      "DesignationName": state.filterDesignationName,
      "MobileNumber": state.filterMobileNumber,
      "BranchName": state.filterBranchName,
    };
    if (state.filterDOBFrom != null) {
      queryParams["FromDateOfBirth"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterDOBFrom!);
    }
    if (state.filterDOBTo != null) {
      queryParams["ToDateOfBirth"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterDOBTo!);
    }
    if (state.filterIsProbation.isNotEmpty) {
      queryParams["IsEmployeeOnProbation"] = state.filterIsProbation;
    }
    if (state.filterIdCardIssue.isNotEmpty) {
      queryParams["IsIdCardIssued"] = state.filterIdCardIssue;
    }
    final result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<UserModel> newData = List<UserModel>.from(
          response['data'] ?? [],
        );

        final List<UserModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.employeeMasterList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            employeeMasterList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // <---- GET EMPLOYEE DOCUMENT LIST ---->
  Future getEmployeeDocumentList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getEmployeeDocumentList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {"EmployeeId": employeeId},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<EmployeeDocumentModel> newList =
            pageNumber == 1
                ? List<EmployeeDocumentModel>.from(response['data'])
                : [...state.employeeDocumentList, ...response['data']];

        emit(state.copyWith(isLoading: false, employeeDocumentList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE ASSET LIST ---->
  Future getEmployeeAssetList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getEmployeeAssetList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {"EmployeeId": employeeId, "IsCheckPermission": false},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<AssetMappingModel> newList =
            pageNumber == 1
                ? List<AssetMappingModel>.from(response['data'])
                : [...state.assetMappingList, ...response['data']];

        emit(state.copyWith(isLoading: false, assetMappingList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE SHIFT MANAGEMENT LIST ---->
  Future getShiftManagementList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository
        .getEmployeeShiftManagementList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {
            "EmployeeId": employeeId,
            "IsCheckPermission": false,
            "IsCheckEmployeeShift": true,
          },
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<ShiftMappingModel> newList =
            pageNumber == 1
                ? List<ShiftMappingModel>.from(response['data'])
                : [...state.shiftManagementList, ...response['data']];

        emit(state.copyWith(isLoading: false, shiftManagementList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE WEEK OFF MAPPING LIST ---->
  Future getWeekOffMappingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getEmployeeWeekOffMappingList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {
        "EmployeeId": employeeId,
        "IsCheckPermission": false,
        "IsCheckEmployeeWeekOffPolicy": true,
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<WeekOffMappingModel> newList =
            pageNumber == 1
                ? List<WeekOffMappingModel>.from(response['data'])
                : [...state.weekOffMappingList, ...response['data']];

        emit(state.copyWith(isLoading: false, weekOffMappingList: newList));
      },
    );
  }

  // <---- ADD EMPLOYEE MASTER ---->
  Future addEmployeeMaster({
    required BuildContext context,
    required String firstName,
    required String middleName,
    required String lastName,
    required String selectedGender,
    required String selectedMaritalStatus,
    required String selectedBloodGroup,
    required int selectedReportingPersonId,
    required int selectedBranchId,
    required DateTime dateOfBirth,
    required DateTime joiningDate,
    DateTime? idCardIssueDate,
    required int selectedCompanyNameId,
    required int selectedDepartmentId,
    required int selectedDesignationId,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required int selectedVillageId,
    required String officeEmailId,
    required String personalEmailId,
    required String personalMobileNumber,
    required String officeMobileNumber,
    required String communicationAddress,
    required String permanentAddress,
    required int bankNameMasterId,
    required String bankBranchName,
    required String accountNumber,
    required String ifscCode,
    required String emergencyMobileNumber,
    required String emergencyContactPersonRelationship,
    required String employeeType,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      'EmployeeId': 0,
      "FirstName": firstName,
      "MiddleName": middleName,
      "LastName": lastName,
      "DepartmentMasterId": selectedDepartmentId,
      "DesignationMasterId": selectedDesignationId,
      "BranchMasterId": selectedBranchId,
      "Gender": selectedGender,
      "MaritalStatus": selectedMaritalStatus,
      "DateOfBirth": dateOfBirth.toIso8601String(),
      "JoiningDate": joiningDate.toIso8601String(),
      "EmailId": personalEmailId,
      "OfficeEmailId": officeEmailId,
      "ReportPersonId": selectedReportingPersonId,
      "PersonalMobileNumber": personalMobileNumber,
      "OfficeMobileNumber": officeMobileNumber,
      "BankListMasterId": bankNameMasterId,
      "BankBranchName": bankBranchName,
      "IFSCCode": ifscCode,
      "AccountNo": accountNumber,
      "CommunicationAddress": communicationAddress,
      "PermanentAddress": permanentAddress,
      "BloodGroup": selectedBloodGroup,
      "CompanyId": selectedCompanyNameId,
      "CountryMasterId": selectedCountryNameId,
      "StateMasterId": selectedStateId,
      "DistrictMasterId": selectedDistrictId,
      "CityMasterId": selectedCityId,
      "VillageMasterId": selectedVillageId,
      "IsGeoFenceLocation": true,
      "EmployeeType": employeeType,
      "EmergencyMobileNumber": emergencyMobileNumber,
      "EmergencyContactPersonRelationship": emergencyContactPersonRelationship,
    };
    requestBody["IdCardIssueDate"] = idCardIssueDate?.toIso8601String();
    var addResult = await employeeMasterRepository.addUpdateEmployeeMaster(
      requestBody: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false));
        await showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Employee Added Successfully");
      },
    );
  }

  // <---- UPDATE EMPLOYEE MASTER ---->
  Future updateEmployeeMaster({
    required BuildContext context,
    required int employeeMasterId,
    required String uniqueKey,
    required String firstName,
    required String middleName,
    required String lastName,
    required String selectedGender,
    required String selectedMaritalStatus,
    required String selectedBloodGroup,
    required int selectedReportingPersonId,
    required int selectedBranchId,
    required DateTime dateOfBirth,
    required DateTime joiningDate,
    DateTime? idCardIssueDate,
    required int selectedCompanyNameId,
    required int selectedDepartmentId,
    required int selectedDesignationId,
    required int selectedCountryNameId,
    required int selectedStateId,
    required int selectedDistrictId,
    required int selectedCityId,
    required int selectedVillageId,
    required String officeEmailId,
    required String personalEmailId,
    required String personalMobileNumber,
    required String officeMobileNumber,
    required String communicationAddress,
    required String permanentAddress,
    required int bankNameMasterId,
    required String bankBranchName,
    required String ifscCode,
    required String accountNumber,
    required String emergencyMobileNumber,
    required String emergencyContactPersonRelationship,
    required String employeeType,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      'EmployeeId': employeeMasterId,
      'UniqueKey': uniqueKey,
      "FirstName": firstName,
      "MiddleName": middleName,
      "LastName": lastName,
      "DepartmentMasterId": selectedDepartmentId,
      "DesignationMasterId": selectedDesignationId,
      "BranchMasterId": selectedBranchId,
      "Gender": selectedGender,
      "MaritalStatus": selectedMaritalStatus,
      "DateOfBirth": dateOfBirth.toIso8601String(),
      "JoiningDate": joiningDate.toIso8601String(),
      "EmailId": personalEmailId,
      "OfficeEmailId": officeEmailId,
      "ReportPersonId": selectedReportingPersonId,
      "PersonalMobileNumber": personalMobileNumber,
      "OfficeMobileNumber": officeMobileNumber,
      "BankListMasterId": bankNameMasterId,
      "BankBranchName": bankBranchName,
      "IFSCCode": ifscCode,
      "AccountNo": accountNumber,
      "CommunicationAddress": communicationAddress,
      "PermanentAddress": permanentAddress,
      "BloodGroup": selectedBloodGroup,
      "CompanyId": selectedCompanyNameId,
      "CountryMasterId": selectedCountryNameId,
      "StateMasterId": selectedStateId,
      "DistrictMasterId": selectedDistrictId,
      "CityMasterId": selectedCityId,
      "VillageMasterId": selectedVillageId,
      "IsGeoFenceLocation": true,
      "EmployeeType": employeeType,
      "EmergencyMobileNumber": emergencyMobileNumber,
      "EmergencyContactPersonRelationship": emergencyContactPersonRelationship,
    };
    requestBody["IdCardIssueDate"] = idCardIssueDate?.toIso8601String();
    var updateResult = await employeeMasterRepository.addUpdateEmployeeMaster(
      requestBody: requestBody,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedEmployee = response['data'][0] as UserModel;
        if (state.employeeMasterList.isNotEmpty &&
            index < state.employeeMasterList.length) {
          final updatedList = List<UserModel>.from(state.employeeMasterList);
          updatedList[index] = updatedEmployee;
          emit(state.copyWith(employeeMasterList: updatedList));
        }
        showSuccessMessage(context, subTitle: "Employee Updated Successfully");
      },
    );
  }

  // <---- UPDATE EMPLOYEE DOCUMENT ---->
  Future updateEmployeeDocument({
    required BuildContext context,
    required int employeeDocumentId,
    required String uniqueKey,
    required String employeeId,
    required String documentName,
    required String removeDocumentURL,
    required MultiFilePickerModel files,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      'EmployeeDocumentId': employeeDocumentId.toString(),
      'UniqueKey': uniqueKey,
      "EmployeeId": employeeId,
      "DocumentName": documentName,
      "RemoveDocumentURL": removeDocumentURL,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < files.fileNameList.length; i++) {
      if (files.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": files.fileBytesList[i],
        "fileName": files.fileNameList[i],
      });
    }

    var updateResult = await employeeMasterRepository.addUpdateEmployeeDocument(
      requestBody: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["successMessage"]);
        await getEmployeeDocumentList(context, 1, 100, int.parse(employeeId));
      },
    );
  }

  Future<void> getBankList(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    var queryParams = {
      "BankName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      query: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<BankListMasterModel>.from(response['data']);

        final List<BankListMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.bankList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            bankList: updatedList,
            bankTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- COMPANY DROPDOWN ---->
  Future<void> getCompanies(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "CompanyName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    final result = await companyMasterRepository.getCompanyList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<CompanyModel>.from(response['data']);

        final List<CompanyModel> updatedList =
            pageNumber == 1 ? newData : [...state.companyNameList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            companyNameList: updatedList,
            companyNameTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- DEPARTMENT DROPDOWN ---->
  Future<void> getDepartmentList(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    var queryParams = {
      "DepartmentName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    emit(state.copyWith(isLoading: true));

    final result = await departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<DepartmentModel>.from(response['data']);

        final List<DepartmentModel> updatedList =
            pageNumber == 1 ? newData : [...state.departmentList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            departmentList: updatedList,
            departmentTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- DESIGNATION DROPDOWN ---->
  Future<void> getDesignationList(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "DesignationName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    final result = await designationRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<DesignationMasterModel>.from(response['data']);

        final List<DesignationMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.designationList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            designationList: updatedList,
            designationTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- REPORTING PERSON DROPDOWN ---->
  Future<void> getEmployee(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    var queryParams = {
      "EmployeeName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<UserModel>.from(response['data']);

        final List<UserModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.reportingPersonList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            reportingPersonList: updatedList,
            reportingPersonTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- BRANCH MASTER DROPDOWN ---->
  Future<void> getBranch(
    BuildContext context,
    int pageNumber,
    int pageSize, {
    String? searchQuery,
  }) async {
    var queryParams = {
      "BranchName": searchQuery ?? "",
      "IsCheckPermission": false,
    };

    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getBranchList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      query: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<BranchModel>.from(response['data']);

        final List<BranchModel> updatedList =
            pageNumber == 1 ? newData : [...state.branchList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            branchList: updatedList,
            branchTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await employeeMasterRepository.exportEmployee(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"EmployeeName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Employee Master ${DateTime.now()}.pdf"
              : "Employee Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> getEmployeeProjects(int employeeId) async {
    emit(state.copyWith(isLoadingProjects: true));

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: 1,
      pageSize: 100,
      queryParams: {"EmployeeId": employeeId},
    );

    result.fold(
      (_) {
        emit(state.copyWith(projectList: [], isLoadingProjects: false));
      },
      (response) {
        emit(
          state.copyWith(
            projectList: response['data'] as List<ProjectModel>,
            isLoadingProjects: false,
          ),
        );
      },
    );
  }

  // <---- GET EMPLOYEE EXPERIENCE DETAILS LIST ---->
  Future getEmployeeExperienceDetailsList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository
        .getEmployeeExperienceDetailsList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<EmployeeExperienceDetailsModel> newList =
            pageNumber == 1
                ? List<EmployeeExperienceDetailsModel>.from(dataList)
                : [
                  ...state.employeeExperienceDetailsList,
                  ...List<EmployeeExperienceDetailsModel>.from(dataList),
                ];

        emit(
          state.copyWith(
            isLoading: false,
            employeeExperienceDetailsList: newList,
          ),
        );
      },
    );
  }

  // <---- GET EMPLOYEE EDUCATION DETAILS LIST ---->
  Future getEmployeeEducationDetailsList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository
        .getEmployeeEducationDetailsList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<EmployeeEducationDetailsModel> newList =
            pageNumber == 1
                ? List<EmployeeEducationDetailsModel>.from(dataList)
                : [
                  ...state.employeeEducationDetailsList,
                  ...List<EmployeeEducationDetailsModel>.from(dataList),
                ];

        emit(
          state.copyWith(
            isLoading: false,
            employeeEducationDetailsList: newList,
          ),
        );
      },
    );
  }

  // <---- GET BRANCH ASSOCIATION LIST ---->
  Future getBranchAssociationList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _branchAssociationMasterRepository
        .getBranchAssociationList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<BranchAssociationModel> newList =
            pageNumber == 1
                ? List<BranchAssociationModel>.from(dataList)
                : [
                  ...state.branchAssociationList,
                  ...List<BranchAssociationModel>.from(dataList),
                ];

        emit(state.copyWith(isLoading: false, branchAssociationList: newList));
      },
    );
  }
}
