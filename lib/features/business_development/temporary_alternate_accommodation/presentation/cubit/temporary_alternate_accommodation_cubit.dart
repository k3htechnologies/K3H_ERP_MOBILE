import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/model/project_with_bank_details.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/repository/temporary_alternate_accommodation.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
part 'temporary_alternate_accommodation_state.dart';

class TemporaryAlternateAccommodationCubit
    extends Cubit<TemporaryAlternateAccommodationState> {
  TemporaryAlternateAccommodationCubit()
    : super(TemporaryAlternateAccommodationState.initial());
  // PROPOSED OFFER REPOSITORY
  final ProposedOfferRepository _proposedOfferRepository =
      serviceLocator<ProposedOfferRepository>();
  // EMPLOYEE MASTER REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  // RENT REPOSITORY
  final TemporaryAlternateAccommodationRepository
  _temporaryAlternateAccommodationRepository =
      serviceLocator<TemporaryAlternateAccommodationRepository>();

  void resetState() {
    emit(TemporaryAlternateAccommodationState.initial());
  }

  void search({
    required String value,
    required BuildContext context,
    required int projectId,
    required int? buildingId,
  }) {
    emit(state.copyWith(searchText: value));
    if (buildingId == null) return;
    getChargesDetails(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      buildingId: buildingId,
    );
  }

  void onTabChanged(
    BuildContext context, {
    required int projectId,
    required int? buildingId,
    required String? tenure,
    required String tabName,
  }) async {
    emit(
      state.copyWith(
        rentList: [],
        selectedTenure: "",
        selectedTenureIndex: -1,
        currentPage: 1,
        chargeType: tabName,
        isLoading: true,
      ),
    );

    if (buildingId == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final isTaaOrBrokerage = tabName == 'TAA' || tabName == 'Brokerage';

    if (isTaaOrBrokerage) {
      await getTemporaryAccommodationAlternativeDetails(
        context: context,
        projectId: projectId,
        buildingId: buildingId,
      );
    } else {
      emit(state.copyWith(tenureList: []));
    }

    if (!context.mounted) return;

    if (!isTaaOrBrokerage || state.tenureList.isNotEmpty) {
      await getChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
      );
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future getChargesDetails({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChargeType": state.chargeType,
      "Tenure": state.selectedTenure,
      "FlatNumber": state.searchText,
      "ApplicantName": state.filterByApplicantName,
      "ApplicantType": state.filterByApplicantType,
      "FlatType": state.filterByExistingUnitType,
    };
    final result = await _temporaryAlternateAccommodationRepository
        .pullTenantApplicantCharges(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<TemporaryAlternativeAccommodationModel> newData =
            List<TemporaryAlternativeAccommodationModel>.from(
              response['data'] ?? [],
            );

        final List<TemporaryAlternativeAccommodationModel> updatedList =
            pageNumber == 1 ? newData : [...state.rentList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            rentList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> getBankList(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 15,
      query: value != null && value.isNotEmpty ? {"BankName": value} : {},
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<BankListMasterModel>;
        return {
          "itemList":
              banks.map((bank) {
                return {
                  "zAttributesId": bank.bankListMasterId,
                  "DisplayName": bank.bankNameWithCode,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<List<Map<String, dynamic>>> getProjectWithBankById({
    required int projectWithBankDetailsId,
  }) async {
    ProjectModel project = getProject();
    var result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: project.projectId,
      queryParams: {'ProjectWithBankDetailsId': projectWithBankDetailsId},
    );
    return result.fold(
      (failure) {
        return [];
      },
      (response) {
        final data =
            response["data"] as List<ProjectWithBankDetailsModel>? ?? [];
        return data
            .map(
              (e) => {
                "zAttributesId": e.projectWithBankDetailsId,
                "DisplayName": e.bankName,
                "AccountHolderName": e.beneficiaryAccountHolderName,
                "AccountNumber": e.accountNumber,
                "Branch": e.branch,
                "IFSCCode": e.ifscCode,
                "AcType": e.acType,
                "NatureOfAccount": e.natureOfAccount,
              },
            )
            .toList();
      },
    );
  }

  Future<Map<String, dynamic>> getProjectWithBankDropdown(
    int pageNumber, {
    String? value,
  }) async {
    ProjectModel project = getProject();
    var result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: project.projectId,
    );
    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final data =
            response["data"] as List<ProjectWithBankDetailsModel>? ?? [];
        return {
          "itemList": List<Map<String, dynamic>>.from(
            data.map(
              (e) => {
                "zAttributesId": e.projectWithBankDetailsId,
                "DisplayName": e.bankName,
                "AccountHolderName": e.beneficiaryAccountHolderName,
                "AccountNumber": e.accountNumber,
                "Branch": e.branch,
                "IFSCCode": e.ifscCode,
                "AcType": e.acType,
                "NatureOfAccount": e.natureOfAccount,
              },
            ),
          ),
          "totalNumberOfRecord": data.length,
        };
      },
    );
  }

  // PULL RENT DETAILS (For Tenure List)
  Future<void> getTemporaryAccommodationAlternativeDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    final result = await _proposedOfferRepository
        .pullTemporaryAccommodationAlternativeDetails(
          projectId: projectId,
          buildingId: buildingId,
        );

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final rentDetailsList =
            List<TemporaryAlternativeAccommodationDetailsModel>.from(
              response['data'] ?? [],
            );

        final tenureList =
            rentDetailsList
                .map((item) => item.tenure.trim())
                .where((tenure) => tenure.isNotEmpty)
                .map((tenure) {
                  return tenure.toLowerCase().startsWith('tenure')
                      ? tenure.substring(6).trim()
                      : tenure;
                })
                .where((tenure) => tenure.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        final formattedTenureList =
            tenureList.map((tenure) => 'Tenure $tenure').toList();

        emit(
          state.copyWith(
            rentDetails: rentDetailsList,
            tenureList: formattedTenureList,
            selectedTenure:
                formattedTenureList.isNotEmpty ? formattedTenureList.first : '',
          ),
        );
      },
    );
  }

  void onTenureChanged(
    BuildContext context, {
    required int projectId,
    required int buildingId,
    required String tabName,
    required String tenure,
    required int tenureIndex,
  }) {
    emit(
      state.copyWith(
        selectedTenure: tenure,
        selectedTenureIndex: tenureIndex,
        rentList: [],
        currentPage: 1,
      ),
    );
    getChargesDetails(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      buildingId: buildingId,
    );
  }

  Future applyTAAFilter({
    required BuildContext context,
    String? unitNumber,
    String? existingUnitType,
    String? applicantName,
    String? applicantType,
    bool? isClear,
    required int projectId,
    required int buildingId,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByExistingUnitType: "",
          filterByApplicantName: "",
          filterByApplicantType: "",
          currentPage: 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: unitNumber ?? state.searchText,
          filterByExistingUnitType:
              existingUnitType ?? state.filterByExistingUnitType,
          filterByApplicantName: applicantName ?? state.filterByApplicantName,
          filterByApplicantType: applicantType ?? state.filterByApplicantType,
          currentPage: 1,
        ),
      );
    }
    getChargesDetails(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      buildingId: buildingId,
    );
  }

  Future addPayTrackRentLedger({
    required BuildContext context,
    required int payTrackRentId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
    required int projectId,
    required int projectBankListMasterId,
    required String accountHolderName,
    required int bankListMasterId,
    required String accountNumber,
    required String ifscCode,
    required String paymentMode,
    required String amountType,
    required String payAmount,
    required String transactionChequeDemandDraftNumber,
    required DateTime transactionChequeDemandDraftDate,
    required MultiFilePickerModel transactionChequeDemandDraftURL,
    required MultiFilePickerModel paymentReceiptURL,
    required bool makeChargeTypeApiPull,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PayTrackRentId": payTrackRentId.toString(),
      "TenantId": tenantId.toString(),
      "TenantApplicantId": tenantApplicantId.toString(),
      "BuildingId": buildingId.toString(),
      "ProjectId": projectId.toString(),
      "ProjectBankListMasterId": projectBankListMasterId.toString(),
      "AccountHolderName": accountHolderName,
      "BankListMasterId": bankListMasterId.toString(),
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "AmountType": amountType,
      "PaymentMode": paymentMode,
      "PayAmount": payAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate":
          transactionChequeDemandDraftDate.apiDate.toString(),
      "Tenure": state.selectedTenure,
      "ChargeType": state.chargeType,
    };
    List<Map<String, dynamic>> fileList = [];
    for (
      int i = 0;
      i < transactionChequeDemandDraftURL.fileNameList.length;
      i++
    ) {
      if (transactionChequeDemandDraftURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TransactionChequeDemandDraftURL",
        "value": transactionChequeDemandDraftURL.fileBytesList[i],
        "fileName": transactionChequeDemandDraftURL.fileNameList[i],
      });
    }
    for (int i = 0; i < paymentReceiptURL.fileNameList.length; i++) {
      if (paymentReceiptURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PaymentReceiptURL",
        "value": paymentReceiptURL.fileBytesList[i],
        "fileName": paymentReceiptURL.fileNameList[i],
      });
    }
    var addResult = await _temporaryAlternateAccommodationRepository
        .addUpdatePayTrackRent(requestBody: requestBody, fileList: fileList);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);

        if (makeChargeTypeApiPull) {
          getChargesDetails(
            context: context,
            pageNumber: 1,
            projectId: projectId,
            buildingId: buildingId,
          );
        } else {
          getPayTrackRentLedgerList(
            context,
            tenantId,
            tenantApplicantId,
            buildingId,
            projectId,
          );
        }
      },
    );
  }

  Future updatePayTrackRentLedger({
    required BuildContext context,
    required int payTrackRentId,
    required String uniqueKey,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
    required int projectId,
    required int projectBankListMasterId,
    required String accountHolderName,
    required int bankListMasterId,
    required String accountNumber,
    required String ifscCode,
    required String paymentMode,
    required String amountType,
    required String payAmount,
    required String transactionChequeDemandDraftNumber,
    required DateTime transactionChequeDemandDraftDate,
    required MultiFilePickerModel transactionChequeDemandDraftURL,
    required MultiFilePickerModel paymentReceiptURL,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PayTrackRentId": payTrackRentId.toString(),
      "Uniquekey": uniqueKey,
      "TenantId": tenantId.toString(),
      "TenantApplicantId": tenantApplicantId.toString(),
      "BuildingId": buildingId.toString(),
      "ProjectId": projectId.toString(),
      "ProjectBankListMasterId": projectBankListMasterId.toString(),
      "AccountHolderName": accountHolderName,
      "BankListMasterId": bankListMasterId.toString(),
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "PaymentFor": '',
      "AmountType": amountType,
      "PaymentMode": paymentMode,
      "PayAmount": payAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate":
          transactionChequeDemandDraftDate.toIso8601String(),
      "Tenure": state.selectedTenure,
      "ChargeType": state.chargeType,
      "RemovePaymentReceiptURL": paymentReceiptURL.deletedFileList,
      "RemoveTransactionChequeDemandDraftURL":
          transactionChequeDemandDraftURL.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];
    for (
      int i = 0;
      i < transactionChequeDemandDraftURL.fileNameList.length;
      i++
    ) {
      if (transactionChequeDemandDraftURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TransactionChequeDemandDraftURL",
        "value": transactionChequeDemandDraftURL.fileBytesList[i],
        "fileName": transactionChequeDemandDraftURL.fileNameList[i],
      });
    }
    for (int i = 0; i < paymentReceiptURL.fileNameList.length; i++) {
      if (paymentReceiptURL.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PaymentReceiptURL",
        "value": paymentReceiptURL.fileBytesList[i],
        "fileName": paymentReceiptURL.fileNameList[i],
      });
    }
    var updateResult = await _temporaryAlternateAccommodationRepository
        .addUpdatePayTrackRent(requestBody: requestBody, fileList: fileList);
    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedPaymentLedger =
            (response['data'] as List<PaymentLedgerModel>).first;

        if (state.paymentLedgerList != null &&
            state.paymentLedgerList!.isNotEmpty &&
            index < state.paymentLedgerList!.length) {
          final updatedList = List<PaymentLedgerModel>.from(
            state.paymentLedgerList!,
          );

          updatedList[index] = updatedPaymentLedger;

          emit(
            state.copyWith(isLoading: false, paymentLedgerList: updatedList),
          );
        }

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  double? get paidAmountForSummary => state.paymentLedgerList?.fold<double>(
    0.0,
    (sum, p) => sum + (p.payAmount),
  );

  Future clearPaymentLedger() async {
    emit(state.copyWith(paymentLedgerList: [], paymentLedgerSearchText: ''));
  }

  void onPaymentLedgerSearch({
    required BuildContext context,
    required String value,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
    required int projectId,
  }) {
    emit(state.copyWith(paymentLedgerSearchText: value));
    getPayTrackRentLedgerList(
      context,
      tenantId,
      tenantApplicantId,
      buildingId,
      projectId,
    );
  }

  Future getPayTrackRentLedgerList(
    BuildContext context,
    int tenantId,
    int tenantApplicantId,
    int buildingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _temporaryAlternateAccommodationRepository
        .pullPayTrackRentLedgerList(
          pageNumber: 1,
          pageSize: 100,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
          buildingId: buildingId,
          projectId: projectId,
          queryParams: {
            'ChargeType': state.chargeType,
            'AccountHolderName': state.paymentLedgerSearchText,
          },
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaymentLedgerModel> rawData = List<PaymentLedgerModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(isLoading: false, paymentLedgerList: rawData));
      },
    );
  }

  Future deletePayTrackRentLedger({
    required BuildContext context,
    required int payTrackRentId,
    required String uniqueKey,
    required int projectId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _temporaryAlternateAccommodationRepository
        .deletePayTrackRent(
          payTrackRentId: payTrackRentId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
          buildingId: buildingId,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);
        final updatedList = List<PaymentLedgerModel>.from(
          state.paymentLedgerList ?? [],
        );
        updatedList.removeAt(index!);
        emit(state.copyWith(paymentLedgerList: updatedList, isLoading: false));
      },
    );
  }

  Future<List<TemporaryAlternativeAccommodationModel>>
  getChargesDetailsForView({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"ChargeType": state.chargeType};
    if (state.selectedTenure.isNotEmpty) {
      queryParams["Tenure"] = state.selectedTenure;
    }
    final result = await _temporaryAlternateAccommodationRepository
        .pullTenantApplicantCharges(
          pageNumber: 1,
          pageSize: 1,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
        return [];
      },
      (response) {
        final List<TemporaryAlternativeAccommodationModel> newData =
            List<TemporaryAlternativeAccommodationModel>.from(
              response['data'] ?? [],
            );
        emit(state.copyWith(isLoading: false));
        return newData;
      },
    );
  }

  Future exportExcelPdfForTAA(
    BuildContext context,
    String exportType, {
    required int projectId,
    required int buildingId,
  }) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found.");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _temporaryAlternateAccommodationRepository
        .pullTenantApplicantChargesForExport(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {
            "ExportType": exportType,
            "ChargeType": state.chargeType,
            "Tenure": state.selectedTenure,
          },
          projectId: projectId,
          buildingId: buildingId,
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
              ? "${state.chargeType} ${DateTime.now()}.pdf"
              : "${state.chargeType} ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportExcelPdfForPaymentLedger(
    BuildContext context,
    String exportType, {
    required int projectId,
    required int buildingId,
    required int tenantId,
    required int tenantApplicantId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _temporaryAlternateAccommodationRepository
        .getPayTrackRentLedgerListForExport(
          pageNumber: 1,
          pageSize: 10000,
          queryParams: {
            "ExportType": exportType,
            "ChargeType": state.chargeType,
            "Tenure": state.selectedTenure,
          },
          projectId: projectId,
          buildingId: buildingId,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
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
              ? "Pay Track Rent Ledger ${DateTime.now()}.pdf"
              : "Pay Track Rent Ledger ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(TemporaryAlternateAccommodationState state) {
    return getActiveFilterCount([
      state.searchText.isNotEmpty,
      state.filterByApplicantName.isNotEmpty,
      state.filterByApplicantType.isNotEmpty,
      state.filterByExistingUnitType.isNotEmpty,
    ]);
  }
}
