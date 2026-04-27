import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorScreen extends StatefulWidget {
  final String systemGeneratedCode;
  final Function(FinalizeVendorForComparisonModel)? onVendorTap;
  final VoidCallback? onBack;
  final FinalizeVendorForComparisonModel? selectedVendor;
  const FinalizeVendorScreen({
    super.key,
    required this.systemGeneratedCode,
    this.onVendorTap,
    this.onBack,
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
  final Set<int> selectedVendorIndex = {};
  final ValueNotifier<MaterialRequisitionModel?> materialRequisitionOverview =
      ValueNotifier(null);
  bool isQuotationFetched = false;
  @override
  void initState() {
    super.initState();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _selectedProject = getProject();
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

      selectedVendorList.value = vendors;
    } else {
      selectedVendorList.value = [];
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        final vendorForFinalize = state.vendorFinalisationForComparison;
        return ValueListenableBuilder(
          valueListenable: selectedVendorList,
          builder: (context, value, child) {
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
                              _finalizeVendorCubit.changeView(
                                FinalizeVendorViewType.getQuotation,
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
                              style: AppTextStyle.ts12M(color: AppColor.green),
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 8.h),
                        SvgPicture.asset(
                          AppAssets.compareVendorIcon,
                          height: 24.h,
                          width: 24.w,
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
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// HEADER
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _toggleVendorSelection(index);
                                        },
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _isSelected(index)
                                                      ? AppColor.primary
                                                      : AppColor.primary
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                              width: 2,
                                            ),
                                            color:
                                                _isSelected(index)
                                                    ? AppColor.primary
                                                        .withValues(alpha: 0.2)
                                                    : Colors.transparent,
                                          ),
                                          child:
                                              _isSelected(index)
                                                  ? Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: AppColor.primary,
                                                  )
                                                  : null,
                                        ),
                                      ),
                                      horizontalSpacing(width: 10.w),
                                      GestureDetector(
                                        onTap: () {
                                          widget.onVendorTap?.call(vendor);
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

                              /// DETAILS
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
    final base = total - 4000; // 🔥 Replace with actual logic if API gives tax

    return (total - base).toInt();
  }

  int _calculateGrandTotal(FinalizeVendorForComparisonModel vendor) {
    final terms = vendor.materialRequisitionQuotationTermsData;

    if (terms.isEmpty) return 0;

    return terms.first.total.toInt();
  }
}
