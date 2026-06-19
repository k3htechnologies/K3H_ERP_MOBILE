// ── SHARED CARD WRAPPER ───────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

Widget buildCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: commonCardDecoration(),
    child: child,
  );
}

Widget buildSectionTitle(String title) {
  return Text(title, style: AppTextStyle.ts14SB(color: AppColor.black));
}
