import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DocumentsViewVendorScreen extends StatelessWidget {
  final VendorModel vendorModel;
  const DocumentsViewVendorScreen({super.key, required this.vendorModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Vendor Management",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Documents",
              style: AppTextStyle.ts16SB(color: AppColor.black),
            ),
            verticalSpacing(),
            _buildContainer(
              title: "Aadhaar Card",
              onTap: () {
                if (vendorModel.aadharCardUrl.isEmpty) {
                  showErrorMessage(
                    context,
                    "Image Error",
                    "Document Not Available",
                  );
                  return;
                }
                showFilePreviewDialog(
                  context,
                  vendorModel.aadharCardUrl.split(","),
                );
              },
            ),
            _buildContainer(
              title: "PAN Card",
              onTap: () {
                if (vendorModel.panCardUrl.isEmpty) {
                  showErrorMessage(
                    context,
                    "Image Error",
                    "Document Not Available",
                  );
                  return;
                }
                showFilePreviewDialog(
                  context,
                  vendorModel.panCardUrl.split(","),
                );
              },
            ),
            _buildContainer(
              title: "GST Certificate",
              onTap: () {
                if (vendorModel.gstCertificateUrl.isEmpty) {
                  showErrorMessage(
                    context,
                    "Image Error",
                    "Document Not Available",
                  );
                  return;
                }
                showFilePreviewDialog(
                  context,
                  vendorModel.gstCertificateUrl.split(","),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.0),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: AppColor.black.withValues(alpha: 0.0),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
                border: Border(bottom: BorderSide(color: AppColor.lightBlue)),
              ),
              child: Text(
                title,
                style: AppTextStyle.ts16M(color: AppColor.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
