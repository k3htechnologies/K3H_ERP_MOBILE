import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/data/repository/vendor.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  VendorCubit() : super(VendorState.initial());

  VendorRepository vendorRepository = serviceLocator<VendorRepository>();

  CompanyMasterRepository companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();

  // <---- GET VENDORS LIST ---->
  Future getVendors(BuildContext context, int pageNumber, int pageSize) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "VendorName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "CompanyName": state.filterByCompanyName,
      "CompanyType": state.filterByCompanyType,
    };
    var result = await vendorRepository.getVendorsList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        List<VendorModel> updatedList = List.from(state.vendorList);
        updatedList.addAll(response['data'] as List<VendorModel>);
        emit(
          state.copyWith(
            isLoading: false,
            vendorList: updatedList,
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

  // <---- DELETE VENDOR  ---->
  Future deleteVendor({
    required BuildContext context,
    required int vendorId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await vendorRepository.deleteVendor(
      vendorId: vendorId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<VendorModel>.from(state.vendorList);
          updatedList.removeAt(index);
          emit(state.copyWith(vendorList: updatedList));
        } else {
          getVendors(context, state.currentPage, 10);
        }
      },
    );
  }

  // <---- SEARCH VENDOR ---->
  Future searchVendor(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, vendorList: []));
    await getVendors(context, 1, 10);
  }

  // <--- SORT VENDOR ---->
  Future sortVendor(
    BuildContext context,
    String value,
    String direction,
  ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        vendorList: [],
      ),
    );
    await getVendors(context, 1, 10);
  }

  // <---- FILTER CP ---->
  Future filterVendor({
    required BuildContext context,
    required String companyName,
    required String companyType,
  }) async {
    emit(
      state.copyWith(
        filterByCompanyName: companyName,
        filterByCompanyType: companyType,
        vendorList: [],
      ),
    );
    await getVendors(context, state.currentPage, 20);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await vendorRepository.exportVendor(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"VendorName": state.searchText, "ExportType": exportType}
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
              ? "vendor_${DateTime.now()}.pdf"
              : "vendor_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // <---- GET MAGIC LINK ---->
 /* Future<String?> getMagicLink(
    BuildContext context,
    int clientRegistrationId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await vendorRepository.getMagicLink(
      magicLinkType: "VENDOR MANAGEMENT",
      clientRegistrationId: clientRegistrationId,
    );
    goRouter.pop();
    return result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return null;
      },
      (url) {
        return url;
      },
    );
  }*/
}
