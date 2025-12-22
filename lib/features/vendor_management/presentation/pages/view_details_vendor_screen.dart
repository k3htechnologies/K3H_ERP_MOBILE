import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class ViewDetailsVendorScreen extends StatefulWidget {
  final VendorModel vendor;
  const ViewDetailsVendorScreen({super.key, required this.vendor});

  @override
  State<ViewDetailsVendorScreen> createState() =>
      _ViewDetailsVendorScreenState();
}

class _ViewDetailsVendorScreenState extends State<ViewDetailsVendorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Vendor Management',
        authorization: AuthorizationModel(),
      ),
    );
  }
}
