import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class FinalizeVendorEditScreen extends StatefulWidget {
  final String systemgeneratedCode;

  const FinalizeVendorEditScreen({
    super.key,
    required this.systemgeneratedCode,
  });

  @override
  State<FinalizeVendorEditScreen> createState() =>
      _FinalizeVendorEditScreenState();
}

class _FinalizeVendorEditScreenState extends State<FinalizeVendorEditScreen> {
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
                widget.systemgeneratedCode,
                style: AppTextStyle.ts16M(color: AppColor.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
