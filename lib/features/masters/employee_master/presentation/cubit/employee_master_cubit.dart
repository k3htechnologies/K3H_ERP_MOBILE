import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/branch.model.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
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

  // <---- FILTER EMPLOYEE ---->
  Future filterEmployee({
    required BuildContext context,
    required String departmentName,
    required String designationName,
  }) async {
    emit(
      state.copyWith(
        filterDepartmentName: departmentName,
        filterDesignationName: designationName,
        employeeMasterList: [],
      ),
    );
    await getEmployeeMasterList(context, state.currentPage, 20);
  }

  // <---- GET EMPLOYEE MASTER LIST ---->
  Future getEmployeeMasterList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "EmployeeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "DepartmentName": state.filterDepartmentName,
      "DesignationName": state.filterDesignationName,
    };
    var result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        List<UserModel> updatedList =
            pageNumber == 1
                  ? List<UserModel>.from(response['data'] as List<UserModel>)
                  : List<UserModel>.from(state.employeeMasterList)
              ..addAll(response['data'] as List<UserModel>);
        emit(
          state.copyWith(
            isLoading: false,
            employeeMasterList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
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
    var addResult = await employeeMasterRepository.addUpdateEmployeeMaster(
      requestBody: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) async {
        emit(state.copyWith(errorMessage: failure.message));
        await showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        var list = [
          response['data'][0] as UserModel,
          ...state.employeeMasterList,
        ];
        emit(
          state.copyWith(
            employeeMasterList: list,
            totalNumberOfRecord:
                state.totalNumberOfRecord == -1
                    ? 1
                    : state.totalNumberOfRecord + 1,
          ),
        );
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
    var updateResult = await employeeMasterRepository.addUpdateEmployeeMaster(
      requestBody: requestBody,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
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

  // <---- SEARCH EMPLOYEE ---->
  Future searchEmployee(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, employeeMasterList: []));
    await getEmployeeMasterList(context, 1, 10);
  }

  // <---- SORT EMPLOYEE ---->
  Future sortEmployee(
    BuildContext context,
    String value,
    String direction,
  ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        employeeMasterList: [],
      ),
    );
    await getEmployeeMasterList(context, 1, 10);
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

  Future<void> fetchEmployeeProjects(int employeeId) async {
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

  void onTabChanged(int index, int employeeId) {
    if (index == 3 && state.projectList.isEmpty) {
      fetchEmployeeProjects(employeeId);
    }
  }
}
