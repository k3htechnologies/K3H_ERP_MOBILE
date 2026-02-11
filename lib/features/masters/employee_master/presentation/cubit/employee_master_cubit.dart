import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
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
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_document.model.dart';
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

  // <---- SEARCH EMPLOYEE ---->
  Future searchEmployee(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, employeeMasterList: []));
    await getEmployeeMasterList(context, 1);
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

        emit(
          state.copyWith(
            isLoading: false,
            employeeDocumentList: newList,
          ),
        );
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
      queryParams: {"EmployeeId": employeeId},
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

        emit(
          state.copyWith(
            isLoading: false,
            assetMappingList: newList,
          ),
        );
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
          queryParams: {"EmployeeId": employeeId},
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

        emit(
          state.copyWith(
            isLoading: false,
            shiftManagementList: newList,
          ),
        );
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
      queryParams: {"EmployeeId": employeeId},
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

        emit(
          state.copyWith(
            isLoading: false,
            weekOffMappingList: newList,
          ),
        );
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

  // <---- BANK DROPDOWN ---->
  Future<Map<String, dynamic>> getBankList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 10,
      query: {'BankName': value ?? ''},
    );
    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<dynamic>)
                .map(
                  (e) => {
                    "zAttributesId": e["BankListMasterId"],
                    "DisplayName": e["BankNameWithCode"],
                  },
                )
                .toList(),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- COMPANY DROPDOWN ---->
  Future<Map<String, dynamic>> getCompanies(
    int pageNumber, {
    String? value,
  }) async {
    var result = await companyMasterRepository.getCompanyList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'CompanyName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {"itemList": [], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<CompanyModel>).map(
              (e) => {
                "zAttributesId": e.companyId,
                "DisplayName": e.companyName,
              },
            ),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- DEPARTMENT DROPDOWN ---->
  Future<Map<String, dynamic>> getDepartments(
    int pageNumber, {
    String? value,
  }) async {
    var result = await departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'DepartmentName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {"itemList": [], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<DepartmentModel>).map(
              (e) => {
                "zAttributesId": e.departmentMasterId,
                "DisplayName": e.departmentName,
              },
            ),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- DESIGNATION DROPDOWN ---->
  Future<Map<String, dynamic>> getDesignations(
    int pageNumber, {
    String? value,
  }) async {
    var result = await designationRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'DesignationName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {"itemList": [], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<DesignationMasterModel>).map(
              (e) => {
                "zAttributesId": e.designationMasterId,
                "DisplayName": e.designationName,
              },
            ),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- DESIGNATION DROPDOWN ---->
  Future<Map<String, dynamic>> getEmployee(
    int pageNumber, {
    String? value,
  }) async {
    var result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'EmployeeName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {"itemList": [], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<UserModel>).map(
              (e) => {"zAttributesId": e.employeeId, "DisplayName": e.fullName},
            ),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- BRANCH MASTER DROPDOWN ---->
  Future<Map<String, dynamic>> getBranch(
    int pageNumber, {
    String? value,
  }) async {
    var result = await employeeMasterRepository.getBranchList(
      pageNumber: pageNumber,
      pageSize: 10,
      query: {"BranchName": value ?? ''},
    );

    return result.fold(
      (failure) {
        return {"itemList": [], "totalNumberOfRecord": 0};
      },
      (response) async {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            await compute(
              (_) => (response['data'] as List<BranchModel>).map(
                (e) => {
                  "zAttributesId": e.branchMasterId,
                  "DisplayName": e.branchName,
                },
              ),
              '',
            ),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
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
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "employee_${DateTime.now()}.pdf"
              : "employee_${DateTime.now()}.xlsx",
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

  void onTabChanged(BuildContext context, int index, int employeeId) {
    if (index == 1) {
      getEmployeeDocumentList(context, 1, 100, employeeId);
    }
    if (index == 2) {
      getEmployeeAssetList(context, 1, 100, employeeId);
    }
    if (index == 3) {
      getEmployeeProjects(employeeId);
    }
    if (index == 4) {
      getShiftManagementList(context, 1, 100, employeeId);
    }
    if (index == 5) {
      getWeekOffMappingList(context, 1, 100, employeeId);
    } else {
      return;
    }
  }
}
