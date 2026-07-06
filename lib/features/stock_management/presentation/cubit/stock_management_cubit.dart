import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management.model.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management_history.model.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management_summary.model.dart';
import 'package:k3h_erp_app/features/stock_management/data/repository/stock_management.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'stock_management_state.dart';

class StockManagementCubit extends Cubit<StockManagementState> {
  StockManagementCubit() : super(StockManagementState.initial());

  // REPOSITORIES
  final StockManagementRepository _stockManagementRepository =
      serviceLocator<StockManagementRepository>();

  // SEARCH CHANNEL PARTNER
  Future searchStock(BuildContext context, String value, int projectId) async {
    emit(state.copyWith(searchText: value, stockList: []));
    await getStockList(context, 1, projectId);
  }

  // GET STOCK LIST
  Future getStockList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"MaterialName": state.searchText};
    var result = await _stockManagementRepository.getStockList(
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
        final List<StockManagementModel> newData =
            List<StockManagementModel>.from(response['data'] ?? []);

        final List<StockManagementModel> updatedList =
            pageNumber == 1 ? newData : [...state.stockList, ...newData];
        emit(
          state.copyWith(
            stockList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // GET STOCK HISTORY LIST
  Future getStockHistoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
    int subMaterialMasterId, {
    String? type,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "SubMaterialMasterId": subMaterialMasterId,
    };
    if (type != null && type.isNotEmpty) {
      queryParams["type"] = type;
    }
    var result = await _stockManagementRepository.getStockHistoryList(
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
        final List<StockManagementHistoryModel> newData =
            List<StockManagementHistoryModel>.from(response['data'] ?? []);

        final List<StockManagementHistoryModel> updatedList =
            pageNumber == 1 ? newData : [...state.stockHistoryList, ...newData];
        emit(
          state.copyWith(
            stockHistoryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // GET STOCK SUMMARY LIST
  Future getStockSummaryList(
    BuildContext context,
    int pageNumber,
    int projectId,
    int subMaterialId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"SubMaterialId": subMaterialId};
    var result = await _stockManagementRepository.getStockSummaryList(
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
        final List<StockManagementSummaryModel> newData =
            List<StockManagementSummaryModel>.from(response['data'] ?? []);

        final List<StockManagementSummaryModel> updatedList =
            pageNumber == 1 ? newData : [...state.stockSummaryList, ...newData];
        emit(
          state.copyWith(
            stockSummaryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addUpdateStock(
    BuildContext context, {
    required int projectId,
    required int subMaterialMasterId,
    required String reason,
    required String inwardOutwardType,
    required String partyName,
    required double materialQuantityInwardOutward,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {
      "SubMaterialMasterId": subMaterialMasterId,
      "ProjectId": projectId,
      "Reason": reason,
      "InwardOutwardType": inwardOutwardType,
      "PartyName": partyName,
      "MaterialQuantityInwardOutward": materialQuantityInwardOutward,
    };

    var result = await _stockManagementRepository.addUpdateStock(body: body);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));

        showSuccessMessage(
          context,
          subTitle: response["message"] ?? "Stock added successfully",
        );

        /// REFRESH STOCK LIST
        await getStockList(context, 1, projectId);
      },
    );
  }

  Future addUpdateUsedUnusedStock(
    BuildContext context, {
    required int projectId,
    required int subMaterialMasterId,
    required int materialRequisitionGRNStockId,
    required double usedQuantity,
    required double unusedQuantity,
    String? type,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {
      "ProjectId": projectId,
      "MaterialRequisitionGRNStockId": materialRequisitionGRNStockId,
      "UsedQuantity": usedQuantity,
      "UnusedQuantity": unusedQuantity,
    };

    var result = await _stockManagementRepository.addUpdateStockUsage(
      body: body,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, 'Error', failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));

        showSuccessMessage(
          context,
          subTitle: response["message"] ?? "Updated successfully",
        );

        /// REFRESH LIST
        await getStockHistoryList(
          context,
          1,
          projectId,
          subMaterialMasterId,
          type: type,
        );
      },
    );
  }

  // GET STOCK LIST
  Future stocksForExportPDF(
    BuildContext context,
    int projectId,
    String? exportType,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _stockManagementRepository.exportStock(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {
                "ChannelPartnerName": state.searchText,
                "ExportType": exportType,
              }
              : {"ExportType": exportType},
    );
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
          exportType?.toLowerCase() == "pdf"
              ? "Stock Management ${DateTime.now()}.pdf"
              : "Stock Management ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
