import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget channelPartnerDocumentView({
  required BuildContext context,
  required ChannelPartnerModel channelPartner,
}) {
  final List<Map<String, String>> documents = [
    {
      "title": "PAN Card",
      "number": channelPartner.panNumber,
      "url": channelPartner.panCardUrl,
    },
    {
      "title": "Aadhaar Card",
      "number": channelPartner.aadhaarCardNumber,
      "url": channelPartner.aadhaarCardUrl,
    },
    {
      "title": "GST Certificate",
      "number": channelPartner.gstNumber,
      "url": channelPartner.gstCertificateUrl,
    },
  ];

  final validDocuments =
      documents.where((doc) => (doc["url"] ?? "").isNotEmpty).toList();

  if (validDocuments.isEmpty) {
    return SizedBox(
      height: 180,
      child: Center(child: noDataWidget(message: "No Data Found.")),
    );
  }
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text("Verification Documents", style: AppTextStyle.ts14M()),
        Expanded(
          child: ListView.separated(
            itemCount: validDocuments.length,
            separatorBuilder: (context, index) => verticalSpacing(height: 12),
            itemBuilder: (context, index) {
              final doc = validDocuments[index];
              return Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Container(
                      height: 32.h,
                      width: 32.w,
                      decoration: BoxDecoration(
                        color: AppColor.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.idCard,
                        color: AppColor.primary,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4.h,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                doc['title']!,
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                              if (doc['number']?.isNotEmpty == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.lightGreenBg.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Verified",
                                    style: AppTextStyle.ts12M(
                                      color: AppColor.darkGreen,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          buildDocumentRow(
                            context: context,
                            docNumber:
                                doc['number']?.isNotEmpty == true
                                    ? doc['number']!
                                    : "-",
                            url: doc['url'] ?? "-",
                            title: doc['title']!,
                            iconWithoutBg: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
