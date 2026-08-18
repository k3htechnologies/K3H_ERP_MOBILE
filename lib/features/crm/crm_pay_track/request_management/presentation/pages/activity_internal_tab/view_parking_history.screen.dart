import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewParkingHistoryScreen extends StatefulWidget {
  final ParkingModificationRequestModel parkingDetail;
  const ViewParkingHistoryScreen({super.key, required this.parkingDetail});

  @override
  State<ViewParkingHistoryScreen> createState() =>
      _ViewParkingHistoryScreenState();
}

class _ViewParkingHistoryScreenState extends State<ViewParkingHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            "Modified Requests > Activity > Version ${widget.parkingDetail.versionNumber}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.parkingDetail.parkingData.length,
          separatorBuilder: (_, __) => verticalSpacing(),
          itemBuilder: (context, index) {
            final parking = widget.parkingDetail.parkingData[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.lightGreyBackground,
                border: Border.all(color: AppColor.grey50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Proof Of Document",
                        value: widget.parkingDetail.proofOfDocumentUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget
                                .parkingDetail
                                .proofOfDocumentUrl
                                .isNotEmpty) {
                              showFilePreviewDialog(
                                title: "Proof Of Document",
                                context,
                                widget.parkingDetail.proofOfDocumentUrl.split(
                                  ",",
                                ),
                              );
                            }
                          },
                          isDisable:
                              widget.parkingDetail.proofOfDocumentUrl.isEmpty,
                        ),
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Parking Number",
                        value: parking.parkingNumber,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Category",
                        value: parking.parkingCategory,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Type",
                        value: parking.parkingType,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Size",
                        value: parking.parkingSubType,
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Dimensions",
                        value: parking.parkingDimensions,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "EV Charging",
                        value: parking.isEvChargingAvailable ? "Yes" : "No",
                      ),
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Created By",
                        value: parking.createdBy,
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  buildRowWrapper(
                    child: buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDateTimeAsDDMMMYYYY(parking.createdDate),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
