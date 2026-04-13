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
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
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

  // UTILS REPO
  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();

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

  // <---- SEARCH PROJECT ---->
  Future searchProject(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, projectList: []));
    await getProjectList(context: context, pageNumber: 1);
  }

  // <---- TAB CHANGED ---->
  void onTabChanged(
    BuildContext context,
    int index, {
    int? projectId,
    int? employeeId,
  }) {
    if (index == 1 && projectId != null) {
      emit(
        state.copyWith(
          employeeByProject: [],
          currentPageEmployee: 1,
          totalNumberOfRecordEmployee: 0,
        ),
      );
      getProjectWithEmployee(context: context, projectId: projectId);
    }
    if (index == 2 && projectId != null) {
      // Bank Details tab selected - reset and fetch all banks
      emit(state.copyWith(bankByProject: [], currentPageBank: 1));
      getProjectWithBankDetails(context: context, projectId: projectId);
    }
    if (index == 3 && projectId != null) {
      // Company tab selected - reset and fetch all companies
      emit(
        state.copyWith(
          companyByProject: [],
          currentPageCompany: 1,
          totalNumberOfRecordCompany: 0,
        ),
      );
      getProjectWithCompany(context: context, projectId: projectId);
    }
    if (index == 4 && projectId != null) {
      emit(state.copyWith(moduleWorkflowApprovalList: []));
      getApprovalList(context: context, projectId: projectId);
    }
  }

  // <--- SORT VENDOR ---->
  Future sortProject({
    required BuildContext context,
    String? ctsNumber,
    String? projectLocation,
    String? projectName,
    String? projectStatus,
    String? village,
    String? architectName,
    String? reraNumber,
    String? projectScheme,
    String? projectSubScheme,
    bool isRedevelopment = false,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          filterCTSNumber: "",
          filterProjectLocation: "",
          currentPage: 1,
          filterProjectName: '',
          filterProjectStatus: '',
          filterVillage: '',
          filterArchitectName: '',
          filterRERANumber: '',
          filterProjectScheme: '',
          filterProjectSubScheme: '',
          isRedevelopment: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          filterCTSNumber: ctsNumber ?? state.filterCTSNumber,
          filterProjectLocation: projectLocation ?? state.filterProjectLocation,
          currentPage: 1,
          filterProjectName: projectName ?? state.filterProjectName,
          filterProjectStatus: projectStatus ?? state.filterProjectStatus,
          filterVillage: village ?? state.filterVillage,
          filterArchitectName: architectName ?? state.filterArchitectName,
          filterRERANumber: reraNumber ?? state.filterRERANumber,
          filterProjectScheme: projectScheme ?? state.filterProjectScheme,
          filterProjectSubScheme:
              projectSubScheme ?? state.filterProjectSubScheme,
          isRedevelopment:
              isRedevelopment == true
                  ? 1
                  : isRedevelopment == false
                  ? 0
                  : state.isRedevelopment,
        ),
      );
    }

    await getProjectList(context: context, pageNumber: 1);
  }

  // <---- PULL PROJECTS ---->
  Future getProjectList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: state.pageSize,
      queryParams: {
        "ProjectName": state.searchText,
        "ProjectLocation": state.filterProjectLocation,
        "CTCNumber": state.filterCTSNumber,
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) async {
        final List<ProjectModel> newData = List<ProjectModel>.from(
          response['data'] ?? [],
        );

        final List<ProjectModel> updatedList =
            pageNumber == 1 ? newData : [...state.projectList, ...newData];

        emit(
          state.copyWith(
            projectList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
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
    required String fileNumber,
    required String architectName,
    required String architectMobileNumber,
    required bool isRedevelopment,
    required String districtMasterId,
    required String stateMasterId,
    required String cityMasterId,
    required String villageMasterId,
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
      "FileNumber": fileNumber,
      "ArchitectName": architectName,
      "ArchitectMobileNumber": architectMobileNumber,
      "IsRedevelopment": isRedevelopment ? '1' : '0',
      "CountryMasterId": "1",
      "DistrictMasterId": districtMasterId,
      "StateMasterId": stateMasterId,
      "CityMasterId": cityMasterId,
      "VillageMasterId": villageMasterId,
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
    required String fileNumber,
    required String architectName,
    required String architectMobileNumber,
    required bool isRedevelopment,
    required String districtMasterId,
    required String stateMasterId,
    required String cityMasterId,
    required String villageMasterId,
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
      "FileNumber": fileNumber,
      "ArchitectName": architectName,
      "ArchitectMobileNumber": architectMobileNumber,
      "CountryMasterId": "1",
      "IsRedevelopment": isRedevelopment ? '1' : '0',
      "DistrictMasterId": districtMasterId,
      "StateMasterId": stateMasterId,
      "CityMasterId": cityMasterId,
      "VillageMasterId": villageMasterId,
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
        goRouter.pop();

        await _updateProjectInLocalStorage(response['data'][0] as ProjectModel);
        final updatedDepartment = response['data'][0] as ProjectModel;

        if (state.projectList.isNotEmpty && index < state.projectList.length) {
          final updatedList = List<ProjectModel>.from(state.projectList);
          updatedList[index] = updatedDepartment;
          emit(state.copyWith(projectList: updatedList, isLoading: false));
        }
        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle: 'Project Updated Successfully!!!',
          );
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
      log('Error updating project in local storage: $e');
    }
  }

  // <---- ADD COMPANY RESPECTED TO PROJECTS ---->
  Future<void> getProjectWithCompany({
    required BuildContext context,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithCompany(
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final allCompanies =
            (response['data'] as List)
                .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
                .toList();

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
      emit(state.copyWith(currentPageCompany: state.currentPageCompany + 1));
    }
  }

  // <---- ADD BANK RESPECTED TO PROJECTS ---->
  Future<void> getProjectWithBankDetails({
    required BuildContext context,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        try {
          final data = response['data'];
          final allBanks =
              data != null && data is List
                  ? data
                      .map((e) {
                        try {
                          return BankDetailsModel.fromJson(
                            e as Map<String, dynamic>,
                          );
                        } catch (e) {
                          log('Error parsing bank details: $e');
                          return null;
                        }
                      })
                      .whereType<BankDetailsModel>()
                      .toList()
                  : <BankDetailsModel>[];

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

    final int endIndex = state.currentPageBank * pageSize;

    if (state.bankByProject.isEmpty) return [];

    return state.bankByProject.sublist(
      0,
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
      emit(state.copyWith(currentPageBank: state.currentPageBank + 1));
    }
  }

  // <---- ADD EMPLOYEE RESPECT TO PROJECTS ---->
  Future<void> getProjectWithEmployee({
    required BuildContext context,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isEmployeeLoading: true));
    var result = await _projectMasterRepository.getProjectWithEmployee(
      projectId: projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isEmployeeLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final allEmployees =
            (response['data'] as List)
                .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                .toList();

        final isSearch = queryParams != null && queryParams.isNotEmpty;

        emit(
          state.copyWith(
            isEmployeeLoading: false,
            employeeByProject: allEmployees,
            employeeByProjectOriginal:
                isSearch ? state.employeeByProjectOriginal : allEmployees,
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

    final int endIndex = state.currentPageEmployee * pageSize;

    if (state.employeeByProject.isEmpty) return [];

    return state.employeeByProject.sublist(
      0,
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
      emit(state.copyWith(currentPageEmployee: state.currentPageEmployee + 1));
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
        getProjectWithBankDetails(
          projectId: int.parse(projectId),
          context: context,
        );
        showSuccessMessage(context, subTitle: response["message"]);
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
        getProjectWithBankDetails(projectId: projectId, context: context);
        showSuccessMessage(
          context,
          subTitle: 'Project with bank details deleted successfully',
        );
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
      pageSize:
          isAllSelected ? state.totalNumberOfRecordCompanyMaster : pageSize,
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

        companyList = List.from(rawList);

        emit(
          state.copyWith(
            isLoading: false,
            currentPageCompanyMaster: pageNumber,
            totalNumberOfRecordCompanyMaster: totalRecords,
          ),
        );
      },
    );

    return companyList;
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
      pageSize:
          isAllSelected ? state.totalNumberOfRecordEmployeeMaster : pageSize,
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

        employeeList = List.from(rawList);

        emit(
          state.copyWith(
            isLoading: false,
            currentPageEmployeeMaster: pageNumber,
            totalNumberOfRecordEmployeeMaster: totalRecords,
          ),
        );
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
        getProjectWithCompany(
          projectId: int.parse(projectId),
          context: context,
        );
        await showSuccessMessage(context, subTitle: response["message"]);
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
        await showSuccessMessage(
          context,
          subTitle: 'Employee has been added to the project',
        );
        if (context.mounted) {
          getProjectWithEmployee(
            projectId: int.parse(projectId),
            context: context,
          );
        }
        if (onSuccess != null) onSuccess();
      },
    );
  }

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
        getProjectWithEmployee(context: context, projectId: projectId);
        showSuccessMessage(
          context,
          subTitle: 'Employee has been deleted to the project',
        );
      },
    );
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Project Master ${DateTime.now()}.pdf"
              : "Project Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  //  GET APPROVAL LIST
  Future<void> getApprovalList({
    required BuildContext context,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await utilsRepository.pullModulesWorkflowApproval(
      projectId: projectId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ModulesWorkflowApprovalModel> newData =
            List<ModulesWorkflowApprovalModel>.from(response['data'] ?? []);

        emit(
          state.copyWith(isLoading: false, moduleWorkflowApprovalList: newData),
        );
      },
    );
  }

  // DELETE EMPLOYEE FROM MODULE WORKFLOW APPROVAL
  Future<void> deleteModulesWorkflowApproval({
    required BuildContext context,
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    emit(state.copyWith(isLoading: true));

    final result = await utilsRepository.deleteModulesWorkflowApproval(
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
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Deleted successfully",
        );

        await getApprovalList(context: context, projectId: projectId);

        emit(state.copyWith(isLoading: false));
      },
    );
  }

  // ADD UPDATE MODULES WORKFLOW APPROVAL (FOR ADDING EMPLOYEES TO APPROVAL MODULES)
  Future<void> addUpdateModulesWorkflowApproval({
    required BuildContext context,
    required String employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));

    final result = await utilsRepository.addUpdateModulesWorkflowApproval(
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
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        await getApprovalList(context: context, projectId: projectId);

        emit(state.copyWith(isLoading: false));
      },
    );
  }
}
