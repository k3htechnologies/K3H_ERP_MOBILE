import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'terms_and_conditions_state.dart';

class TermsAndConditionsCubit extends Cubit<TermsAndConditionsState> {
  TermsAndConditionsCubit() : super(TermsAndConditionsState.initial());

  final TermsAndConditionsMasterRepository _termsAndConditionsMasterRepository =
      serviceLocator<TermsAndConditionsMasterRepository>();

  // CLEAR SEARCH
  void clearSearch(){
    emit(state.copyWith(
      searchTextBooking: "",
      searchTextMaterialRequisition: "",
    ));
  }

  // <---- GET MATERIAL REQUISITION LIST ---->
  Future getMaterialRequisitionTermsAndConditionList(
    BuildContext context,
    int pageNumber, {
    String? searchOverride,
  }) async {
    final String searchText = searchOverride ?? "";
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {};
    if (searchText.trim().isNotEmpty) {
      queryParams["Title"] = searchText.trim();
    }
    var result = await _termsAndConditionsMasterRepository
        .getTermsAndConditionsList(
          pageNumber: pageNumber,
          pageSize: 10,
          moduleName: "MATERIAL REQUISITION",
          queryParams: queryParams,
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<TermsAndConditionsModel> updatedList =
            pageNumber == 1
                ? []
                : List.from(state.materialRequisitionTermsAndConditionsList);
        updatedList.addAll(response['data'] as List<TermsAndConditionsModel>);
        emit(
          state.copyWith(
            isLoading: false,
            materialRequisitionTermsAndConditionsList: updatedList,
            materialRequisitionTotalNumberOfRecordTermsAndConditions:
                response['totalNumberOfRecord'] == 0 &&
                        state.materialRequisitionCurrentPageTermsAndConditions !=
                            1
                    ? state.materialRequisitionTotalNumberOfRecordTermsAndConditions -
                        1
                    : response['totalNumberOfRecord'],
            materialRequisitionCurrentPageTermsAndConditions: pageNumber,
            searchTextMaterialRequisition: searchText,
          ),
        );
      },
    );
  }

  // <---- GET BOOKING LIST ---->
  Future getBookingTermsAndConditionList(
    BuildContext context,
    int pageNumber, {
    String? searchOverride,
  }) async {
    final String searchText = searchOverride ?? "";
    emit(state.copyWith(isLoading: true));
    final Map<String, dynamic> queryParams = {};
    if (searchText.trim().isNotEmpty) {
      queryParams["Title"] = searchText.trim();
    }
    var result = await _termsAndConditionsMasterRepository
        .getTermsAndConditionsList(
          pageNumber: pageNumber,
          pageSize: 10,
          moduleName: "BOOKING",
          queryParams: queryParams,
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<TermsAndConditionsModel> updatedList =
            pageNumber == 1
                ? []
                : List.from(state.bookingTermsAndConditionsList);
        updatedList.addAll(response['data'] as List<TermsAndConditionsModel>);

        emit(
          state.copyWith(
            isLoading: false,
            bookingTermsAndConditionsList: updatedList,
            bookingTotalNumberOfRecordTermsAndConditions:
                response['totalNumberOfRecord'] == 0 &&
                        state.bookingCurrentPageTermsAndConditions != 1
                    ? state.bookingTotalNumberOfRecordTermsAndConditions - 1
                    : response['totalNumberOfRecord'],
            bookingCurrentPageTermsAndConditions: pageNumber,
            searchTextBooking: searchText,
          ),
        );
      },
    );
  }

  // <---- ADD MATERIAL REQUISITION ---->
  Future addMaterialRequisition({
    required BuildContext context,
    required String name,
    required String module,
    required String description,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "TermsAndConditionsMasterId": 0,
      "ModuleName": "MATERIAL REQUISITION",
      "Title": name,
      "Description": description,
    };
    var addResult = await _termsAndConditionsMasterRepository
        .addUpdateTermsAndConditions(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: "Terms and Conditions Added Successfully",
        );
        goRouter.pop();
      },
    );
  }

  // <---- UPDATE MATERIAL REQUISITION ---->
  Future updateMaterialRequisition({
    required BuildContext context,
    required int termsAndConditionId,
    required String uniqueKey,
    required String name,
    required String module,
    required String description,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "TermsAndConditionsMasterId": termsAndConditionId,
      "Uniquekey": uniqueKey,
      "ModuleName": "MATERIAL REQUISITION",
      "Title": name,
      "Description": description,
    };
    var addResult = await _termsAndConditionsMasterRepository
        .addUpdateTermsAndConditions(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedItem = response['data'][0] as TermsAndConditionsModel;

        if (state.materialRequisitionTermsAndConditionsList.isNotEmpty &&
            index < state.materialRequisitionTermsAndConditionsList.length) {
          final updatedList = List<TermsAndConditionsModel>.from(
            state.materialRequisitionTermsAndConditionsList,
          );
          updatedList[index] = updatedItem;
          emit(
            state.copyWith(
              materialRequisitionTermsAndConditionsList: updatedList,
              isLoading: false,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Terms and Conditions Updated Successfully",
        );
      },
    );
  }

  // <---- ADD BOOKING ---->
  Future addBooking({
    required BuildContext context,
    required String name,
    required String module,
    required String description,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "TermsAndConditionsMasterId": 0,
      "ModuleName": "BOOKING",
      "Title": name,
      "Description": description,
    };
    var addResult = await _termsAndConditionsMasterRepository
        .addUpdateTermsAndConditions(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: "Terms and Conditions Added Successfully",
        );
        goRouter.pop();
      },
    );
  }

  // <---- UPDATE BOOKING ---->
  Future updateBooking({
    required BuildContext context,
    required int termsAndConditionId,
    required String uniqueKey,
    required String name,
    required String module,
    required String description,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "TermsAndConditionsMasterId": termsAndConditionId,
      "Uniquekey": uniqueKey,
      "ModuleName": 'BOOKING',
      "Title": name,
      "Description": description,
    };
    var addResult = await _termsAndConditionsMasterRepository
        .addUpdateTermsAndConditions(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedItem = response['data'][0] as TermsAndConditionsModel;

        if (state.bookingTermsAndConditionsList.isNotEmpty &&
            index < state.bookingTermsAndConditionsList.length) {
          final updatedList = List<TermsAndConditionsModel>.from(
            state.bookingTermsAndConditionsList,
          );
          updatedList[index] = updatedItem;
          emit(
            state.copyWith(
              bookingTermsAndConditionsList: updatedList,
              isLoading: false,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: "Terms and Conditions Updated Successfully",
        );
      },
    );
  }

  // <---- DELETE MATERIAL REQUISITION ---->
  Future deleteMaterialRequisition({
    required BuildContext context,
    required int termsAndConditionsMasterId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _termsAndConditionsMasterRepository
        .deleteTermsAndConditions(
          termsAndConditionsMasterId: termsAndConditionsMasterId,
          uniquekey: uniqueKey,
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
          subTitle: "Terms and Conditions Deleted Successfully",
        );
        if (index != null) {
          final updatedList = List<TermsAndConditionsModel>.from(
            state.materialRequisitionTermsAndConditionsList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              isLoading: false,
              materialRequisitionTermsAndConditionsList: updatedList,
            ),
          );
        } else {
          getMaterialRequisitionTermsAndConditionList(context, pageNumber);
        }
      },
    );
  }

  // <---- DELETE BOOKING ---->
  Future deleteBooking({
    required BuildContext context,
    required int termsAndConditionsMasterId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _termsAndConditionsMasterRepository
        .deleteTermsAndConditions(
          termsAndConditionsMasterId: termsAndConditionsMasterId,
          uniquekey: uniqueKey,
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
          subTitle: "Terms and Conditions Deleted Successfully",
        );
        if (index != null) {
          final updatedList = List<TermsAndConditionsModel>.from(
            state.bookingTermsAndConditionsList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              isLoading: false,
              bookingTermsAndConditionsList: updatedList,
            ),
          );
        } else {
          getBookingTermsAndConditionList(context, pageNumber);
        }
      },
    );
  }

  // <---- SEARCH BOOKING ---->
  Future searchBooking(BuildContext context, String value) async {
    emit(
      state.copyWith(
        searchTextBooking: value,
        bookingTermsAndConditionsList: [],
      ),
    );
    await getBookingTermsAndConditionList(context, 1, searchOverride: value);
  }

  // <---- SEARCH MATERIAL REQUISITION ---->
  Future searchMaterialRequisition(BuildContext context, String value) async {
    emit(
      state.copyWith(
        searchTextMaterialRequisition: value,
        materialRequisitionTermsAndConditionsList: [],
      ),
    );
    await getMaterialRequisitionTermsAndConditionList(
      context,
      1,
      searchOverride: value,
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdfMaterialRequisition(
    BuildContext context,
    String exportType,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _termsAndConditionsMasterRepository
        .exportTermsAndConditions(
          pageNumber: 1,
          pageSize:
              state.materialRequisitionTotalNumberOfRecordTermsAndConditions,
          moduleName: "MATERIAL REQUISITION",
          queryParams:
              state.searchTextMaterialRequisition != ""
                  ? {
                    "Title": state.searchTextMaterialRequisition,
                    "ExportType": exportType,
                  }
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
              ? "Terms & Conditions Master ${DateTime.now()}.pdf"
              : "Terms & Conditions Master ${DateTime.now()}.xlsx",
        );
        showSuccessMessage(
          context,
          subTitle: 'Exported as $exportType Successfully',
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdfBooking(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _termsAndConditionsMasterRepository
        .exportTermsAndConditions(
          pageNumber: 1,
          pageSize: state.bookingTotalNumberOfRecordTermsAndConditions,
          moduleName: 'BOOKING',
          queryParams:
              state.searchTextBooking != ""
                  ? {"Title": state.searchTextBooking, "ExportType": exportType}
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
              ? "Terms & Conditions Master ${DateTime.now()}.pdf"
              : "Terms & Conditions Master ${DateTime.now()}.xlsx",
        );
        showSuccessMessage(
          context,
          subTitle: 'Exported as $exportType Successfully',
        );
      },
    );
  }

  // Same as Call Tracker: only update state; screen calls the API on tab change.
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        isLoading: true,
        currentTabIndex: index,
        searchTextBooking: "",
        searchTextMaterialRequisition: "",
        bookingTermsAndConditionsList: [],
        materialRequisitionTermsAndConditionsList: [],
        bookingCurrentPageTermsAndConditions: 1,
        materialRequisitionCurrentPageTermsAndConditions: 1,
      ),
    );
    clearSearch();
  }
}
