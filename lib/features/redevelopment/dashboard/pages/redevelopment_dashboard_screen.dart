import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class RedevelopmentDashboardScreen extends StatefulWidget {
  const RedevelopmentDashboardScreen({super.key});

  @override
  State<RedevelopmentDashboardScreen> createState() => _RedevelopmentDashboardScreenState();
}

class _RedevelopmentDashboardScreenState extends State<RedevelopmentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(screenTitle: "Redevelopment Dashboard", authorization: AuthorizationModel()),
      body: Center(child: Text("Jay Shree Ram!!!"),),
    );
  }
}
