import 'package:flutter/material.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

class NotAuthorizedScreen extends StatelessWidget {
  const NotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                AppAssets.notAuthorized,
                height: 400,
                width: 400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}