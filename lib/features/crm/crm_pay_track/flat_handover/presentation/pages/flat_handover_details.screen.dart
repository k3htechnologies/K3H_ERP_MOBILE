import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FlatHandoverDetailsScreen extends StatefulWidget {
  final PayTrackBookingFilesModel? flatHandoverDocument;
  final BookingModel? bookingModel;
  final bool isApprove;
  const FlatHandoverDetailsScreen({
    super.key,
    this.flatHandoverDocument,
    required this.bookingModel,
    required this.isApprove,
  });

  @override
  State<FlatHandoverDetailsScreen> createState() =>
      _FlatHandoverDetailsScreenState();
}

class _FlatHandoverDetailsScreenState extends State<FlatHandoverDetailsScreen> {
  late UtilsCubit _utilsCubit;
  late ProjectModel _selectedProject;
  late TextEditingController _approvedRemarkC;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _utilsCubit = context.read<UtilsCubit>();
    _selectedProject = getProject();
    _approvedRemarkC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _approvedRemarkC.dispose();
  }

  Future<void> _verifyAndSubmitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isSuccess = await _utilsCubit.updateModulesWorkflowApproval(
      context: context,
      moduleName: "FLAT HANDOVER APPROVAL",
      id: widget.bookingModel!.bookingId,
      projectId: _selectedProject.projectId,
      subId: widget.flatHandoverDocument!.payTrackBookingFilesId,
      isApproved: widget.isApprove,
      remark: _approvedRemarkC.text.trim(),
    );

    if (mounted && isSuccess) {
      goRouter.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            "Approve Flat Handover : ${widget.flatHandoverDocument!.fileName}",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unit Details",
                      style: AppTextStyle.ts14SB(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    buildRowTitleValue(
                      title: "Project Name",
                      value: _selectedProject.projectName,
                      singleLine: false,
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Wing",
                            value: widget.bookingModel?.wing ?? "-",
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Floor",
                            value: widget.bookingModel?.floor ?? "-",
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Unit Number",
                            value: widget.bookingModel?.flat ?? "-",
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Configuration",
                            value:
                                widget.bookingModel?.flatConfiguration ?? "-",
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "RERA Carpet Area (SqFt)",
                            value:
                                widget.bookingModel?.reraCarpetAreaSqFt
                                    .toString() ??
                                "-",
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Agreement Value (With TDS) (₹)",
                            value:
                                widget.bookingModel?.agreementValue
                                    .toIndianCurrency() ??
                                "-",
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Number Of Parking",
                            value:
                                widget.bookingModel?.numberOfParking
                                    .toString() ??
                                "-",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Applicant & Co-Applicant Details",
                      style: AppTextStyle.ts14SB(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          widget.bookingModel!.bookingApplicantData.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            thickness: 0.2,
                            color: AppColor.greyTitleAndValueColor,
                          ),
                      itemBuilder: (context, index) {
                        final applicant =
                            widget.bookingModel!.bookingApplicantData[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            verticalSpacing(height: 6.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColor.primary,
                                  child:
                                      applicant.photoURL.isNotEmpty
                                          ? ClipOval(
                                            child: NetworkImageWidget(
                                              imageUrl: applicant.photoURL,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Text(
                                            applicant.applicantName.isNotEmpty
                                                ? applicant.applicantName[0]
                                                    .toUpperCase()
                                                : "U",
                                            style: AppTextStyle.ts24B(
                                              color: AppColor.white,
                                            ),
                                          ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        applicant.applicantName,
                                        style: AppTextStyle.ts16SB(),
                                      ),
                                      verticalSpacing(height: 6),
                                      CustomClickToContactText(
                                        countryCode:
                                            applicant
                                                .applicantMobileNumberCountryCode,
                                        value: applicant.applicantMobileNumber,
                                        type: ContactType.phone,
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.lightBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    applicant.applicantType,
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(height: 6.0),
                          ],
                        );
                      },
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 35,
                    //       backgroundColor: AppColor.primary,
                    //       child:
                    //           widget
                    //                   .bookingModel!
                    //                   .bookingApplicantData
                    //                   .first
                    //                   .photoURL
                    //                   .isNotEmpty
                    //               ? ClipOval(
                    //                 child: NetworkImageWidget(
                    //                   imageUrl:
                    //                       widget
                    //                           .bookingModel!
                    //                           .bookingApplicantData
                    //                           .first
                    //                           .photoURL,
                    //                   fit: BoxFit.fill,
                    //                   width: 70,
                    //                   height: 70,
                    //                 ),
                    //               )
                    //               : Text(
                    //                 widget
                    //                         .bookingModel!
                    //                         .bookingApplicantData
                    //                         .first
                    //                         .applicantName
                    //                         .isNotEmpty
                    //                     ? widget
                    //                         .bookingModel!
                    //                         .bookingApplicantData
                    //                         .first
                    //                         .applicantName[0]
                    //                         .toUpperCase()
                    //                     : 'U',
                    //                 style: AppTextStyle.ts24B(
                    //                   color: AppColor.white,
                    //                 ),
                    //               ),
                    //     ),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           widget
                    //               .bookingModel!
                    //               .bookingApplicantData
                    //               .first
                    //               .applicantName,
                    //           style: AppTextStyle.ts16SB(),
                    //           maxLines: 2,
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //         verticalSpacing(height: 6),
                    //         Text(
                    //           widget
                    //               .bookingModel!
                    //               .bookingApplicantData
                    //               .first
                    //               .applicantMobileNumber,
                    //           style: AppTextStyle.ts14M(color: AppColor.grey),
                    //         ),
                    //       ],
                    //     ),
                    //     Container(
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 10.0,
                    //         vertical: 6.0,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: AppColor.lightBlue,
                    //         borderRadius: BorderRadius.circular(6.0),
                    //       ),
                    //       child: Text(
                    //         widget
                    //             .bookingModel!
                    //             .bookingApplicantData
                    //             .first
                    //             .applicantType,
                    //         style: AppTextStyle.ts12R(color: AppColor.primary),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Container(
                height: 350,
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Parking Details", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
                    Expanded(
                      child:
                          widget.bookingModel!.parkingData.isEmpty
                              ? Center(
                                child: noDataWidget(
                                  message: 'No Parking Data Found',
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                shrinkWrap: true,
                                itemCount:
                                    widget.bookingModel!.parkingData.length,
                                itemBuilder: (_, index) {
                                  final parking =
                                      widget.bookingModel!.parkingData[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColor.primary,
                                        width: .3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 10,
                                      children: [
                                        Text(
                                          "Parking ${index + 1}",
                                          style: AppTextStyle.ts14SB(
                                            color: AppColor
                                                .greyTitleAndValueColor
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        Row(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Parking Number",
                                              value: parking.parkingNumber,
                                            ),
                                            buildColumnTitleValue(
                                              title: "Building",
                                              value: parking.buildingNumber,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Wing",
                                              value: parking.wing,
                                            ),
                                            buildColumnTitleValue(
                                              title: "Floor",
                                              value: parking.floor,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Category",
                                              value: parking.parkingCategory,
                                            ),
                                            buildColumnTitleValue(
                                              title: "Type",
                                              value: parking.parkingType,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Size",
                                              value: parking.parkingSubType,
                                            ),
                                            buildColumnTitleValue(
                                              title: "Dimensions",
                                              value: parking.parkingDimensions,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "EV Charging",
                                              value:
                                                  parking.isEVChargingAvailable
                                                      ? "Yes"
                                                      : "No",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: CustomTextField(
                  textController: _approvedRemarkC,
                  hint: "Enter Remark",
                  title: "Remark",
                  minLines: 3,
                  maxLines: 10,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Remark is required";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: widget.isApprove ? "Approve" : "Reject",
            onPressed: _verifyAndSubmitForm,
          ),
        ),
      ),
    );
  }
}
