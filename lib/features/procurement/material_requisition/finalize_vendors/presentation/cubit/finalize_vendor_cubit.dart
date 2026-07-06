import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/repository/finalize_vendor.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'finalize_vendor_state.dart';

class FinalizeVendorCubit extends Cubit<FinalizeVendorState> {
  FinalizeVendorCubit() : super(FinalizeVendorState.initial());

  FinalizeVendorRepository finalizeVendorRepository =
      serviceLocator<FinalizeVendorRepository>();

  Future getVendorForEnquiryList(
    BuildContext context,
    int projectId,
    int materialRequisitionId,
    String uniquekey,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await finalizeVendorRepository
        .getAllAvailableVendorForRequisition(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniquekey: uniquekey,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            vendorSelectionForEnquiryList:
                response['data'] as List<RequisitionVendorModel>,
          ),
        );
      },
    );
  }

  Future getAllAvailableVendorsForEnquiry(
    BuildContext context,
    int projectId,
    int materialRequisitionId,
    String uniqueKey,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await finalizeVendorRepository.getSelectedVendor(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniquekey: uniqueKey,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context);
      },
    );
  }

  Future addVendorForEnquiry({
    required BuildContext context,
    required int projectId,
    required MaterialRequisitionModel materialRequisition,
    required List<int> vendorIds,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      'ProjectId': projectId,
      'MaterialRequisitionId': materialRequisition.materialRequisitionId,
      'Uniquekey': materialRequisition.uniquekey,
      'VendorId': vendorIds.join(','),
    };
    var addResult = await finalizeVendorRepository.addVendorForEnquiry(
      body: body,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context);

        await getSelectedVenodeForCompare(
          context,
          projectId,
          materialRequisition.materialRequisitionId,
          materialRequisition.uniquekey,
        );
        emit(state.copyWith(viewType: FinalizeVendorViewType.finalizedList));
      },
    );
  }

  int isOnlyOneVendorSelected() {
    bool isSelectedFound = false;
    int id = -1;

    for (var item in state.vendorFinalisationForComparison) {
      if (item.isSelected) {
        if (!isSelectedFound) {
          isSelectedFound = true;
          id = item.vendorId;
        } else {
          return 0;
        }
      }
    }

    return id;
  }

  Future addFinalizedVendor({
    required BuildContext context,
    required int projectId,
    required MaterialRequisitionModel materialRequisition,
  }) async {
    var result = isOnlyOneVendorSelected();
    if (result == -1) {
      DialogHelper.showErrorMessage(
        context: context,
        title: 'Error',
        message: 'Select at least one vendor',
      );
      return;
    } else if (result == 0) {
      DialogHelper.showErrorMessage(
        context: context,
        title: 'Error',
        message: 'Select only one vendor',
      );
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      'ProjectId': projectId,
      'MaterialRequisitionId': materialRequisition.materialRequisitionId,
      'Uniquekey': materialRequisition.uniquekey,
      'VendorId': result.toString(),
    };
    var addResult = await finalizeVendorRepository.addFinalizedVendor(
      body: body,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            allAvailableVendorList:
                response['data'] as List<RequisitionVendorModel>,
          ),
        );
        showSuccessMessage(context);
        getVendorForEnquiryList(
          context,
          projectId,
          materialRequisition.materialRequisitionId,
          materialRequisition.uniquekey,
        );
      },
    );
  }

  void toggleVendorSelection(int vendorId) {
    final updatedList =
        state.vendorFinalisationForComparison
            .map(
              (e) => FinalizeVendorForComparisonModel(
                vendorId: e.vendorId,
                uniquekey: e.uniquekey,
                companyName: e.companyName,
                companyType: e.companyType,
                vendorName: e.vendorName,
                mobileNumber: e.mobileNumber,
                emailId: e.emailId,
                aadharCardNumber: e.aadharCardNumber,
                aadharCardUrl: e.aadharCardUrl,
                panCardNumber: e.panCardNumber,
                panCardUrl: e.panCardUrl,
                gstNumber: e.gstNumber,
                gstCertificateUrl: e.gstCertificateUrl,
                address: e.address,
                countryMasterId: e.countryMasterId,
                countryName: e.countryName,
                stateMasterId: e.stateMasterId,
                stateName: e.stateName,
                districtMasterId: e.districtMasterId,
                districtName: e.districtName,
                cityMasterId: e.cityMasterId,
                cityName: e.cityName,
                availableMaterialList: e.availableMaterialList,
                availableContractList: e.availableContractList,
                createdById: e.createdById,
                createdBy: e.createdBy,
                createdDate: e.createdDate,
                modifiedById: e.modifiedById,
                modifiedBy: e.modifiedBy,
                modifiedDate: e.modifiedDate,
                isApproval: e.isApproval,
                isFinalized: e.isFinalized,
                vendorFinalizationApproval: e.vendorFinalizationApproval,

                isSelected: e.vendorId == vendorId ? !e.isSelected : false,

                materialRequisitionQuotationTermsData:
                    e.materialRequisitionQuotationTermsData,
                subMaterialMasterData: e.subMaterialMasterData,
                contractTypeMasterData: e.contractTypeMasterData,
                magicLinkUrl: e.magicLinkUrl,
                systemGeneratedCode: e.systemGeneratedCode,
                projectName: e.projectName,
                paidAmount: e.paidAmount,
                totalPoAmount: e.totalPoAmount,
                totalInvoiceAmount: e.totalInvoiceAmount,
                totalInvoice: e.totalInvoice,
              ),
            )
            .toList();

    emit(state.copyWith(vendorFinalisationForComparison: updatedList));
  }

  Future updateVendorQuotation(
    BuildContext context,
    int projectId,
    MaterialRequisitionQuotationTerms terms,
    int index,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    final payloadList =
        terms.materialRequisitionQuotationData
            .map(
              (e) => {
                'MaterialRequisitionQuotationId':
                    e.materialRequisitionQuotationId,
                'MaterialRequisitionDetailId': e.materialRequisitionDetailId,
                'Logistics': e.logistics,
                'Amount': e.amount,
                'CGST': e.cgst,
                'SGST': e.sgst,
                'UGST': e.ugst,
                'TGST': e.tgst,
              },
            )
            .toList();

    final encodedJson = jsonEncode(payloadList);
    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "MaterialRequisitionQuotationTermsId":
          terms.materialRequisitionQuotationTermsId,
      if (terms.uniquekey.isNotEmpty) "Uniquekey": terms.uniquekey,
      "MaterialRequisitionId": terms.materialRequisitionId,
      "VendorId": terms.vendorId,
      "ExpectedDeliveryInDays": terms.expectedDeliveryInDays,
      "ExpectedPaymentInDays": terms.expectedPaymentInDays,
      "Total": terms.total,
      "MaterialRequisitionQuotationJSON": encodedJson,
    };

    var addResult = await finalizeVendorRepository
        .addToUpdateMaterialRequisitionQuotation(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) async {
        emit(state.copyWith(isLoading: true));
        final updatedList = List<RequisitionVendorModel>.from(
          state.selctedVendorList,
        );
        final dataList =
            response['data'] as List<MaterialRequisitionQuotationTerms>;

        if (dataList.isNotEmpty && index < updatedList.length) {
          final termsData = dataList.first;

          updatedList[index].materialRequisitionQuotationTermsData = termsData;
        }
        emit(state.copyWith(isLoading: false, selctedVendorList: updatedList));
        showSuccessMessage(context);
        if (context.mounted) {
          Future.delayed(Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
    );
  }

  Future<List<FinalizeVendorForComparisonModel>> getSelectedVenodeForCompare(
    BuildContext context,
    int projectId,
    int materialRequisitionId,
    String uniquekey,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await finalizeVendorRepository.getSelectedVendorForCompare(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniquekey: uniquekey,
    );

    goRouter.pop();

    return result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return [];
      },
      (response) {
        final rawList = response['data'];

        if (rawList == null || rawList is! List) {
          return [];
        }

        final list = rawList.cast<FinalizeVendorForComparisonModel>();

        emit(
          state.copyWith(
            vendorFinalisationForComparison: list,
            isLoading: false,
          ),
        );

        return list;
      },
    );
  }

  Future compareVendor(
    BuildContext context,
    String exportType,
    int projectId,
    int materialRequisitionId,
    String uniqueKey,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await finalizeVendorRepository.compareFinalizedVendor(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniqueKey: uniqueKey,
      queryParams: {"ExportType": "VENDOR COMPARISON CHART"},
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
              ? "Finalize Vendor ${DateTime.now()}.pdf"
              : "Finalize Vendor ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
