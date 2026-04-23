import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorEditScreen extends StatelessWidget {
  final FinalizeVendorForComparisonModel vendor;
  final VoidCallback onBack;

  const FinalizeVendorEditScreen({
    super.key,
    required this.vendor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 20.0, bottom: 20.0),
      child: Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                vendor.systemGeneratedCode,
                style: AppTextStyle.ts16M(color: AppColor.primary),
              ),
            ],
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.h,
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(vendor.vendorName, style: AppTextStyle.ts16M()),
                          horizontalSpacing(width: 10.w),
                          Icon(
                            Icons.copy_rounded,
                            size: 16.0,
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                      verticalSpacing(height: 6.h),
                      Text(
                        vendor.companyName,
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
