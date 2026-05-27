import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/model/inventory_parking_details.model.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/model/inventory_parking_overall_report.model.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/repository/inventory_report.repository.dart';

import 'package:k3h_erp_app/features/inventory_reports/presentation/cubit/inventory_report_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class InventoryReportCubit extends Cubit<InventoryReportState> {
  InventoryReportCubit() : super(InventoryReportState.initial());
  final InventoryReportRepository inventoryReportRepository =
      serviceLocator<InventoryReportRepository>();

  void resetState() {
    emit(InventoryReportState.initial());
  }

  void search(BuildContext context, String query) {
    emit(state.copyWith(searchText: query));
    getInventoryReport(pageNumber: 1, context: context);
  }

  /// Inventory Report List
  Future<void> getInventoryReport({
    required int pageNumber,
    required BuildContext context,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = {"ProjectName": state.searchText};
    final response = await inventoryReportRepository.getInventoryReport(
      pageSize: 10,
      pageNumber: pageNumber,
      queryParams: queryParams,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            reportList: [],
            reportDetailsList: state.reportDetailsList,
          ),
        );
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        final List<InventoryParkingDetailsModel> newData =
            response['data'] as List<InventoryParkingDetailsModel>;
        final List<InventoryParkingDetailsModel> updatedList =
            pageNumber == 1 ? newData : [...state.reportList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            reportList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            reportDetailsList: null,
          ),
        );
      },
    );
  }

  /// Inventory Overall Report
  Future<void> getInventoryOverallReport({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final response = await inventoryReportRepository.getInventoryOverallReport(
      pageSize: 1,
      pageNumber: 1,
      projectId: projectId,
      queryParams: queryParams,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            reportList: state.reportList,
            reportDetailsList: null,
          ),
        );
      },
      (result) {
        final reportDetails =
            result['data'] as List<InventoryParkingOverallReport>;

        emit(
          state.copyWith(
            isLoading: false,
            reportList: state.reportList,
            reportDetailsList: reportDetails,
          ),
        );
      },
    );
  }

  /// Clear State
  void clearReport() {
    emit(InventoryReportState.initial());
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await inventoryReportRepository.getInventoryReportForExport(
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
              ? "Inventory and Parking Overall Report ${DateTime.now()}.pdf"
              : "Inventory and Parking Overall Report ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
