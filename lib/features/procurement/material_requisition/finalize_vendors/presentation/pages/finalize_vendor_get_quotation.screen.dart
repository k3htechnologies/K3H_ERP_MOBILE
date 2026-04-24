import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorGetQuotationScreen extends StatefulWidget {
  final String systemgeneratedCode;
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  const FinalizeVendorGetQuotationScreen({
    super.key,
    required this.systemgeneratedCode,
    required this.projectId,
    required this.materialRequisitionId,
    required this.uniquekey,
  });

  @override
  State<FinalizeVendorGetQuotationScreen> createState() =>
      _FinalizeVendorGetQuotationScreenState();
}

class _FinalizeVendorGetQuotationScreenState
    extends State<FinalizeVendorGetQuotationScreen> {
  // CUBIT
  late FinalizeVendorCubit _finalizeVendorCubit;
  final Set<int> selectedVendorIndex = {};
  @override
  void initState() {
    super.initState();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _finalizeVendorCubit.getVendorForEnquiryList(
      context,
      widget.projectId,
      widget.materialRequisitionId,
      widget.uniquekey,
    );
  }

  void _toggleVendorSelection(int index) {
    setState(() {
      if (selectedVendorIndex.contains(index)) {
        selectedVendorIndex.remove(index);
      } else {
        selectedVendorIndex.add(index);
      }
    });
  }

  bool _isSelected(int index) {
    return selectedVendorIndex.contains(index);
  }

  void _onGetQuotationTap() async {
    final state = _finalizeVendorCubit.state;

    if (selectedVendorIndex.isEmpty) {
      showErrorMessage(
        context,
        "Validation",
        "Please select at least one vendor",
      );
      return;
    }

    final selectedVendorIds =
        selectedVendorIndex
            .map((index) => state.vendorSelectionForEnquiryList[index].vendorId)
            .toList();

    await _finalizeVendorCubit.addVendorForEnquiry(
      context: context,
      projectId: widget.projectId,
      materialRequisition: MaterialRequisitionModel(
        materialRequisitionId: widget.materialRequisitionId,
        uniquekey: widget.uniquekey,
        systemGeneratedCode: widget.systemgeneratedCode,
        projectId: widget.projectId,
        projectName: '',
        attachmentsURL: '',
        remarks: '',
        clientRegistrationId: 0,
        materialRequisitionStage: '',
        materialRequisitionStatus: '',
        finalVendor: '',
        isSplit: false,
        isCopy: false,
        isRequisitionAction: false,
        createdById: 0,
        createdBy: '',
        createdDate: DateTime.now(),
        modifiedById: 0,
        modifiedBy: '',
        modifiedDate: DateTime.now(),
        paidAmount: 0,
        totalPoAmount: 0,
        totalInoviceAmount: 0,
        totalInvoice: 0,
        purchaseOrderURL: '',
        isApprovalVendorFinalization: false,
        isApprovalInvoice: false,
        vendorFinalizationApprovalStatus: '',
        invoiceApprovalStatus: '',
        materialRequisitionDetailData: [],
      ),
      vendorIds: selectedVendorIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        final getQuotation = state.vendorSelectionForEnquiryList;
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.h,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.systemgeneratedCode,
                      style: AppTextStyle.ts16M(color: AppColor.primary),
                    ),
                  ),
                  horizontalSpacing(width: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _onGetQuotationTap,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: AppColor.green,
                          ),
                          child: Text(
                            "Get Quotation",
                            style: AppTextStyle.ts14M(color: AppColor.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: getQuotation.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final listOfVendorForQuotation = getQuotation[index];
                    return _buildVendorDetails(index, listOfVendorForQuotation);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVendorDetails(
    int index,
    RequisitionVendorModel listOfVendorForQuotation,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CustomCheckBox(
                isSelected: _isSelected(index),
                onChanged: (newValue) {
                  log("the value is :$newValue");
                  _toggleVendorSelection(index);
                },
              ),
              horizontalSpacing(width: 10.w),
              Expanded(
                child: _buildRow(
                  "Vendor Name",
                  listOfVendorForQuotation.vendorName,
                ),
              ),
            ],
          ),
          _buildRow("Company Name", listOfVendorForQuotation.companyName),
          _buildRow("Phone Number", listOfVendorForQuotation.mobileNumber),
          _buildRow("E-mail ID", listOfVendorForQuotation.emailId),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            ":   ",
            style: AppTextStyle.ts14R(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.ts14M(color: AppColor.black),
            ),
          ),
        ],
      ),
    );
  }
}
