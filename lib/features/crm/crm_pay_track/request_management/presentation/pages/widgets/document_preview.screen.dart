import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class DocumentPreviewText extends StatelessWidget {
  final String text;
  final String fileUrl;
  final String? title;

  const DocumentPreviewText({
    super.key,
    required this.text,
    required this.fileUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasFile) {
          showFilePreviewDialog(context, title: title, fileUrl.split(","));
        }
      },
      child: Text(
        text.isEmpty ? "-" : text,
        style: AppTextStyle.ts14M().copyWith(
          decoration: hasFile ? TextDecoration.underline : TextDecoration.none,
          color: hasFile ? AppColor.primary : AppColor.black,
          decorationColor: AppColor.primary,
        ),
      ),
    );
  }
}
