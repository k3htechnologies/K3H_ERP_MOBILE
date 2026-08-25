import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyPartners extends StatefulWidget {
  const CompanyPartners({super.key});

  @override
  State<CompanyPartners> createState() => _CompanyPartnersState();
}

class _CompanyPartnersState extends State<CompanyPartners> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
      builder: (context, state) {
        if ((state.isLoading ?? false) || state.companyOverview == null) {
          return loader();
        }
        if (state.companyOverview != null &&
            state.companyOverview!.companyPartnerData.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Partner Data Available"),
          );
        }
        final partners = state.companyOverview?.companyPartnerData ?? [];
        return ListView.builder(
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
                              style: AppTextStyle.ts16M(color: AppColor.grey),
                            ),

                            CustomClickToContactText(
                              countryCode: "+91",
                              value: p.mobileNumber,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 12),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Share %",
                        value: "${p.partnerPercentage.toStringAsFixed(1)}%",
                      ),
                      buildColumnTitleValue(
                        title: "E-mail ID",
                        value: p.emailId,
                        customValueWidget: CustomClickToContactText(
                          value: p.emailId,
                          type: ContactType.email,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "DOB",
                        value: formatDateTimeAsDDMMMYYYY(p.dateOfBirth),
                      ),
                      buildColumnTitleValue(title: "Gender", value: p.gender),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "PAN Card Number",
                        value: p.panNumber.isEmpty ? "-" : p.panNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,

                          title: "PAN Card",
                          context: context,
                          docNumber: p.panNumber.isEmpty ? "-" : p.panNumber,
                          url: p.panCardURL,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "Aadhar Number",
                        value:
                            p.aadharCardNumber.isEmpty
                                ? "-"
                                : p.aadharCardNumber,
                        customValueWidget: buildDocumentRow(
                          iconWithoutBg: true,
                          title: "Aadhar Number",
                          context: context,
                          docNumber:
                              p.aadharCardURL.isEmpty
                                  ? "-"
                                  : p.aadharCardNumber,
                          url: p.aadharCardURL,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
