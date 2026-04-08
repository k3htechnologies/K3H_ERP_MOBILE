import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class FinalizeVendorScreen extends StatefulWidget {
  const FinalizeVendorScreen({super.key});

  @override
  State<FinalizeVendorScreen> createState() => _FinalizeVendorScreenState();
}

class _FinalizeVendorScreenState extends State<FinalizeVendorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Finalize Vendor",
        authorization: AuthorizationModel(),
      ),
      body: Center(
        child: Text(
          "FINALIZE VENDOR SCREEN TAB",
          style: AppTextStyle.ts14R(color: AppColor.primary),
        ),
      ),
    );
  }
}
