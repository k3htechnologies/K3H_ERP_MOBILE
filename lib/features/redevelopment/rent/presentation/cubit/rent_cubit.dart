import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/repository/rent.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'rent_state.dart';

class RentCubit extends Cubit<RentState> {
  RentCubit() : super(RentState.initial());

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // PROPOSED OFFER REPOSITORY
  final ProposedOfferRepository _proposedOfferRepository =
      serviceLocator<ProposedOfferRepository>();

  // EMPLOYEE MASTER REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // RENT REPOSITORY
  final RentRepository _rentRepository = serviceLocator<RentRepository>();

  // <---- GET BUILDING LIST ---->
  Future getBuildingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },

      (response) {
        final newData = List<RedevelopmentBuildingModel>.from(response['data']);

        List<RedevelopmentBuildingModel> updatedList;

        if (pageNumber == 1) {
          updatedList =
              state.buildingList
                  .where((b) => b.projectId != projectId)
                  .toList();
        } else {
          updatedList = List.from(state.buildingList);
        }

        final Map<int, RedevelopmentBuildingModel> uniqueMap = {
          for (var b in updatedList) b.buildingId: b,
        };

        for (final b in newData) {
          if (b.projectId == projectId) {
            uniqueMap[b.buildingId] = b;
          }
        }

        updatedList = uniqueMap.values.toList();

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            buildingList: updatedList,
            buildingTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- GET BANK LIST ---->
  Future<Map<String, dynamic>> getBankList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 10,
      query: {'BankName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {
          "itemList": <Map<String, dynamic>>[
            {'zAttributesId': -1, 'DisplayName': 'Select Bank'},
          ],
          "totalNumberOfRecord": 0,
        };
      },
      (response) {
        final List<Map<String, dynamic>> banks =
            List<Map<String, dynamic>>.from(
              (response['data'] as List<dynamic>).map(
                (e) => {
                  "zAttributesId": e["BankListMasterId"],
                  "DisplayName": e["BankNameWithCode"],
                },
              ),
            );

        return {
          "itemList": [...banks],
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- GET PROJECT WITH BANK DETAILS ---->
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
        final data = response["data"] as List<dynamic>? ?? [];

        return {
          "itemList": List<Map<String, dynamic>>.from(
            data.map(
              (e) => {
                "zAttributesId": e["BankListMasterId"],
                "DisplayName": e["BankName"],
                "AccountHolderName": e["BeneficiaryAccountHolderName"],
                "AccountNumber": e["AccountNumber"],
                "Branch": e["Branch"],
                "IFSCCode": e["IFSCCode"],
                "AcType": e["AcType"],
              },
            ),
          ),
          "totalNumberOfRecord": data.length,
        };
      },
    );
  }

  // <---- PULL RENT DETAILS (For Tenure List) ---->
  Future pullRentDetails({
    required BuildContext context,
    required int projectId,
    required int buildingId,
  }) async {
    final result = await _proposedOfferRepository.pullRentDetails(
      projectId: projectId,
      buildingId: buildingId,
    );
    return result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<RentDetailsModel> rentDetailsList =
            List<RentDetailsModel>.from(response['data'] ?? []);

        emit(state.copyWith(rentDetails: rentDetailsList));
      },
    );
  }

  // <---- EXTRACT TENURE LIST FROM RENT DETAILS ---->
  void extractTenureList(String chargeType) {
    final List<RentDetailsModel> rentDetailsList = state.rentDetails;

    final Set<String> tenureSet = {};
    for (var item in rentDetailsList) {
      debugPrint("  - Type: '${item.type}', Tenure: '${item.tenure}'");
      final String tenureValue = item.tenure.trim();
      if (tenureValue.isNotEmpty) {
        String tenure = tenureValue;
        if (tenureValue.toLowerCase().startsWith('tenure')) {
          tenure = tenureValue.substring(6).trim();
        }
        if (tenure.isNotEmpty) {
          tenureSet.add(tenure);
          debugPrint("    -> Added tenure: '$tenure' (from '$tenureValue')");
        }
      }
    }
    final List<String> tenureList = tenureSet.toList()..sort();

    emit(state.copyWith(tenureList: tenureList));
  }

  // <---- PULL CHARGES DETAILS ---->
  Future pullChargesDetails({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
    required int buildingId,
    required String chargeName,
    required String tenure,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"ChargeType": chargeName};
    if (tenure.isNotEmpty) {
      queryParams["Tenure"] = tenure;
    }

    final result = await _rentRepository.pullTenantApplicantCharges(
      pageNumber: pageNumber,
      pageSize: 5,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: queryParams,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final List<RentModel> rawData = List<RentModel>.from(
          response['data'] ?? [],
        );
        final int totalRecords = response['totalNumberOfRecord'] ?? 0;
        final Map<String, RentModel> uniqueItemsMap = {};
        for (var item in rawData) {
          final String uniqueKey =
              "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
          if (!uniqueItemsMap.containsKey(uniqueKey)) {
            uniqueItemsMap[uniqueKey] = item;
          }
        }
        final List<RentModel> newData = uniqueItemsMap.values.toList();

        List<RentModel> updatedList;
        if (pageNumber == 1) {
          updatedList = newData;
        } else {
          final Map<String, RentModel> existingItemsMap = {};
          for (var item in state.rentList) {
            final String uniqueKey =
                "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
            existingItemsMap[uniqueKey] = item;
          }
          final List<RentModel> uniqueNewData = [];
          for (var item in newData) {
            final String uniqueKey =
                "${item.tenantApplicantChargesId}_${item.tenantId}_${item.tenantApplicantId}_${item.buildingId}_${item.stage}_${item.date.toIso8601String()}_${item.amount}";
            if (!existingItemsMap.containsKey(uniqueKey)) {
              uniqueNewData.add(item);
            }
          }

          updatedList = [...state.rentList, ...uniqueNewData];
        }
        emit(
          state.copyWith(
            isLoading: false,
            rentList: updatedList,
            totalNumberOfRecord: totalRecords,
            currentPage: pageNumber,
            selectedTenure: tenure,
          ),
        );
      },
    );
  }

  // HELPER ON TAB CHANGED
  void onTabChanged(
    int index,
    BuildContext context, {
    required int projectId,
    required int? buildingId,
    required String? tenure,
    required String tabName,
  }) {
    emit(
      state.copyWith(
        rentList: [],
        selectedTenure: "",
        selectedTenureIndex: -1,
        currentPage: 1,
        currentTabIndex: index,
      ),
    );

    if (buildingId == null) {
      return;
    }

    if (tabName == 'Rent' || tabName == 'Brokerage') {
      extractTenureList(tabName);
      pullChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
        chargeName: tabName,
        tenure: "",
      );
    } else {
      emit(state.copyWith(tenureList: []));
      pullChargesDetails(
        context: context,
        pageNumber: 1,
        projectId: projectId,
        buildingId: buildingId,
        chargeName: tabName,
        tenure: "",
      );
    }
  }

  // HELPER ON TENURE CHANGED
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

    pullChargesDetails(
      context: context,
      pageNumber: 1,
      projectId: projectId,
      buildingId: buildingId,
      chargeName: tabName,
      tenure: tenure,
    );
  }

  // <---- ADD PAYMENT TRACKING RENT ---->
  Future addPayTrackRent({
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
    required String paymentType,
    required String payAmount,
    required String transactionChequeDemandDraftNumber,
    required String tenure,
    required String chargeType,
    required DateTime transactionChequeDemandDraftDate,
    required MultiFilePickerModel transactionChequeDemandDraftURL,
    required MultiFilePickerModel paymentReceiptURL,
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
      "PaymentFor": '',
      "AmountType": amountType,
      "PaymentType": paymentType,
      "PaymentMode": paymentMode,
      "PayAmount": payAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate":
          transactionChequeDemandDraftDate.toIso8601String(),
      "Tenure": tenure,
      "ChargeType": chargeType,
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

    var addResult = await _rentRepository.addUpdatePayTrackRent(
      requestBody: requestBody,
      fileList: fileList,
    );

    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(
          context,
          subTitle: "Payment tracking added successfully",
        );
      },
    );
  }

  // <---- UPDATE PAYMENT TRACKING RENT (reference: employee updateEmployeeMaster) ---->
  Future updatePayTrackRent({
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
    required String paymentType,
    required String payAmount,
    required String transactionChequeDemandDraftNumber,
    required String tenure,
    required String chargeType,
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
      "PaymentType": paymentType,
      "PaymentMode": paymentMode,
      "PayAmount": payAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate":
          transactionChequeDemandDraftDate.toIso8601String(),
      "Tenure": tenure,
      "ChargeType": chargeType,
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

    var updateResult = await _rentRepository.addUpdatePayTrackRent(
      requestBody: requestBody,
      fileList: fileList,
    );

    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedPayment =
            response['data'] != null && (response['data'] as List).isNotEmpty
                ? PaymentLedgerModel.fromJson(
                  (response['data'] as List).first as Map<String, dynamic>,
                )
                : null;
        if (updatedPayment != null &&
            state.paymentLedgerList != null &&
            index >= 0 &&
            index < state.paymentLedgerList!.length) {
          final updatedList = List<PaymentLedgerModel>.from(
            state.paymentLedgerList ?? [],
          );
          updatedList[index] = updatedPayment;
          emit(state.copyWith(paymentLedgerList: updatedList));
        }
        showSuccessMessage(context, subTitle: "Payment updated successfully");
      },
    );
  }

  // <---- GET PAY TRACK RENT LIST ---->
  Future getPayTrackRentList(
    BuildContext context,
    int tenantId,
    int tenantApplicantId,
    int buildingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _rentRepository.getPayTrackRentLedgerList(
      pageNumber: 1,
      pageSize: 100,
      tenantId: tenantId,
      tenantApplicantId: tenantApplicantId,
      buildingId: buildingId,
      projectId: projectId,
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

  // <---- DELETE PAY TRACK RENT ---->
  Future deletePayTrackRent({
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
    var deleteResult = await _rentRepository.deletePayTrackRent(
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
        showSuccessMessage(
          context,
          subTitle: 'Payment Deleted Successfully!!!',
        );
        final updatedList = List<PaymentLedgerModel>.from(
          state.paymentLedgerList ?? [],
        );
        updatedList.removeAt(index!);

        emit(state.copyWith(paymentLedgerList: updatedList, isLoading: false));
      },
    );
  }
}
