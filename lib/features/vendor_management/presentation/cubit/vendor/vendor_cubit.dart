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

  // VENDOR REPOSITORY
  VendorRepository vendorRepository = serviceLocator<VendorRepository>();

  // COMPANY MASTER REPOSITORY
  CompanyMasterRepository companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();

  // <---- SEARCH VENDOR ---->
  Future searchVendor(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, vendorList: []));
    await getVendors(context, 1);
  }

  // <---- GET VENDORS LIST ---->
  Future getVendors(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "VendorName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "CompanyName": state.filterByCompanyName,
      "CompanyType": state.filterByCompanyType,
      "MobileNumber": state.filterByMobileNumber,
      "CityName": state.filterByCity,
      "GSTNumber": state.filterByGstNumber,
      "AadharCardNumber": state.filterByAadhaarCardNumber,
      "PanCardNumber": state.filterByPanCardNumber,
    };

    var result = await vendorRepository.getVendorsList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<VendorModel> newData = List<VendorModel>.from(
          response['data'] ?? [],
        );

        final List<VendorModel> updatedList =
            pageNumber == 1
                ? newData
                : {
                  for (final v in [...state.vendorList, ...newData])
                    v.vendorId: v,
                }.values.toList();

        emit(
          state.copyWith(
            vendorList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
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
        showSuccessMessage(context, subTitle: 'Vendor Deleted Successfully!!!');
        if (index != null) {
          final updatedList = List<VendorModel>.from(state.vendorList);
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              vendorList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getVendors(context, state.currentPage);
        }
      },
    );
  }

  void updateVendorInList(VendorModel updatedVendor, int index) {
    if (state.vendorList.isNotEmpty && index < state.vendorList.length) {
      final updatedList = List<VendorModel>.from(state.vendorList);
      updatedList[index] = updatedVendor;

      emit(state.copyWith(vendorList: updatedList, isLoading: false));
    }
  }

  // <--- SORT VENDOR ---->

  Future sortVendor({
    required BuildContext context,
    String? vendorName,
    String? companyType,
    String? companyName,
    String? mobileNumber,
    String? city,
    String? gstNumber,
    String? aadhaarCardNumber,
    String? panCardNumber,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByCompanyType: "",
          filterByCompanyName: "",
          filterByMobileNumber: "",
          filterByCity: "",
          filterByGstNumber: "",
          filterByAadhaarCardNumber: "",
          filterByPanCardNumber: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          currentPage: 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: vendorName ?? state.searchText,
          filterByCompanyType: companyType ?? state.filterByCompanyType,
          filterByCompanyName: companyName ?? state.filterByCompanyName,
          filterByMobileNumber: mobileNumber ?? state.filterByMobileNumber,
          filterByCity: city ?? state.filterByCity,
          filterByGstNumber: gstNumber ?? state.filterByGstNumber,
          filterByAadhaarCardNumber:
              aadhaarCardNumber ?? state.filterByAadhaarCardNumber,
          filterByPanCardNumber: panCardNumber ?? state.filterByPanCardNumber,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          currentPage: 1,
        ),
      );
    }

    await getVendors(context, 1);
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
    await getVendors(context, state.currentPage);
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "vendor_${DateTime.now()}.pdf"
              : "vendor_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(VendorState state) {
    final hasSort =
        state.currentSortColumn == "Vendor Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByCompanyName.trim().isNotEmpty,
      state.filterByCompanyType.trim().isNotEmpty,
      state.filterByMobileNumber.trim().isNotEmpty,
      state.filterByCity.trim().isNotEmpty,
      state.filterByGstNumber.trim().isNotEmpty,
      state.filterByAadhaarCardNumber.trim().isNotEmpty,
      state.filterByPanCardNumber.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
