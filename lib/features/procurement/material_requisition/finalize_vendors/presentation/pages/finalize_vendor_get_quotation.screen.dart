import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class FinalizeVendorGetQuotationScreen extends StatefulWidget {
  final String vendor;
  const FinalizeVendorGetQuotationScreen({super.key, required this.vendor});

  @override
  State<FinalizeVendorGetQuotationScreen> createState() =>
      _FinalizeVendorGetQuotationScreenState();
}

class _FinalizeVendorGetQuotationScreenState
    extends State<FinalizeVendorGetQuotationScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 20.0, bottom: 20.0),
      child: Column(
        spacing: 10.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.vendor,
                style: AppTextStyle.ts16M(color: AppColor.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
