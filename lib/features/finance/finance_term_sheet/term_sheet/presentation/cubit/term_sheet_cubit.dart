import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/local_term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/repository/term_sheet.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'term_sheet_state.dart';

class TermSheetCubit extends Cubit<TermSheetState> {
  TermSheetCubit() : super(TermSheetState.inital());
  // REPOSITORY
  final TermSheetRepository _termSheetRepository =
      serviceLocator<TermSheetRepository>();

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  void clearProjectCompany() {
    emit(state.copyWith(companyByProject: [], isFetchingCompany: false));
  }

  int updateTermSheetFilterCount(TermSheetState state) {
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByCompanyName.trim().isNotEmpty,
      state.filterByStatus.trim().isNotEmpty,
      state.filterByInstitutionName.trim().isNotEmpty,
    ]);
  }

  void clearSearch() {
    emit(state.copyWith(searchText: "", termSheetList: [], currentPage: 1));
  }

  Future searchTermSheet(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, termSheetList: []));
    await getTermSheet(context, 1);
  }

  Future applyTermSheetFilterAndSort({
    required BuildContext context,
    String? projectName,
    String? companyName,
    String? status,
    String? institutionName,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByCompanyName: "",
          filterByStatus: "",
          filterByInstitutionName: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: projectName ?? state.searchText,
          filterByCompanyName: companyName ?? state.filterByCompanyName,
          filterByStatus: status ?? state.filterByStatus,
          filterByInstitutionName:
              institutionName ?? state.filterByInstitutionName,
        ),
      );
    }
    await getTermSheet(context, 1);
  }

  void clearLocalTermSheetData() {
    emit(
      state.copyWith(localTermSheetList: [], hasUnsavedTermSheetChanges: false),
    );
  }

  Future<void> getProjectWithCompany({
    required BuildContext context,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"IsCheckPermission": false};
    var result = await _projectMasterRepository.getProjectWithCompany(
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final allCompanies =
            (response['data'] as List)
                .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
                .toList();

        emit(
          state.copyWith(
            isLoading: false,
            isFetchingCompany: false,
            companyByProject: allCompanies,
          ),
        );
      },
    );
  }

  Future<void> getTermSheet(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "IsCheckPermission": false,
      "ProjectName": state.searchText,
      "CompanyName": state.filterByCompanyName,
      "ApprovalStatus": state.filterByStatus,
      "NameOfInstitutionBankNbfc": state.filterByInstitutionName,
    };

    try {
      final result = await _termSheetRepository.getTermSheet(
        pageSize: 10,
        pageNumber: pageNumber,
        queryParams: queryParams,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false));
          showErrorMessage(context, "Error", failure.message);
        },
        (response) {
          final logs = response['data'] as List<TermSheetModel>;
          final List<TermSheetModel> updatedList =
              pageNumber == 1 ? logs : [...state.termSheetList, ...logs];
          emit(
            state.copyWith(
              termSheetList: updatedList,
              termSheetOverview: logs.isNotEmpty ? logs.first : null,
              totalNumberOfRecord: response['totalNumberOfRecord'],
              currentPage: pageNumber,
              isLoading: false,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint("Get PayTrack Call Log Error => $e");
      debugPrintStack(stackTrace: stackTrace);

      emit(state.copyWith(isLoading: false));
    }
  }

  void addTermSheetLocally(LocalTermSheetModel termSheet) {
    final updatedList = List<LocalTermSheetModel>.from(
      state.localTermSheetList,
    );

    updatedList.add(termSheet);

    emit(
      state.copyWith(
        localTermSheetList: updatedList,
        hasUnsavedTermSheetChanges: true,
      ),
    );
  }

  void updateTermSheetLocally({
    required int index,
    required LocalTermSheetModel termSheet,
  }) {
    final updatedList = List<LocalTermSheetModel>.from(
      state.localTermSheetList,
    );

    if (index < 0 || index >= updatedList.length) {
      return;
    }

    updatedList[index] = termSheet;

    emit(
      state.copyWith(
        localTermSheetList: updatedList,
        hasUnsavedTermSheetChanges: true,
      ),
    );
  }

  void deleteTermSheetLocally(int index) {
    final updatedList = List<LocalTermSheetModel>.from(
      state.localTermSheetList,
    );

    if (index < 0 || index >= updatedList.length) {
      return;
    }

    updatedList.removeAt(index);

    emit(
      state.copyWith(
        localTermSheetList: updatedList,
        hasUnsavedTermSheetChanges: updatedList.isNotEmpty,
      ),
    );
  }

  void clearLocalTermSheets() {
    emit(
      state.copyWith(localTermSheetList: [], hasUnsavedTermSheetChanges: false),
    );
  }

  Future addTermSheet({
    required BuildContext context,
    required String projectId,
    required String companyId,
    required List<LocalTermSheetModel> termSheetList,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "TermSheetId": "0",
      "Uniquekey": "",
      "ProjectId": projectId,
      "CompanyId": companyId,
    };
    List<Map<String, dynamic>> fileList = [];
    for (int index = 0; index < termSheetList.length; index++) {
      final termSheet = termSheetList[index];
      requestBody["AddUpdateTermSheetDetails[$index].TermSheetDetailsId"] = "0";

      requestBody["AddUpdateTermSheetDetails[$index].Uniquekey"] = "";

      requestBody["AddUpdateTermSheetDetails[$index].TermSheetId"] = "0";

      requestBody["AddUpdateTermSheetDetails[$index].ProjectId"] = projectId;
      requestBody["AddUpdateTermSheetDetails[$index].LoanTakenBy"] =
          termSheet.loanTakenBy;
      requestBody["AddUpdateTermSheetDetails[$index].NameOfInstitutionBankNBFC"] =
          termSheet.nameOfInstitutionBankNBFC;
      requestBody["AddUpdateTermSheetDetails[$index].Type"] = termSheet.type;
      requestBody["AddUpdateTermSheetDetails[$index].TermSheetDate"] =
          termSheet.termSheetDate?.toIso8601String() ?? "";
      requestBody["AddUpdateTermSheetDetails[$index].SanctionDate"] =
          termSheet.sanctionDate?.toIso8601String() ?? "";
      requestBody["AddUpdateTermSheetDetails[$index].LoanStartDate"] =
          termSheet.loanStartDate?.toIso8601String() ?? "";
      requestBody["AddUpdateTermSheetDetails[$index].LoanEndDate"] =
          termSheet.loanEndDate?.toIso8601String() ?? "";
      requestBody["AddUpdateTermSheetDetails[$index].FacilityAmount"] =
          termSheet.facilityAmount.toString();
      requestBody["AddUpdateTermSheetDetails[$index].RateOfInterestInPercentage"] =
          termSheet.rateOfInterestInPercentage.toString();
      requestBody["AddUpdateTermSheetDetails[$index].ProcessingFeesInPercentage"] =
          termSheet.processingFeesInPercentage.toString();
      requestBody["AddUpdateTermSheetDetails[$index].LegalAndDocumentationFees"] =
          termSheet.legalAndDocumentationFees.toString();
      requestBody["AddUpdateTermSheetDetails[$index].EMIAmount"] =
          termSheet.emiAmount.toString();
      requestBody["AddUpdateTermSheetDetails[$index].MinimumSellingPrice"] =
          termSheet.minimumSellingPrice.toString();
      requestBody["AddUpdateTermSheetDetails[$index].MonotoriumPeriodInMonth"] =
          termSheet.monotoriumPeriodInMonth.toString();
      requestBody["AddUpdateTermSheetDetails[$index].LoanTenureInMonth"] =
          termSheet.loanTenureInMonth.toString();
      requestBody["AddUpdateTermSheetDetails[$index].OtherImportantTermsIfAny"] =
          termSheet.otherImportantTermsIfAny;
      requestBody["AddUpdateTermSheetDetails[$index].Remark"] =
          termSheet.remark;
      requestBody["AddUpdateTermSheetDetails[$index].RemoveTermSheetURL"] = "";
      final files = termSheet.termSheetFiles;
      for (int i = 0; i < files.fileNameList.length; i++) {
        if (files.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "AddUpdateTermSheetDetails[$index].TermSheetURL",
          "value": files.fileBytesList[i],
          "fileName": files.fileNameList[i],
        });
      }
    }
    var updateResult = await _termSheetRepository.addUpdateTermSheet(
      body: requestBody,
      fileList: fileList,
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
        showSuccessMessage(context, subTitle: response['message']);
        getTermSheet(context, 1);
      },
    );
  }

  Future<void> updateTermSheet({
    required BuildContext context,
    required TermSheetModel? termSheetModel,
    required TermSheetDetailsView? termSheetDetailsView,
    required LocalTermSheetModel updatedTermSheet,
  }) async {
    if (termSheetModel == null) {
      showErrorMessage(context, "Error", "Term Sheet data not found");
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    final String projectId = termSheetModel.projectId.toString();
    final String companyId = termSheetModel.companyId.toString();

    final Map<String, String> requestBody = {
      "TermSheetId": termSheetModel.termSheetId.toString(),
      "Uniquekey": termSheetModel.uniquekey,
      "ProjectId": projectId,
      "CompanyId": companyId,

      "AddUpdateTermSheetDetails[0].TermSheetDetailsId":
          updatedTermSheet.termSheetDetailsId.toString(),

      "AddUpdateTermSheetDetails[0].Uniquekey": updatedTermSheet.uniquekey,

      "AddUpdateTermSheetDetails[0].TermSheetId":
          termSheetModel.termSheetId.toString(),

      "AddUpdateTermSheetDetails[0].ProjectId": projectId,

      "AddUpdateTermSheetDetails[0].LoanTakenBy": updatedTermSheet.loanTakenBy,

      "AddUpdateTermSheetDetails[0].NameOfInstitutionBankNBFC":
          updatedTermSheet.nameOfInstitutionBankNBFC,

      "AddUpdateTermSheetDetails[0].Type": updatedTermSheet.type,

      "AddUpdateTermSheetDetails[0].TermSheetDate":
          updatedTermSheet.termSheetDate?.apiDate ?? "",

      "AddUpdateTermSheetDetails[0].SanctionDate":
          updatedTermSheet.sanctionDate?.apiDate ?? "",

      "AddUpdateTermSheetDetails[0].LoanStartDate":
          updatedTermSheet.loanStartDate?.apiDate ?? "",

      "AddUpdateTermSheetDetails[0].LoanEndDate":
          updatedTermSheet.loanEndDate?.apiDate ?? "",

      "AddUpdateTermSheetDetails[0].FacilityAmount":
          updatedTermSheet.facilityAmount.toString(),

      "AddUpdateTermSheetDetails[0].RateOfInterestInPercentage":
          updatedTermSheet.rateOfInterestInPercentage.toString(),

      "AddUpdateTermSheetDetails[0].ProcessingFeesInPercentage":
          updatedTermSheet.processingFeesInPercentage.toString(),

      "AddUpdateTermSheetDetails[0].LegalAndDocumentationFees":
          updatedTermSheet.legalAndDocumentationFees.toString(),

      "AddUpdateTermSheetDetails[0].EMIAmount":
          updatedTermSheet.emiAmount.toString(),

      "AddUpdateTermSheetDetails[0].MinimumSellingPrice":
          updatedTermSheet.minimumSellingPrice.toString(),

      "AddUpdateTermSheetDetails[0].MonotoriumPeriodInMonth":
          updatedTermSheet.monotoriumPeriodInMonth.toString(),

      "AddUpdateTermSheetDetails[0].LoanTenureInMonth":
          updatedTermSheet.loanTenureInMonth.toString(),

      "AddUpdateTermSheetDetails[0].OtherImportantTermsIfAny":
          updatedTermSheet.otherImportantTermsIfAny,

      "AddUpdateTermSheetDetails[0].Remark": updatedTermSheet.remark,

      "AddUpdateTermSheetDetails[0].RemoveTermSheetURL":
          updatedTermSheet.termSheetFiles.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    final files = updatedTermSheet.termSheetFiles;
    debugPrint("FILE NAMES: ${files.fileNameList}");
    debugPrint("FILE BYTES COUNT: ${files.fileBytesList.length}");
    debugPrint("FILE NAMES COUNT: ${files.fileNameList.length}");
    debugPrint("DELETED FILES: ${files.deletedFileList}");
    for (int i = 0; i < files.fileNameList.length; i++) {
      if (files.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AddUpdateTermSheetDetails[0].TermSheetURL",
        "value": files.fileBytesList[i],
        "fileName": files.fileNameList[i],
      });
    }

    log("UPDATE TERM SHEET BODY: $requestBody");
    debugPrint("DETAIL ID: ${updatedTermSheet.termSheetDetailsId}");

    debugPrint("DETAIL UNIQUEKEY: ${updatedTermSheet.uniquekey}");
    final result = await _termSheetRepository.addUpdateTermSheet(
      body: requestBody,
      fileList: fileList,
    );

    if (context.mounted) {
      goRouter.pop();
    }

    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, "Error", failure.message);
        }
      },
      (response) async {
        if (!context.mounted) return;

        showSuccessMessage(context, subTitle: response["message"]);

        await getTermSheet(context, 1);

        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> getTermSheetView(
    BuildContext context,
    int projectId,
    int termSheetId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {};

    final result = await _termSheetRepository.getTermSheetView(
      projectId: projectId,
      termSheetId: termSheetId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<TermSheetViewModel> newList =
            response['data'] as List<TermSheetViewModel>;

        emit(
          state.copyWith(
            termSheetViewList: newList,
            termSheetDetailsViewModel:
                newList.isNotEmpty &&
                        newList.first.termSheetDetailsData.isNotEmpty
                    ? newList.first.termSheetDetailsData.first
                    : null,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future deleteTermSheet({
    required BuildContext context,
    required TermSheetModel termSheet,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _termSheetRepository.deleteTermSheet(
      projectId: termSheet.projectId,
      termSheetId: termSheet.termSheetId,
      termSheetDetailsId: termSheet.termSheetDetailsId,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        final updatedList = List<TermSheetModel>.from(state.termSheetList);
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            termSheetList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
      },
    );
  }

  Future<void> deleteTermSheetDetails({
    required BuildContext context,
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final deleteResult = await _termSheetRepository.deleteTermSheet(
      projectId: projectId,
      termSheetId: termSheetId,
      termSheetDetailsId: termSheetDetailsId,
    );

    if (context.mounted) {
      goRouter.pop();
    }

    await deleteResult.fold(
      (failure) async {
        if (context.mounted) {
          showErrorMessage(context, 'Error', failure.message);
        }
      },
      (response) async {
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response["message"]);
        }

        await getTermSheetView(context, projectId, termSheetId);
      },
    );
  }

  Future<void> finalizeTermSheetApproval(
    BuildContext context, {
    required int termSheetId,
    required int projectId,
    DateTime? closingDate,
    String? closingRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> body = {
      "TermSheetId": termSheetId,
      "ProjectId": projectId,
      "ActionType": "FINAL APPROVAL",
    };
    if (closingDate != null) {
      body["ClosingDate"] = closingDate.apiDate;
    }

    if (closingRemark != null && closingRemark.trim().isNotEmpty) {
      body["ClosingRemark"] = closingRemark.trim();
    }

    debugPrint("FINALIZE BODY: $body");

    final result = await _termSheetRepository.finalizeApproval(body: body);

    if (context.mounted) {
      goRouter.pop();
    }

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        getTermSheet(context, 1);
        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _termSheetRepository.exportTermSheet(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
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
              ? "TermSheet ${DateTime.now()}.pdf"
              : "TermSheet ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
