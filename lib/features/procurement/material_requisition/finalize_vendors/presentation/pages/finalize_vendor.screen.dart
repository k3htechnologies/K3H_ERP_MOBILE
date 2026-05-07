import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorScreen extends StatefulWidget {
  final String systemGeneratedCode;
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  final FinalizeVendorForComparisonModel? selectedVendor;
  const FinalizeVendorScreen({
    super.key,
    required this.systemGeneratedCode,
    required this.materialRequisitionId,
    required this.projectId,
    required this.uniquekey,
    this.selectedVendor,
  });

  @override
  State<FinalizeVendorScreen> createState() => _FinalizeVendorScreenState();
}

class _FinalizeVendorScreenState extends State<FinalizeVendorScreen> {
  // CUBIT
  late FinalizeVendorCubit _finalizeVendorCubit;
  late ProjectModel _selectedProject;

  final ValueNotifier<List<dynamic>> selectedVendorList = ValueNotifier([]);
  final ValueNotifier<MaterialRequisitionModel?> materialRequisitionOverview =
      ValueNotifier(null);
  bool isQuotationFetched = false;
  @override
  void initState() {
    super.initState();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _selectedProject = getProject();
    _loadMaterialData();
  }

  Future<void> initOverview() async {
    if (materialRequisitionOverview.value?.uniquekey != null &&
        materialRequisitionOverview.value!.uniquekey.isNotEmpty) {
      final vendors = await _finalizeVendorCubit.getSelectedVenodeForCompare(
        context,
        _selectedProject.projectId,
        materialRequisitionOverview.value?.materialRequisitionId ?? 0,
        materialRequisitionOverview.value?.uniquekey ?? "",
      );
      final finalVendorId = materialRequisitionOverview.value?.finalVendor;

      for (var v in vendors) {
        v.isSelected = v.vendorId.toString() == finalVendorId;
      }
      selectedVendorList.value = vendors;
    } else {
      selectedVendorList.value = [];
    }
  }

  Future<void> _loadMaterialData() async {
    final materialCubit = context.read<MaterialRequisitionCubit>();

    await materialCubit.getMaterialRequisitionDetailsById(
      context,
      1,
      widget.projectId,
      widget.materialRequisitionId,
    );

    materialRequisitionOverview.value =
        materialCubit.state.materialRequisitionOverview;
    await initOverview();
  }

  void _onFinalizeVendorTap() async {
    await _finalizeVendorCubit.addFinalizedVendor(
      context: context,
      projectId: _selectedProject.projectId,
      materialRequisition: MaterialRequisitionModel(
        materialRequisitionId: widget.materialRequisitionId,
        uniquekey: widget.uniquekey,
        systemGeneratedCode: widget.systemGeneratedCode,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        final vendorForFinalize = state.vendorFinalisationForComparison;
        return ValueListenableBuilder(
          valueListenable: materialRequisitionOverview,
          builder: (context, overview, child) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.systemGeneratedCode,
                          style: AppTextStyle.ts16M(color: AppColor.primary),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final systemGeneratedCode = Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  widget.systemGeneratedCode,
                                ),
                              );
                              final materialRequisitionId = Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  widget.materialRequisitionId.toString(),
                                ),
                              );
                              final projectID = Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  widget.projectId.toString(),
                                ),
                              );
                              final uniquekey = Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  widget.uniquekey.toString(),
                                ),
                              );

                              goRouter.pushNamed(
                                AppRoutes.finalizeVendorGetQuotation,
                                queryParameters: {
                                  'systemGeneratedCode': systemGeneratedCode,
                                  'materialRequisitionId':
                                      materialRequisitionId,
                                  'projectId': projectID,
                                  'uniquekey': uniquekey,
                                },
                              );
                            },
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
                                style: AppTextStyle.ts12M(
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 8.h),
                        Expanded(
                          child: GestureDetector(
                            onTap: _onFinalizeVendorTap,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: AppColor.green.withValues(alpha: 0.14),
                              ),
                              child: Text(
                                "Finalize Vendor",
                                style: AppTextStyle.ts12M(
                                  color: AppColor.green,
                                ),
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 8.h),
                        GestureDetector(
                          onTap: () {
                            _finalizeVendorCubit.compareVendor(
                              context,
                              "exportType",
                              _selectedProject.projectId,
                              widget.materialRequisitionId,
                              widget.uniquekey,
                            );
                          },
                          child: SvgPicture.asset(
                            AppAssets.compareVendorIcon,
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                      ],
                    ),

                    verticalSpacing(height: 10.h),
                    ListView.builder(
                      itemCount: vendorForFinalize.length,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final vendor = vendorForFinalize[index];
                        final vedorQuotationOfSelecetdVendor =
                            vendor
                                    .materialRequisitionQuotationTermsData
                                    .isNotEmpty
                                ? vendor
                                    .materialRequisitionQuotationTermsData
                                    .first
                                : null;
                        final isFinalized =
                            overview?.finalVendor.trim().toLowerCase() ==
                            vendor.vendorName.trim().toLowerCase();

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomCheckBox(
                                        isSelected:
                                            isFinalized || vendor.isSelected,
                                        onChanged: (value) {
                                          if (isFinalized) return;
                                          _finalizeVendorCubit
                                              .toggleVendorSelection(
                                                vendor.vendorId,
                                              );
                                        },
                                      ),
                                      horizontalSpacing(width: 10.w),
                                      GestureDetector(
                                        onTap: () async {
                                          final materials =
                                              materialRequisitionOverview
                                                  .value
                                                  ?.materialRequisitionDetailData ??
                                              [];

                                          final updatedVendors =
                                              await _finalizeVendorCubit
                                                  .getSelectedVenodeForCompare(
                                                    context,
                                                    _selectedProject.projectId,
                                                    widget
                                                        .materialRequisitionId,
                                                    widget.uniquekey,
                                                  );

                                          final selectedVendor = updatedVendors
                                              .firstWhere(
                                                (v) =>
                                                    v.vendorId ==
                                                    vendor.vendorId,
                                                orElse: () => vendor,
                                              );

                                          await goRouter.pushNamed(
                                            AppRoutes.finalizeEditVendor,
                                            extra: {
                                              "vendor": selectedVendor,
                                              "materials": materials,
                                              "systemGeneratedCode":
                                                  widget.systemGeneratedCode,
                                              "projectId": widget.projectId,
                                              "materialRequisitionId":
                                                  widget.materialRequisitionId,
                                              "uniquekey": widget.uniquekey,
                                            },
                                          );
                                        },
                                        child: Text(
                                          vendor.vendorName,
                                          style: AppTextStyle.ts16M(
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomIconButton(
                                    onPressed: () async {
                                      copy(
                                        context: context,
                                        text: widget.systemGeneratedCode,
                                      );
                                    },
                                    backgroundColor: AppColor.white,

                                    icon: Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 12),
                              _buildRow("Company Name", vendor.companyName),
                              _buildRow(
                                "Base Amount",
                                "₹${vedorQuotationOfSelecetdVendor?.total.toInt() ?? 0}",
                              ),
                              _buildRow(
                                "Total Tax",
                                "₹${_calculateTax(vendor)}",
                                valueColor: Colors.orange,
                              ),

                              _buildRow(
                                "Grand Total",
                                "₹${_calculateGrandTotal(vendor)}",
                                valueColor: AppColor.primary,
                              ),

                              _buildRow(
                                "Est. Delivery",
                                "${vedorQuotationOfSelecetdVendor?.expectedDeliveryInDays ?? 0} Days",
                                valueColor: Colors.green,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(String title, String value, {Color? valueColor}) {
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
              style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTax(FinalizeVendorForComparisonModel vendor) {
    final terms = vendor.materialRequisitionQuotationTermsData;

    if (terms.isEmpty) return 0;

    final total = terms.first.total;
    final base = total - 4000;

    return (total - base).toInt();
  }

  int _calculateGrandTotal(FinalizeVendorForComparisonModel vendor) {
    final terms = vendor.materialRequisitionQuotationTermsData;

    if (terms.isEmpty) return 0;

    return terms.first.total.toInt();
  }
}
