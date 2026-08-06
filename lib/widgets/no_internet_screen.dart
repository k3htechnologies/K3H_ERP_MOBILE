import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: commonCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColor.error,
                size: 70,
              ),

              const SizedBox(height: 20),

              Text("Connection Lost", style: AppTextStyle.ts20SB()),

              const SizedBox(height: 18),

              Text(
                "It seems you are offline or the server is not responding.Please check your network and \ntry again.",
                textAlign: TextAlign.center,
                style: AppTextStyle.ts16R(color: AppColor.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
