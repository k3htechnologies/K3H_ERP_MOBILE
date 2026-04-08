import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class PayTrackScreen extends StatefulWidget {
  const PayTrackScreen({super.key});

  @override
  State<PayTrackScreen> createState() => _PayTrackScreenState();
}

class _PayTrackScreenState extends State<PayTrackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Pay Track',
        authorization: AuthorizationModel(),
      ),
      body: SizedBox(),
    );
  }
}
