import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewCompanyPartnerScreen extends StatelessWidget {
  final CompanyModel company;
  const ViewCompanyPartnerScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final partners = company.companyPartnerData;
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Company",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child:
            partners.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      "No Company Partner Added",
                      style: AppTextStyle.ts16M(color: AppColor.grey),
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final p = partners[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              NetworkImageWidget(
                                imageUrl: p.photoURL,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(55),
                              ),
                              horizontalSpacing(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.fullName,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    Text(
                                      p.mobileNumber,
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          verticalSpacing(height: 12),
                          Row(
                            children: [
                              _collum(
                                "Share %",
                                "${p.partnerPercentage.toStringAsFixed(1)}%",
                              ),
                              _collum("E-mail ID", p.emailId),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            children: [
                              _collum("DOB", _formatDate(p.dateOfBirth)),
                              _collum("Gender", p.gender),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            children: [
                              _collum("Aadhaar Card No.", p.aadharCardNumber),
                              _collum("PAN Card No.", p.panNumber),
                            ],
                          ),
                          verticalSpacing(),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Aadhaar Card",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (p.aadharCardURL.isEmpty) {
                                          return;
                                        }
                                        showFilePreviewDialog(
                                          context,
                                          p.aadharCardURL.split(","),
                                        );
                                      },
                                      child: Text(
                                        "View",
                                        style: AppTextStyle.ts14R(
                                          color:
                                              p.aadharCardURL.isEmpty
                                                  ? AppColor.grey
                                                  : AppColor.primary,
                                        ).copyWith(
                                          decoration:
                                              p.aadharCardURL.isEmpty
                                                  ? TextDecoration.none
                                                  : TextDecoration.underline,
                                          decorationColor: AppColor.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PAN Card",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (p.panCardURL.isEmpty) {
                                          return;
                                        }
                                        showFilePreviewDialog(
                                          context,
                                          p.panCardURL.split(","),
                                        );
                                      },
                                      child: Text(
                                        "View",
                                        style: AppTextStyle.ts14R(
                                          color:
                                              p.panCardURL.isEmpty
                                                  ? AppColor.grey
                                                  : AppColor.primary,
                                        ).copyWith(
                                          decoration:
                                              p.panCardURL.isEmpty
                                                  ? TextDecoration.none
                                                  : TextDecoration.underline,
                                          decorationColor: AppColor.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _collum(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts14M(color: AppColor.grey)),
          Text(value.isEmpty ? "-" : value, style: AppTextStyle.ts14R()),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
