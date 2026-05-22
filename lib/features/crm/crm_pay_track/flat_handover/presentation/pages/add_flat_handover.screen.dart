import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';

class AddFlatHandoverScreen extends StatefulWidget {
  const AddFlatHandoverScreen({super.key});

  @override
  State<AddFlatHandoverScreen> createState() => _AddFlatHandoverScreenState();
}

class _AddFlatHandoverScreenState extends State<AddFlatHandoverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Hnadover Documnets",
        authorization: AuthorizationModel(),
      ),
    );
  }
}
