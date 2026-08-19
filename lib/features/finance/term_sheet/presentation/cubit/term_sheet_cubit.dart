import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/local_term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/repository/term_sheet.repository.dart';
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

    final Map<String, dynamic> queryParams = {"IsCheckPermission": false};

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
              totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
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

      // DETAIL IDENTIFICATION FIELDS
      requestBody["AddUpdateTermSheetDetails[$index].TermSheetDetailsId"] = "0";

      requestBody["AddUpdateTermSheetDetails[$index].Uniquekey"] = "";

      requestBody["AddUpdateTermSheetDetails[$index].TermSheetId"] = "0";

      requestBody["AddUpdateTermSheetDetails[$index].ProjectId"] = projectId;

      // BASIC DETAILS
      requestBody["AddUpdateTermSheetDetails[$index].LoanTakenBy"] =
          termSheet.loanTakenBy;

      requestBody["AddUpdateTermSheetDetails[$index].NameOfInstitutionBankNBFC"] =
          termSheet.nameOfInstitutionBankNBFC;
      requestBody["AddUpdateTermSheetDetails[$index].Type"] = termSheet.type;

      // DATES
      requestBody["AddUpdateTermSheetDetails[$index].TermSheetDate"] =
          termSheet.termSheetDate;

      requestBody["AddUpdateTermSheetDetails[$index].SanctionDate"] =
          termSheet.sanctionDate;

      requestBody["AddUpdateTermSheetDetails[$index].LoanStartDate"] =
          termSheet.loanStartDate;

      requestBody["AddUpdateTermSheetDetails[$index].LoanEndDate"] =
          termSheet.loanEndDate;

      // AMOUNTS
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

      // MONTHS
      requestBody["AddUpdateTermSheetDetails[$index].MonotoriumPeriodInMonth"] =
          termSheet.monotoriumPeriodInMonth.toString();

      requestBody["AddUpdateTermSheetDetails[$index].LoanTenureInMonth"] =
          termSheet.loanTenureInMonth.toString();

      // OTHER TEXT
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
        showSuccessMessage(context, subTitle: "Invoice Added Successfully");
        getTermSheet(context, 1);
      },
    );
  }
}
