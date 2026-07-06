import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ActivityTabScreen extends StatefulWidget {
  final RequestManagementState state;

  const ActivityTabScreen({super.key, required this.state});

  @override
  State<ActivityTabScreen> createState() => _ActivityTabScreenState();
}

class _ActivityTabScreenState extends State<ActivityTabScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: "Applicant Details",
            versions: widget.state.bookingApplicantModificationRequestModel,
            childBuilder: (item) {
              return _buildApplicantCard(item);
            },
          ),
          _buildSection(
            title: "Parking Details",
            versions: widget.state.parkingModificationRequestList,
            childBuilder: (item) {
              return _buildParkingCard(item);
            },
          ),
          _buildSection(
            title: "Flat Specification Remark",
            versions: widget.state.flatAlterationRequestsModel,
            childBuilder: (item) {
              return _buildFlatAlterationCard(item);
            },
          ),
          _buildSection(
            title: "Refund Details",
            versions: widget.state.refundRequestList,
            childBuilder: (item) {
              return _buildRefundCard(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List versions,
    required Widget Function(dynamic item) childBuilder,
  }) {
    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts16SB()),
        if (versions.isEmpty)
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: commonCardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No Data to show",
                  style: AppTextStyle.ts14R(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final item = versions[index];
              final version =
                  item.versionNumber.toString().trim().isEmpty
                      ? "${index + 1}"
                      : item.versionNumber.toString();

              return Container(
                margin: EdgeInsets.only(
                  bottom: index == versions.length - 1 ? 0 : 10,
                ),
                padding: EdgeInsets.all(12.0),
                decoration: commonCardDecoration(),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: AppColor.black,
                    collapsedIconColor: AppColor.black,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Version $version",
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                        horizontalSpacing(width: 10),
                        Expanded(
                          child: Divider(
                            color: AppColor.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          bottom: index == versions.length - 1 ? 0 : 10,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.lightGreyBackground,
                          border: Border.all(
                            width: 0.8,
                            color: AppColor.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: childBuilder(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildApplicantCard(
    BookingApplicantModificationRequestModel applicant,
  ) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Request Date",
                value:
                    applicant.createdDate == null
                        ? "-"
                        : formatDateTimeAsDDMMMYYYY(applicant.createdDate!),
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Applicant Type",
                value: applicant.applicantType,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Full Name",
                value: applicant.applicantName,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Contact No.",
                value: applicant.applicantMobileNumber,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "E-mail ID",
                value: applicant.applicantEmailId,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Aadhaar Card No.",
                value: applicant.aadharCardNumber,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "PAN Card No.",
                value: applicant.panNumber,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Approval Status",
                value: applicant.approvalStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParkingCard(ParkingModificationRequestModel parking) {
    final parkingData =
        parking.parkingData.isNotEmpty ? parking.parkingData.first : null;

    if (parkingData == null) {
      return const SizedBox();
    }

    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Parking Number",
                value: parkingData.parkingNumber,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Category",
                value: parkingData.parkingCategory,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Type",
                value: parkingData.parkingType,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Size",
                value: parkingData.parkingSubType,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Dimension",
                value: parkingData.parkingDimensions,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Approval Status",
                value: parkingData.approvalStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlatAlterationCard(FlatAlterationRequestsModel item) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Remark",
                value: item.flatAlterationRemark,
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Approval Status",
                value: item.approvalStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefundCard(BookingModel item) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Request Date",
                value: formatDateTimeAsDDMMMYYYY(item.createdDate),
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: buildColumnTitleValueNormal(
                title: "Refund Amount",
                value: "₹ ${item.totalAmountRefundedAgainstBooking}",
              ),
            ),
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColumnTitleValueNormal(
              title: "Approval Status",
              value: item.approvalStatus,
            ),
          ],
        ),
      ],
    );
  }
}
