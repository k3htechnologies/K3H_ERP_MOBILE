import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/repository/asset_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'asset_master_state.dart';

class AssetMasterCubit extends Cubit<AssetMasterState> {
  AssetMasterCubit() : super(AssetMasterState.initial());

  final AssetMasterRepository assetMasterRepository =
      serviceLocator<AssetMasterRepository>();

  // Track request ID to ignore stale responses
  int _requestId = 0;

  void resetState() {
    emit(AssetMasterState.initial());
  }

  void searchAsset(String value, BuildContext context) {
    emit(
      state.copyWith(
        assetList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getAssetsList(context: context, pageNumber: 1, pageSize: 10);
  }

  void sortAssetList(
    BuildContext context,
    String sortDirection,
    String sortColumn,
  ) {
    emit(
      state.copyWith(
        isLoading: true,
        currentSortColumn: sortColumn,
        currentSortDirection: sortDirection,
      ),
    );
    getAssetsList(
      context: context,
      pageNumber: state.currentPage,
      pageSize: 20,
    );
  }

  Future getAssetsList({
    required BuildContext context,
    required int pageNumber,
    required int pageSize,
  }) async {
    // Increment request ID to track the latest request
    _requestId++;
    final currentRequestId = _requestId;

    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "AssetName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await assetMasterRepository.getAssetList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        // Ignore stale failures from previous requests
        if (currentRequestId != _requestId) {
          return;
        }
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        // Ignore stale responses from previous requests
        if (currentRequestId != _requestId) {
          return;
        }

        final dataList = response['data'];
        List<AssetMasterModel> mappedList;
        if (dataList is List<AssetMasterModel>) {
          mappedList = dataList;
        } else if (dataList is List) {
          mappedList = dataList
              .map((e) => AssetMasterModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          mappedList = [];
        }
        List<AssetMasterModel> updatedList = pageNumber == 1
            ? mappedList
            : [...state.assetList, ...mappedList];
        emit(
          state.copyWith(
            assetList: updatedList,
            isLoading: false,
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

  Future addAsset({
    required BuildContext context,
    required String assetName,
    required String assetCode,
    required String assetType,
    required String assetModel,
    required String assetBrand,
    required String serialNumber,
    required String supplierName,
    required DateTime assetPurchaseDate,
    required String assetCost,
    DateTime? warrantyDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "AssetMasterId": 0,
      "AssetCode": assetCode,
      "AssetName": assetName,
      "AssetType": assetType,
      "AssetModel": assetModel,
      "AssetBrand": assetBrand,
      "SerialNumber": serialNumber,
      "PurchaseDate": assetPurchaseDate.toIso8601String(),
      "AssetCost": assetCost,
      "SupplierName": supplierName,
      if (warrantyDate != null)
        "WarrantyExpiryDate": warrantyDate.toIso8601String(),
    };
    var result = await assetMasterRepository.addUpdateAsset(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (success) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Asset Added Successfully');

        emit(
          state.copyWith(
            assetList: [
              success['data'] as AssetMasterModel,
              ...state.assetList,
            ],
            totalNumberOfRecord: success['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  Future updateAsset({
    required int index,
    required BuildContext context,
    required int assetMasterId,
    required String uniqueKey,
    required String assetName,
    required String assetCode,
    required String assetType,
    required String assetModel,
    required String assetBrand,
    required String serialNumber,
    required String supplierName,
    required DateTime assetPurchaseDate,
    required String assetCost,
    DateTime? warrantyDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "AssetMasterId": assetMasterId,
      "UniqueKey": uniqueKey,
      "AssetCode": assetCode,
      "AssetName": assetName,
      "AssetType": assetType,
      "AssetModel": assetModel,
      "AssetBrand": assetBrand,
      "SerialNumber": serialNumber,
      "PurchaseDate": assetPurchaseDate.toIso8601String(),
      "AssetCost": assetCost,
      "SupplierName": supplierName,
      if (warrantyDate != null)
        "WarrantyExpiryDate": warrantyDate.toIso8601String(),
    };
    var result = await assetMasterRepository.addUpdateAsset(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (success) {
        goRouter.pop();
        final updatedList = List<AssetMasterModel>.from(state.assetList);
        updatedList[index] = success['data'] as AssetMasterModel;
        showSuccessMessage(context, subTitle: "Asset Updated Successfully");

        emit(
          state.copyWith(
            assetList: updatedList,
            totalNumberOfRecord: success['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  Future deleteAsset(
    int index,
    AssetMasterModel asset,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await assetMasterRepository.deleteAsset(
      assetMasterId: asset.assetMasterId,
      uniqueKey: asset.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        showSuccessMessage(context, subTitle: "Asset Deleted Successfully");
        getAssetsList(
          context: context,
          pageNumber: state.currentPage,
          pageSize: 10,
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await assetMasterRepository.exportAsset(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType, "AssetName": state.searchText},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "branch_${DateTime.now()}.pdf"
              : "branch_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
