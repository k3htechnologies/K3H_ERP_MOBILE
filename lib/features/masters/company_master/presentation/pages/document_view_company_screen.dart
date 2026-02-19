import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DocumentsViewCompanyScreen extends StatelessWidget {
  final CompanyModel companyModel;
  const DocumentsViewCompanyScreen({super.key, required this.companyModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Company",
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
              title: "PAN Card",
              value: companyModel.panCardURL,
              onTap: () {
                if (companyModel.panCardURL.isEmpty) {
                  showErrorMessage(context, "Image Error", "No Image Found");
                  return;
                }
                showFilePreviewDialog(
                  context,
                  companyModel.panCardURL.split(","),
                );
              },
            ),
            _buildContainer(
              title: "GST Certificate",
              value: companyModel.gstCertificateURL,
              onTap: () {
                if (companyModel.gstCertificateURL.isEmpty) {
                  showErrorMessage(context, "Image Error", "No Image Found");
                  return;
                }
                showFilePreviewDialog(
                  context,
                  companyModel.gstCertificateURL.split(","),
                );
              },
            ),
            _buildContainer(
              title: "CIN",
              value: companyModel.cinURL,
              onTap: () {
                if (companyModel.cinURL.isEmpty) {
                  showErrorMessage(context, "Image Error", "No Image Found");
                  return;
                }
                showFilePreviewDialog(context, companyModel.cinURL.split(","));
              },
            ),
            _buildContainer(
              title: "Company Letterhead Header",
              value: companyModel.companyLetterheadHeaderURL,
              onTap: () {
                if (companyModel.companyLetterheadHeaderURL.isEmpty) {
                  showErrorMessage(context, "Image Error", "No Image Found");
                  return;
                }
                showFilePreviewDialog(
                  context,
                  companyModel.companyLetterheadHeaderURL.split(","),
                );
              },
            ),
            _buildContainer(
              title: "Company Letterhead Footer",
              value: companyModel.companyLetterheadFooterURL,
              onTap: () {
                if (companyModel.companyLetterheadFooterURL.isEmpty) {
                  showErrorMessage(context, "Image Error", "No Image Found");
                  return;
                }
                showFilePreviewDialog(
                  context,
                  companyModel.companyLetterheadFooterURL.split(","),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // BUILD COMMON CONTAINER
  Widget _buildContainer({required String title,required String value ,required VoidCallback onTap}) {
    return Row(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyle.ts16M(color: AppColor.black)),
                CustomIconButton(
                  backgroundColor:value.isEmpty?AppColor.grey30: AppColor.lightBlue,
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color:value.isEmpty?AppColor.grey: AppColor.primary,
                  ),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
