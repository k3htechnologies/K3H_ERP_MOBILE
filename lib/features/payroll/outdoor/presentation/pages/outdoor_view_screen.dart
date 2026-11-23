import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class OutdoorViewScreen extends StatefulWidget {
  final OutdoorModel outdoorModel;
  const OutdoorViewScreen({super.key, required this.outdoorModel});

  @override
  State<OutdoorViewScreen> createState() => _OutdoorViewScreenState();
}

class _OutdoorViewScreenState extends State<OutdoorViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Outdoor",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Column(
            children: [
              SectionCard(
                title: 'Visit Details',
                titleTextColor: AppColor.purple700,
                headerBackgroundColor: AppColor.lightPurpleBg2,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "Outdoor Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          widget.outdoorModel.outDoorDate,
                        ),
                      ),
                      buildColumnTitleValue(
                        title: "Department",
                        value: widget.outdoorModel.departmentName,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accompanied By (${widget.outdoorModel.accompaniedByName.split(',').length})',
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                      ),
                      verticalSpacing(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children:
                              widget.outdoorModel.accompaniedByName
                                  .split(',')
                                  .map((name) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F7F7),
                                        borderRadius: BorderRadius.circular(5),
                                        border: const Border(
                                          left: BorderSide(
                                            color: Color(0xFF193D87),
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColor.lightGrey,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor:
                                                      AppColor.lightBlue,
                                                  child: Text(
                                                    name
                                                        .trim()[0]
                                                        .toUpperCase(),
                                                    style: AppTextStyle.ts12M(
                                                      color: AppColor.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  name.trim(),
                                                  style: AppTextStyle.ts12M(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              debugPrint("View Map");
                                            },
                                            child: Text(
                                              'View Map',
                                              style: AppTextStyle.ts12SB(
                                                color: AppColor.primary,
                                              ).copyWith(
                                                decorationColor:
                                                    AppColor.primary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      buildColumnTitleValue(
                        title: "Meeting Start Time",
                        value: DateFormat(
                          'hh:mm a',
                        ).format(widget.outdoorModel.outDoorTime),
                      ),
                      buildColumnTitleValue(
                        title: "Estimated End Time",
                        value: DateFormat(
                          'hh:mm a',
                        ).format(widget.outdoorModel.outDoorTime),
                      ),
                    ],
                  ),
                ],
              ),
              SectionCard(
                title: 'Company Details',
                titleTextColor: AppColor.orange,
                headerBackgroundColor: AppColor.lightOrangeBg.withValues(
                  alpha: 0.5,
                ),
                children: [
                  buildColumnTitleValue(
                    title: "Company Name",
                    value: widget.outdoorModel.companyName,
                    removeExpanded: true,
                  ),
                  buildColumnTitleValue(
                    title: "Company Address",
                    value: widget.outdoorModel.companyAddress,
                    removeExpanded: true,
                  ),
                  buildColumnTitleValue(
                    title: "Visiting Card",
                    value: widget.outdoorModel.visitingCardUrl,
                    removeExpanded: true,
                    customValueWidget: Row(
                      children: [
                        CustomButton.documentOutline(
                          isDisable:
                              widget.outdoorModel.visitingCardUrl.isEmpty,
                          onPressed: () {
                            if (widget
                                .outdoorModel
                                .visitingCardUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: 'Visiting Card',
                                context,
                                widget.outdoorModel.visitingCardUrl.split(","),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: widget.outdoorModel.punchIn != null,
                child: Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Attendance", style: AppTextStyle.ts16SB()),
                      verticalSpacing(),
                      if (widget.outdoorModel.punchIn != null)
                        _buildPunchInPunchOutCard(
                          isPunchIn: true,
                          time: widget.outdoorModel.punchIn!,
                          location: widget.outdoorModel.punchInAddress,
                        ),
                      if (widget.outdoorModel.punchOut != null)
                        _buildPunchInPunchOutCard(
                          isPunchIn: false,
                          time: widget.outdoorModel.punchOut!,
                          location: widget.outdoorModel.punchOutAddress,
                        ),
                    ],
                  ),
                ),
              ),
              SectionCard(
                title: 'Visit Purpose & Conclusion',
                children: [
                  buildColumnTitleValue(
                    title: "Purpose",
                    value: widget.outdoorModel.purpose,
                    removeExpanded: true,
                  ),
                  buildColumnTitleValue(
                    title: "Conclusion",
                    value: widget.outdoorModel.conclusion,
                    removeExpanded: true,
                  ),
                ],
              ),
              SectionCard(
                title: "Action Details",
                headerBackgroundColor: AppColor.grey.withValues(alpha: 0.2),
                titleTextColor: AppColor.black,
                border: Border.all(
                  color: AppColor.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Created By",
                        value: widget.outdoorModel.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(widget.outdoorModel.createdDate),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Modified By",
                        value: widget.outdoorModel.modifiedBy,
                      ),
                      buildColumnTitleValue(
                        title: "Modified Date",
                        value: formatDate(widget.outdoorModel.modifiedDate),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER CARD
  Widget _buildPunchInPunchOutCard({
    required bool isPunchIn,
    required DateTime time,
    required String location,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPunchIn ? AppColor.lightGreen : AppColor.lightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPunchIn ? AppColor.darkGreen : AppColor.primary,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: isPunchIn ? AppColor.darkGreen : AppColor.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              horizontalSpacing(),
              Text(
                isPunchIn ? "Punch In" : "Punch Out",
                style: AppTextStyle.ts14M(),
              ),
              Spacer(),
              Text(
                DateFormat('hh:mm a').format(time),
                style: AppTextStyle.ts14M(),
              ),
            ],
          ),
          verticalSpacing(),
          Text(location, style: AppTextStyle.ts14R()),
        ],
      ),
    );
  }
}
