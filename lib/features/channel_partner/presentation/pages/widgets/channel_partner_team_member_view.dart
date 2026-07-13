import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Widget teamMemberTabView({
  required ValueNotifier<List<ChannelPartnerModel>> teamMembersNotifier,
  required ValueNotifier<bool> isLoadingNotifier,
  required ScrollController teamScrollController,
  required bool isTeamLoadingMore,
  required int totalTeamRecords,
}) {
  return ValueListenableBuilder<List<ChannelPartnerModel>>(
    valueListenable: teamMembersNotifier,
    builder: (context, teamMembers, child) {
      if (isLoadingNotifier.value && teamMembers.isEmpty) {
        return Center(child: loader());
      }

      if (teamMembers.isEmpty) {
        return Center(child: noDataWidget());
      }

      return ListView.separated(
        controller: teamScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        separatorBuilder: (context, index) => verticalSpacing(height: 12),
        itemCount:
            teamMembers.length +
            (isTeamLoadingMore || teamMembers.length >= totalTeamRecords
                ? 0
                : 1),
        itemBuilder: (context, index) {
          if (index == teamMembers.length) {
            return isTeamLoadingMore
                ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                : const SizedBox.shrink();
          }

          final member = teamMembers[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(member.name, style: AppTextStyle.ts16SB()),
                    ),
                    Text(
                      member.designation,
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        "Mobile Number",
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text(":", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      flex: 6,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomClickToContactText(
                          countryCode: member.mobileNumberCountryCode,
                          value: member.mobileNumber,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        "Email ID",
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text(":", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      flex: 6,
                      child:
                          member.emailId.isNotEmpty
                              ? Align(
                                alignment: Alignment.centerRight,
                                child: CustomClickToContactText(
                                  value: member.emailId,
                                  type: ContactType.email,
                                ),
                              )
                              : Text(
                                "-",
                                style: AppTextStyle.ts12M(color: Colors.grey),
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
