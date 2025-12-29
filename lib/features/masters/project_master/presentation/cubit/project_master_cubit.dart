import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

part 'project_master_state.dart';

class ProjectMasterCubit extends Cubit<ProjectMasterState> {
  ProjectMasterCubit() : super(ProjectMasterState.initial());

  // PROJECT MASTER REPO
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // COMPANY MASTER REPO
  final CompanyMasterRepository companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();

  // EMPLOYEE MASTER REPO
  final EmployeeMasterRepository employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // EMPLOYEE MASTER REPO
  // final ApprovalRepository approvalRepository =
  // serviceLocator<ApprovalRepository>();

  // <--- RESET PROJECT DETAILS STATE VARIABLE AS SAME CUBIT ISUSED THERE ---->
  void resetProjectDetailsStateVariable() {
    emit(
      state.copyWith(
        employeeByProject: [],
        bankByProject: [],
        companyByProject: [],
      ),
    );
  }

  // <--- RESET PROJECT DETAILS STATE VARIABLE FOR MOBILE ---->
  void resetProjectDetailsStateVariableEmployeeAndCompany() {
    emit(state.copyWith(employeeByProject: [], companyByProject: []));
  }

  // <---- PULL PROJECTS ---->
  Future getProjectList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        projectList: pageNumber == 1 ? [] : state.projectList,
        currentPage: pageNumber == 1 ? 1 : state.currentPage,
      ),
    );
    var result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: state.pageSize,
      queryParams:
          state.searchText != "" ? {"ProjectName": state.searchText} : null,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final fetched = response['data'] as List<ProjectModel>;

        Map<String, ProjectModel> map = {};
        if (pageNumber > 1) {
          for (final c in state.projectList) {
            map[c.uniquekey] = c;
          }
        }
        for (final c in fetched) {
          map[c.uniquekey] = c;
        }
        final updatedList = map.values.toList();
        emit(
          state.copyWith(
            isLoading: false,
            projectList: updatedList,
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

  // <---- ADD PROJECTS ---->
  Future addProject({
    required BuildContext context,
    required String projectName,
    required String location,
    required String ctsNumber,
    required String businessCategory,
    required bool isRedevelopment,
    required String districtMasterId,
    required String stateMasterId,
    required String cityMasterId,
    required String pinCode,
    required String projectScope,
    required String projectEstimateCost,
    required String projectAreaInSqft,
    required String onGoingBudgetCost,
    required String surveyDate,
    required String expectedStartDate,
    required String executionStartDate,
    required String siteContactMobileNumber,
    required String siteContactName,
    required String projectStatus,
    required String reraNumber,
    required String reraCertificateDate,
    required String reraComplitionDate,
    required String projectScheme,
    required String projectSubScheme,
    required String googleLocation,
    required MultiFilePickerModel projectPhotoMap,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "ProjectName": projectName,
      "ProjectLocation": location,
      "CTSNumber": ctsNumber,
      "BussinessCategory": businessCategory,
      "IsRedevelopment": isRedevelopment ? '1' : '0',
      "CountryMasterId": "1",
      "DistrictMasterId": districtMasterId,
      "StateMasterId": stateMasterId,
      "CityMasterId": cityMasterId,
      "ZipCode": pinCode,
      "ProjectScope": projectScope,
      "ProjectEstimateCost": projectEstimateCost,
      "ProjectAreaInSqft": projectAreaInSqft,
      "OnGoingBudgetCost": onGoingBudgetCost,
      "SurveyDate": surveyDate,
      "ExpectedStartDate": expectedStartDate,
      "ExecutionStartDate": executionStartDate,
      "SiteContactMobileNumber": siteContactMobileNumber,
      "SiteContactName": siteContactName,
      "ProjectStatus": projectStatus,
      "RERANumber": reraNumber,
      "RERACertificateDate": reraCertificateDate,
      "RERAComplitionDate": reraComplitionDate,
      "ProjectScheme": projectScheme,
      "ProjectSubScheme": projectSubScheme,
      "GoogleLocation": googleLocation,
    };
    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "ProjectPhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }

    var addResult = await _projectMasterRepository.addUpateProject(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith());
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        emit(
          state.copyWith(
            projectList: [
              response['data'][0] as ProjectModel,
              ...state.projectList,
            ],
            totalNumberOfRecord: state.totalNumberOfRecord + 1,
          ),
        );

        showSuccessMessage(context, subTitle: 'Project Added Successfully!!!');
      },
    );
  }

  // <---- UPDATE PROJECTS ---->
  Future updateProject({
    required BuildContext context,
    required int projectId,
    required String uniqueKey,
    required String projectName,
    required String location,
    required String ctsNumber,
    required String businessCategory,
    required bool isRedevelopment,
    required String districtMasterId,
    required String stateMasterId,
    required String cityMasterId,
    required String pinCode,
    required String projectScope,
    required String projectEstimateCost,
    required String projectAreaInSqft,
    required String onGoingBudgetCost,
    required String surveyDate,
    required String expectedStartDate,
    required String executionStartDate,
    required String siteContactMobileNumber,
    required String siteContactName,
    required String projectStatus,
    required String reraNumber,
    required String reraCertificateDate,
    required String reraComplitionDate,
    required String projectScheme,
    required String projectSubScheme,
    required String googleLocation,
    required MultiFilePickerModel projectPhotoMap,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "ProjectId": projectId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectName": projectName,
      "ProjectLocation": location,
      "CTSNumber": ctsNumber,
      "BussinessCategory": businessCategory,
      "CountryMasterId": "1",
      "IsRedevelopment": isRedevelopment ? '1' : '0',
      "DistrictMasterId": districtMasterId,
      "StateMasterId": stateMasterId,
      "CityMasterId": cityMasterId,
      "ZipCode": pinCode,
      "ProjectScope": projectScope,
      "ProjectEstimateCost": projectEstimateCost,
      "ProjectAreaInSqft": projectAreaInSqft,
      "OnGoingBudgetCost": onGoingBudgetCost,
      "SurveyDate": surveyDate,
      "ExpectedStartDate": expectedStartDate,
      "ExecutionStartDate": executionStartDate,
      "SiteContactMobileNumber": siteContactMobileNumber,
      "SiteContactName": siteContactName,
      "ProjectStatus": projectStatus,
      "RERANumber": reraNumber,
      "RERACertificateDate": reraCertificateDate,
      "RERAComplitionDate": reraComplitionDate,
      "ProjectScheme": projectScheme,
      "ProjectSubScheme": projectSubScheme,
      "GoogleLocation": googleLocation,
      "RemoveProjectPhotoURL": projectPhotoMap.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < projectPhotoMap.fileBytesList.length; i++) {
      if (projectPhotoMap.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "ProjectPhotoURL",
        "value": projectPhotoMap.fileBytesList[i],
        "fileName": projectPhotoMap.fileNameList[i],
      });
    }
    var addResult = await _projectMasterRepository.addUpateProject(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith());
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) async {
        final updatedList = List<ProjectModel>.from(state.projectList);
        updatedList[index] = (response['data'][0] as ProjectModel);
        goRouter.pop();
        emit(state.copyWith(projectList: updatedList));

        // Update project in local storage
        await _updateProjectInLocalStorage(response['data'][0] as ProjectModel);
        if (context.mounted) {
          showSuccessMessage(context, subTitle: 'Project Updated Successfully!!!');
        }
      },
    );
  }

  // <---- UPDATE PROJECT IN LOCAL STORAGE ---->
  Future<void> _updateProjectInLocalStorage(ProjectModel updatedProject) async {
    try {
      final localStorageManager = LocalStorageManager();
      final projectListString = localStorageManager.getString(
        StorageKey.projectList,
      );

      if (projectListString != null && projectListString.isNotEmpty) {
        // Parse the existing project list from local storage
        final List<dynamic> projectListJson = jsonDecode(projectListString);
        final List<ProjectModel> projectList =
            projectListJson
                .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // Find and update the project with the same projectId
        final projectIndex = projectList.indexWhere(
          (project) => project.projectId == updatedProject.projectId,
        );

        if (projectIndex != -1) {
          // Update the project at the found index
          projectList[projectIndex] = updatedProject;

          // Save the updated project list back to local storage
          await localStorageManager.setString(
            StorageKey.projectList,
            jsonEncode(projectList.map((e) => e.toJson()).toList()),
          );
        }

        // Also update the selected project if it's the same project
        final selectedProjectString = localStorageManager.getString(
          StorageKey.selectedProject,
        );
        if (selectedProjectString != null && selectedProjectString.isNotEmpty) {
          final selectedProject = ProjectModel.fromJson(
            jsonDecode(selectedProjectString),
          );
          if (selectedProject.projectId == updatedProject.projectId) {
            await localStorageManager.setString(
              StorageKey.selectedProject,
              jsonEncode(updatedProject.toJson()),
            );
          }
        }
      }
    } catch (e) {
      // Handle any errors silently to avoid disrupting the main flow
      log('Error updating project in local storage: $e');
    }
  }

  // <---- ADD COMPANY RESPECTED TO PROJECTS ---->
  Future<void> getProjectWithCompany({
    required BuildContext context,
    required String projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithCompany(
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final allCompanies = (response['data'] as List)
            .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Store all companies and implement client-side pagination
        emit(
          state.copyWith(
            isLoading: false,
            companyByProject: allCompanies,
            totalNumberOfRecordCompany: response['totalNumberOfRecord'],
            currentPageCompany: 1,
          ),
        );
      },
    );
  }

  // <---- GET PAGINATED COMPANY LIST (CLIENT-SIDE) ---->
  List<CompanyModel> getPaginatedCompanyList() {
    const int pageSize = 10;
    final int startIndex = (state.currentPageCompany - 1) * pageSize;
    final int endIndex = startIndex + pageSize;
    
    if (startIndex >= state.companyByProject.length) {
      return [];
    }
    
    return state.companyByProject.sublist(
      startIndex,
      endIndex > state.companyByProject.length
          ? state.companyByProject.length
          : endIndex,
    );
  }

  // <---- LOAD MORE COMPANIES (CLIENT-SIDE PAGINATION) ---->
  void loadMoreCompanies() {
    const int pageSize = 10;
    final int totalPages = (state.companyByProject.length / pageSize).ceil();
    
    if (state.currentPageCompany < totalPages) {
      emit(
        state.copyWith(
          currentPageCompany: state.currentPageCompany + 1,
        ),
      );
    }
  }

  // <---- ADD BANK RESPECTED TO PROJECTS ---->
  Future<void> getProjectWithBankDetails({
    required BuildContext context,
    required String projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        try {
          final data = response['data'];
          final allBanks = data != null && data is List
              ? data
                  .map(
                    (e) {
                      try {
                        return BankDetailsModel.fromJson(e as Map<String, dynamic>);
                      } catch (e) {
                        log('Error parsing bank details: $e');
                        return null;
                      }
                    },
                  )
                  .whereType<BankDetailsModel>()
                  .toList()
              : <BankDetailsModel>[];
          
          // Store all banks and implement client-side pagination
          emit(
            state.copyWith(
              isLoading: false,
              bankByProject: allBanks,
              currentPageBank: 1,
            ),
          );
        } catch (e) {
          log('Error processing bank details response: $e');
          emit(
            state.copyWith(
              isLoading: false,
              bankByProject: <BankDetailsModel>[],
              currentPageBank: 1,
            ),
          );
        }
      },
    );
  }

  // <---- GET PAGINATED BANK LIST (CLIENT-SIDE) ---->
  List<BankDetailsModel> getPaginatedBankList() {
    const int pageSize = 10;
    final int startIndex = (state.currentPageBank - 1) * pageSize;
    final int endIndex = startIndex + pageSize;
    
    if (startIndex >= state.bankByProject.length) {
      return [];
    }
    
    return state.bankByProject.sublist(
      startIndex,
      endIndex > state.bankByProject.length
          ? state.bankByProject.length
          : endIndex,
    );
  }

  // <---- LOAD MORE BANKS (CLIENT-SIDE PAGINATION) ---->
  void loadMoreBanks() {
    const int pageSize = 10;
    final int totalPages = (state.bankByProject.length / pageSize).ceil();
    
    if (state.currentPageBank < totalPages) {
      emit(
        state.copyWith(
          currentPageBank: state.currentPageBank + 1,
        ),
      );
    }
  }

  // <---- ADD EMPLOYEE RESPECT TO PROJECTS ---->
  Future<void> getProjectWithEmployee({
    required BuildContext context,
    required String projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithEmployee(
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final allEmployees = (response['data'] as List)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Store all employees and implement client-side pagination
        emit(
          state.copyWith(
            isLoading: false,
            employeeByProject: allEmployees,
            totalNumberOfRecordEmployee: response['totalNumberOfRecord'],
            currentPageEmployee: 1,
          ),
        );
      },
    );
  }

  // <---- GET PAGINATED EMPLOYEE LIST (CLIENT-SIDE) ---->
  List<UserModel> getPaginatedEmployeeList() {
    const int pageSize = 10;
    final int startIndex = (state.currentPageEmployee - 1) * pageSize;
    final int endIndex = startIndex + pageSize;
    
    if (startIndex >= state.employeeByProject.length) {
      return [];
    }
    
    return state.employeeByProject.sublist(
      startIndex,
      endIndex > state.employeeByProject.length
          ? state.employeeByProject.length
          : endIndex,
    );
  }

  // <---- LOAD MORE EMPLOYEES (CLIENT-SIDE PAGINATION) ---->
  void loadMoreEmployees() {
    const int pageSize = 10;
    final int totalPages = (state.employeeByProject.length / pageSize).ceil();
    
    if (state.currentPageEmployee < totalPages) {
      emit(
        state.copyWith(
          currentPageEmployee: state.currentPageEmployee + 1,
        ),
      );
    }
  }

  // <---- ADD UPDATE BANK DETAILS RESPECT TO PROJECT ---->
  Future<void> addUpdateProjectWithBankDetails({
    required Map<String, dynamic> bankRequestBody,
    required String projectId,
    required BuildContext context,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectMasterRepository.addUpdateProjectWithBankDetails(
      bankRequestBody: bankRequestBody,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        getProjectWithBankDetails(projectId: projectId, context: context);
        showSuccessMessage(context,subTitle: 'Bank Details Updated Successfully!!!');
      },
    );
  }

  // <---- DELETE BANK RESPECT TO PROJECT ---->
  Future<void> deleteProjectWithBankDetails({
    required BuildContext context,
    required int projectWithBankDetailsId,
    required String uniqueKey,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectMasterRepository.deleteProjectWithBankDetails(
      projectId: projectId,
      uniqueKey: uniqueKey,
      projectWithBankDetailsId: projectWithBankDetailsId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        getProjectWithBankDetails(
          projectId: projectId.toString(),
          context: context,
        );
        showSuccessMessage(context,subTitle: 'Bank Details Deleted Successfully!!!');
      },
    );
  }

  // <---- FETCH COMPANY MASTER LIST ---->
  Future<List<CompanyModel>> getCompanies({
    required int pageNumber,
    required int pageSize,
    required BuildContext context,
    Map<String, dynamic>? queryParams,
    bool isAllSelected = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await companyMasterRepository.getCompanyList(
      pageNumber: pageNumber,
      pageSize: isAllSelected ? state.totalNumberOfRecordCompany : pageSize,
      queryParams: queryParams,
    );

    List<CompanyModel> companyList = [];

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final rawList = response['data'] as List<CompanyModel>;
        final totalRecords = response['totalNumberOfRecord'] as int;
        emit(
          state.copyWith(
            isLoading: false,
            totalNumberOfRecordCompany: totalRecords,
            currentPageCompany: pageNumber,
          ),
        );
        companyList = List.from(rawList);
      },
    );
    return companyList;
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

  // <---- FETCH EMPLOYEE MASTER LIST ---->
  Future<List<UserModel>> getEmployeeMasterList({
    required int pageNumber,
    required int pageSize,
    required BuildContext context,
    Map<String, dynamic>? queryParams,
    bool isAllSelected = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: isAllSelected ? state.totalNumberOfRecordEmployee : pageSize,
      queryParams: queryParams,
    );

    List<UserModel> employeeList = [];

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final rawList = response['data'] as List<UserModel>;
        final totalRecords = response['totalNumberOfRecord'] as int;
        emit(
          state.copyWith(
            isLoading: false,
            totalNumberOfRecordEmployee: totalRecords,
            currentPageEmployee: pageNumber,
          ),
        );
        employeeList = List.from(rawList);
      },
    );
    return employeeList;
  }

  // <----- ADD UPDATE COMPANY RESPECT WITH PROJECT ----->
  Future<void> addUpdateProjectWithCompany({
    required String projectId,
    required String uniqueKey,
    required List selectedCompanyIds,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    emit(state.copyWith());
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "Uniquekey": uniqueKey,
      "CompanyId": selectedCompanyIds.join(","),
    };
    var result = await _projectMasterRepository.addUpdateProjectWithCompany(
      requestBody: requestBody,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));
        getProjectWithCompany(projectId: projectId, context: context);
        await showSuccessMessage(context, subTitle: 'Company Updated Successfully!!!');
        onSuccess();
      },
    );
  }

  // <----- ADD UPDATE EMPLOYEE RESPECT WITH PROJECT ----->
  Future<void> addUpdateProjectWithEmployee({
    required String projectId,
    required String uniqueKey,
    required List<int> selectedEmployeeIds,
    required BuildContext context,
    VoidCallback? onSuccess,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "Uniquekey": uniqueKey,
      "EmployeeId": selectedEmployeeIds.join(","),
    };

    var result = await _projectMasterRepository.addUpdateProjectWithEmployee(
      requestBody: requestBody,
    );
    emit(state.copyWith(isLoading: false));
    result.fold(
      (failure) {
         showErrorMessage(context, "Error Message", failure.message);
      },
      (response) async {
        await showSuccessMessage(context, subTitle: 'Employee Updated Successfully!!!');
        if (context.mounted) {
          getProjectWithEmployee(
            projectId: projectId,
            context: context,
          );
        }
        if (onSuccess != null) onSuccess();
      },
    );
  }

  // <---- GET APPROVAL MODULES LIST ---->
  /*Future<List<ModulesWorkflowApprovalModel>> getModulesApproval({
    required BuildContext context,
    required int employeeId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingDialog(context);
    var result = await approvalRepository.getModulesWorkflowApproval(
      employeeId: employeeId,
      projectId: projectId,
    );
    goRouter.pop();
    return result.fold(
          (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        return [];
      },
          (response) {
        return (response['data'] as List<ModulesWorkflowApprovalModel>);
      },
    );
  }*/

  // <---- DELETE BANK RESPECT TO PROJECT ---->
  Future<void> deleteProjectWithEmployee({
    required BuildContext context,
    required int projectId,
    required String uniquekey,
    required String employeeId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectMasterRepository.deleteProjectWithEmployee(
      projectId: projectId,
      uniquekey: uniquekey,
      employeeId: employeeId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        getProjectWithEmployee(
          context: context,
          projectId: projectId.toString(),
        );
        showSuccessMessage(context,subTitle: 'Employee Deleted Successfully!!!');
      },
    );
  }

  // <----- ADD UPDATE MATERIAL REQUISITION MODULE APPROVAL ----->
  /*Future<void> addUpdateMaterialRequisitionModulesApproval({
    required BuildContext context,
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    Map<String, dynamic> requestBody = {
      "EmployeeId": employeeId,
      "ProjectId": projectId,
      "ModulesMasterId": modulesMasterId,
      "SubModulesMasterId": subModulesMasterId,
      "SubSubModulesMasterId": subSubModulesMasterId,
    };

    DialogHelper.showProcessingDialog(context);
    var result = await approvalRepository.addUpdateModulesWorkflowApproval(
      requestBody: requestBody,
    );
    goRouter.pop();
    result.fold(
          (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
          (response) async {
        goRouter.pop();

        await getModuleWorkFlowApprovalList(
          context: context,
          employeeId: 0,
          projectId: projectId,
        );
        showSuccessMessage(
          goRouter.routerDelegate.navigatorKey.currentContext!,
        );
      },
    );
  }

  // <---- DELETE MODULES WORK FLOW APPROVAL ---->
  Future<void> deleteModulesWorkflowApproval({
    required BuildContext context,
    required int projectId,
    required int employeeId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    DialogHelper.showProcessingDialog(context);
    var result = await approvalRepository.deleteModulesWorkflowApproval(
      employeeId: employeeId,
      projectId: projectId,
      modulesMasterId: modulesMasterId,
      subModulesMasterId: subModulesMasterId,
      subSubModulesMasterId: subSubModulesMasterId,
    );
    goRouter.pop();
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
          (response) async {
        emit(state.copyWith(isLoading: false));
        await getModuleWorkFlowApprovalList(
          context: context,
          employeeId: 0,
          projectId: projectId,
        );
        showSuccessMessage(
          goRouter.routerDelegate.navigatorKey.currentContext!,
        );
      },
    );
  }*/

  // <---- SEARCH PROJECT ---->
  Future searchProject(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, projectList: []));
    await getProjectList(context: context, pageNumber: 1);
  }

  // <---- EXPORT EXCEL OR PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _projectMasterRepository.exportProject(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"ProjectName": state.searchText, "ExportType": exportType}
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
              ? "project_${DateTime.now()}.pdf"
              : "project_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void onTabChanged(BuildContext context, int index, {String? projectId}) {
    if (index == 1 && projectId != null) {
      // Employee tab selected - reset and fetch all employees
      emit(state.copyWith(
        employeeByProject: [],
        currentPageEmployee: 1,
        totalNumberOfRecordEmployee: 0,
      ));
      getProjectWithEmployee(
        context: context,
        projectId: projectId,
      );
    }
    if (index == 2 && projectId != null) {
      // Bank Details tab selected - reset and fetch all banks
      emit(state.copyWith(
        bankByProject: [],
        currentPageBank: 1,
      ));
      getProjectWithBankDetails(
        context: context,
        projectId: projectId,
      );
    }
    if (index == 3 && projectId != null) {
      // Company tab selected - reset and fetch all companies
      emit(state.copyWith(
        companyByProject: [],
        currentPageCompany: 1,
        totalNumberOfRecordCompany: 0,
      ));
      getProjectWithCompany(
        context: context,
        projectId: projectId,
      );
    }
  }

  /*// <---- PULL MODULE WORK FLOW LIST ---->
  Future<void> getModuleWorkFlowApprovalList({
    required BuildContext context,
    required int projectId,
    required int employeeId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await approvalRepository.getModulesWorkflowApproval(
      employeeId: employeeId,
      projectId: projectId,
    );
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
          (response) {
        emit(
          state.copyWith(
            isLoading: false,
            moduleWorkflowApprovalList:
            response["data"] as List<ModulesWorkflowApprovalModel>,
          ),
        );
      },
    );
  }*/
}
