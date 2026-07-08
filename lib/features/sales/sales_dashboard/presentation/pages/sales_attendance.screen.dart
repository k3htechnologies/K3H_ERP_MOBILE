import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class SalesAttendanceScreen extends StatefulWidget {
  final String title;
  const SalesAttendanceScreen({super.key, required this.title});

  @override
  State<SalesAttendanceScreen> createState() => _SalesAttendanceScreenState();
}

class _SalesAttendanceScreenState extends State<SalesAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.title,
        authorization: AuthorizationModel(),
      ),
    );
  }
}
