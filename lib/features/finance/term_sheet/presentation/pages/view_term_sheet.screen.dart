import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class ViewTermSheetScreen extends StatefulWidget {
  const ViewTermSheetScreen({super.key});

  @override
  State<ViewTermSheetScreen> createState() => _ViewTermSheetScreenState();
}

class _ViewTermSheetScreenState extends State<ViewTermSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Term Sheet",
        authorization: AuthorizationModel(),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: []),
    );
  }
}
