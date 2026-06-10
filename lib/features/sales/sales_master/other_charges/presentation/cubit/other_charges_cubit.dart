import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'other_charges_state.dart';

class OtherChargesCubit extends Cubit<OtherChargesState> {
  OtherChargesCubit() : super(OtherChargesState.initial());

  // REPOSITORY
  final OtherChargesRepository _otherChargesRepository =
      serviceLocator<OtherChargesRepository>();

  // <---- SEARCH OTHER CHARGES ---->
  Future searchOtherCharges(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, otherChargesList: []));
    await getOtherChargesList(context, 1, projectId);
  }

  // <---- GET OTHER CHARGES LIST ---->
  Future getOtherChargesList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {
      "ChargeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _otherChargesRepository.getOtherChargesList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<OtherChargeModel> newData = List<OtherChargeModel>.from(
          response['data'] ?? [],
        );

        final List<OtherChargeModel> updatedList =
            pageNumber == 1 ? newData : [...state.otherChargesList, ...newData];
        emit(
          state.copyWith(
            otherChargesList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD OTHER CHARGES ---->
  Future addOtherCharges({
    required BuildContext context,
    required int projectId,
    required String chargeName,
    required String calculatedOn,
    required double value,
    required double gstPercentage,
    required double gstValue,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "OtherChargesId": 0,
      "ProjectId": projectId,
      "ChargeName": chargeName,
      "CalculatedOn": calculatedOn,
      "Value": value,
      "GSTPercentage": gstPercentage,
      "GSTValue": gstValue,
    };
    var addResult = await _otherChargesRepository.addUpdateOtherCharges(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Charges Added Successfully!!!');
      },
    );
  }

  // <---- UPDATE OTHER CHARGES ---->
  Future updateOtherCharges({
    required BuildContext context,
    required int otherChargesId,
    required String uniqueKey,
    required int projectId,
    required String chargeName,
    required String calculatedOn,
    required double value,
    required double gstPercentage,
    required double gstValue,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "OtherChargesId": otherChargesId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ChargeName": chargeName,
      "CalculatedOn": calculatedOn,
      "Value": value,
      "GSTPercentage": gstPercentage,
      "GSTValue": gstValue,
    };
    var addResult = await _otherChargesRepository.addUpdateOtherCharges(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedOtherCharges = response['data'][0] as OtherChargeModel;

        if (state.otherChargesList.isNotEmpty &&
            index < state.otherChargesList.length) {
          final updatedList = List<OtherChargeModel>.from(
            state.otherChargesList,
          );
          updatedList[index] = updatedOtherCharges;
          emit(state.copyWith(otherChargesList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Charges Updated Successfully!!!',
        );
      },
    );
  }

  // <---- DELETE OTHER CHARGES ---->
  Future deleteOtherCharges({
    required BuildContext context,
    required int projectId,
    required int otherChargesId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _otherChargesRepository.deleteOtherCharges(
      projectId: projectId,
      otherChargesId: otherChargesId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Charges Deleted Successfully!!!',
        );
        if (index != null) {
          final updatedList = List<OtherChargeModel>.from(
            state.otherChargesList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              otherChargesList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getOtherChargesList(context, state.currentPage, projectId);
        }
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _otherChargesRepository.exportOtherCharges(
      pageNumber: 1,
      projectId: projectId,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"ChargeName": state.searchText, "ExportType": exportType}
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
              ? "otherCharges_${DateTime.now()}.pdf"
              : "otherCharges_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
