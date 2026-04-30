import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_edit.screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/pages/finalize_vendor_get_quotation.screen.dart';

class FinalizeVendorMainscreen extends StatefulWidget {
  final String systemgeneratedCode;
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  const FinalizeVendorMainscreen({
    super.key,
    required this.systemgeneratedCode,
    required this.projectId,
    required this.materialRequisitionId,
    required this.uniquekey,
  });

  @override
  State<FinalizeVendorMainscreen> createState() =>
      _FinalizeVendorMainscreenState();
}

class _FinalizeVendorMainscreenState extends State<FinalizeVendorMainscreen> {
  @override
  void initState() {
    super.initState();

    final cubit = context.read<FinalizeVendorCubit>();

    if (cubit.state.viewType == FinalizeVendorViewType.finalizedList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cubit.getSelectedVenodeForCompare(
          context,
          widget.projectId,
          widget.materialRequisitionId,
          widget.uniquekey,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
      builder: (context, state) {
        switch (state.viewType) {
          case FinalizeVendorViewType.getQuotation:
            return FinalizeVendorGetQuotationScreen(
              systemgeneratedCode: widget.systemgeneratedCode,
              projectId: widget.projectId,
              materialRequisitionId: widget.materialRequisitionId,
              uniquekey: widget.uniquekey,
            );

          case FinalizeVendorViewType.finalizedList:
            return FinalizeVendorScreen(
              systemGeneratedCode: widget.systemgeneratedCode,
              materialRequisitionId: widget.materialRequisitionId,
              projectId: widget.projectId,
              uniquekey: widget.uniquekey,
            );

          case FinalizeVendorViewType.editVendor:
            return FinalizeVendorEditScreen(
              systemgeneratedCode: widget.systemgeneratedCode,
              vendor: state.selectedVendor,
              materials: state.materials,
              projectId: widget.projectId,
              uniquekey: widget.uniquekey,
              materialRequisitionId: widget.materialRequisitionId,
            );
        }
      },
    );
  }
}
