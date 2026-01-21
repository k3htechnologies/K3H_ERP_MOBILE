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

  // <---- RESET STATE ---->
  void resetState() {
    emit(AssetMasterState.initial());
  }

  // <---- SEARCH ASSET ---->
  void searchAsset(String value, BuildContext context) {
    emit(
      state.copyWith(
        assetList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );

    getAssetsList(context: context, pageNumber: 1);
  }

  // <---- SORT ASSET ---->
  void sortAssetList(
    BuildContext context,
    String sortDirection,
    String sortColumn,
  ) {
    emit(
      state.copyWith(
        currentSortColumn: sortColumn,
        currentSortDirection: sortDirection,
        assetList: [],
        isLoading: true,
        currentPage: 1,
      ),
    );

    getAssetsList(context: context, pageNumber: 1);
  }

  // <---- GET ASSET LIST ---->
  Future getAssetsList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    final queryParams = {
      "AssetName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await assetMasterRepository.getAssetList(
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
        final List<AssetMasterModel> newData = List<AssetMasterModel>.from(
          response['data'] ?? [],
        );

        final List<AssetMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.assetList, ...newData];

        emit(
          state.copyWith(
            assetList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD ASSET ---->
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

    final body = {
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

    final result = await assetMasterRepository.addUpdateAsset(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final newAsset = response['data'] as AssetMasterModel;
        emit(
          state.copyWith(
            assetList: [newAsset, ...state.assetList],
            totalNumberOfRecord: state.totalNumberOfRecord + 1,
          ),
        );

        showSuccessMessage(context, subTitle: 'Asset Added Successfully');
      },
    );
  }

  // <---- UPDATE ASSET ---->
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

    final body = {
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

    final result = await assetMasterRepository.addUpdateAsset(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        if (index < state.assetList.length) {
          final updatedList = List<AssetMasterModel>.from(state.assetList);
          updatedList[index] = response['data'] as AssetMasterModel;

          emit(state.copyWith(assetList: updatedList));
        }

        showSuccessMessage(context, subTitle: 'Asset Updated Successfully');
      },
    );
  }

  // <---- DELETE ASSET ---->
  Future deleteAsset(
    AssetMasterModel asset,
    BuildContext context,
    int index,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await assetMasterRepository.deleteAsset(
      assetMasterId: asset.assetMasterId,
      uniqueKey: asset.uniquekey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        final updatedList = List<AssetMasterModel>.from(state.assetList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            assetList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: "Asset Deleted Successfully");
      },
    );
  }

  // <---- EXPORT ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await assetMasterRepository.exportAsset(
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
              ? "asset_${DateTime.now()}.pdf"
              : "asset_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
