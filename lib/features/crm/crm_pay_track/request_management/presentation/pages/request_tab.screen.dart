// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RequestTabScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const RequestTabScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<RequestTabScreen> createState() => _RequestTabScreenState();
}

class _RequestTabScreenState extends State<RequestTabScreen> {
  late RequestManagementCubit _requestManagementCubit;
  late LoginCubit _loginCubit;
  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _loginCubit = context.read<LoginCubit>();
    _initiate();
  }

  void _initiate() async {
    await _requestManagementCubit.getBookingApplicantModificationRequestList(
      context,
      10,
      1,
      widget.bookingId,
      widget.projectId,
    );
    await _requestManagementCubit.getParkingModificationRequestList(
      context,
      10,
      1,
      widget.bookingId,
      widget.projectId,
    );
    await _requestManagementCubit.getFlatAlterationRequestList(
      context,
      10,
      1,
      widget.bookingId,
      widget.projectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApplicantDetailsWidget(context, state),
              _buildParkingDetailsWidget(context, state),
              _buildFlatSpecificationRemarkgDetailsWidget(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplicantDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final applicantList = List<BookingApplicantModificationRequestModel>.from(
      state.bookingApplicantModificationRequestModel,
    );

    final hasApplicantData = applicantList.isNotEmpty;
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Applicant Details", style: AppTextStyle.ts16SB()),
            horizontalSpacing(),
            CustomButton(
              leading: Icon(Icons.add, size: 18, color: AppColor.white),
              text: "Create Requests",
              onPressed: () async {
                final result = await goRouter.pushNamed(
                  AppRoutes.addApplicantDetailsRequests,
                  extra: {
                    "bookingId": widget.bookingId,
                    "projectId": widget.projectId,
                  },
                );

                if (context.mounted && result == true) {
                  await _requestManagementCubit
                      .getBookingApplicantModificationRequestList(
                        context,
                        10,
                        1,
                        widget.bookingId,
                        widget.projectId,
                      );
                }
              },
            ),
          ],
        ),
        if (hasApplicantData) ...{
          ListView.builder(
            itemCount: applicantList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final applicantData = applicantList[index];

              final applicant = applicantData;
              final isActionAlreadyPerformed = !applicant.isApproval;
              return Container(
                margin: EdgeInsets.only(
                  bottom: index == applicantList.length - 1 ? 0 : 10,
                ),
                padding: EdgeInsets.all(12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 6.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRowTitleValue(
                      title: "Applicant Type",
                      value: applicant.applicantType,
                    ),
                    buildRowTitleValue(
                      title: "Full Name",
                      value: applicant.applicantName,
                    ),
                    buildRowTitleValue(
                      title: "Contact Number",
                      value: applicant.applicantMobileNumber,
                    ),
                    buildRowTitleValue(
                      title: "E-mail ID",
                      value: applicant.applicantEmailId,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Aadhar Card No.",
                      value: applicant.aadharCardNumber,
                      customValueWidget: DocumentPreviewText(
                        text: applicant.aadharCardNumber,
                        fileUrl: applicant.aadharCardUrl,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "PAN Card No.",
                      value: applicant.panNumber,
                      customValueWidget: DocumentPreviewText(
                        text: applicant.panNumber,
                        fileUrl: applicant.panCardUrl,
                      ),
                    ),
                    ApproveRejectWidget(
                      isActionAlreadyPerformed: isActionAlreadyPerformed,
                      actionTitle:
                          applicant.isApproval ? "Approval" : "History",
                      onApprove: (remark) async {
                        final isSuccess = await _loginCubit
                            .updateModulesWorkflowApproval(
                              context: context,
                              moduleName:
                                  "BOOKING APPLICANT MODIFICATION APPROVAL",
                              id: widget.bookingId,
                              subId:
                                  applicant
                                      .bookingApplicantModificationRequestId,
                              projectId: widget.projectId,
                              isApproved: true,
                              remark: remark.trim(),
                            );

                        if (context.mounted && isSuccess) {
                          _requestManagementCubit
                              .getBookingApplicantModificationRequestList(
                                context,
                                10,
                                1,
                                widget.bookingId,
                                widget.projectId,
                              );
                        }
                      },
                      onReject: (remark) async {
                        final isSuccess = await _loginCubit
                            .updateModulesWorkflowApproval(
                              context: context,
                              moduleName:
                                  "BOOKING APPLICANT MODIFICATION APPROVAL",
                              id: widget.bookingId,
                              subId:
                                  applicant
                                      .bookingApplicantModificationRequestId,
                              projectId: widget.projectId,
                              isApproved: false,
                              remark: remark.trim(),
                            );

                        if (context.mounted && isSuccess) {
                          _requestManagementCubit
                              .getBookingApplicantModificationRequestList(
                                context,
                                10,
                                1,
                                widget.bookingId,
                                widget.projectId,
                              );
                        }
                      },
                      onThirdTap: () async {
                        final approvalLogHistoryList = await _loginCubit
                            .getApprovalLogHistory(
                              context: context,
                              id: widget.bookingId,
                              subId:
                                  applicant
                                      .bookingApplicantModificationRequestId,
                              projectId: widget.projectId,
                              moduleName:
                                  "BOOKING APPLICANT MODIFICATION APPROVAL",
                            );
                        if (context.mounted) {
                          goRouter.pushNamed(
                            AppRoutes.approvalLogHistory,
                            queryParameters: {
                              "title": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  "Applicant Details Log History",
                                ),
                              ),
                              "approvalList": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(
                                    approvalLogHistoryList
                                        .map((e) => e.toJson())
                                        .toList(),
                                  ),
                                ),
                              ),
                            },
                          );
                        }
                      },
                      popupTitle: "BOOKING APPLICANT MODIFICATION APPROVAL",
                    ),
                  ],
                ),
              );
            },
          ),
        } else ...{
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "No Booking Applicant details to show",
                    style: AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }

  Widget _buildParkingDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final hasParkingData =
        state.parkingModificationRequestList.isNotEmpty &&
        state.parkingModificationRequestList.first.parkingData.isNotEmpty;
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Parking Details", style: AppTextStyle.ts16SB()),
            CustomButton(
              leading: Icon(Icons.add, size: 18, color: AppColor.white),
              text: "Create Requests",
              onPressed: () {
                goRouter.pushNamed(AppRoutes.swapBookedParking);
              },
            ),
          ],
        ),
        if (hasParkingData) ...{
          SizedBox(
            height: 250.0,
            child: ListView.builder(
              itemCount: state.parkingModificationRequestList.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final parkingData = state.parkingModificationRequestList[index];

                if (parkingData.parkingData.isEmpty) {
                  return const SizedBox.shrink();
                }

                final parking = parkingData.parkingData.first;

                return Container(
                  margin: EdgeInsets.only(
                    bottom:
                        index == state.parkingModificationRequestList.length - 1
                            ? 0
                            : 10,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  decoration: commonCardDecoration(),
                  child: Column(
                    spacing: 6.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRowTitleValue(
                        title: "Parking Number",
                        value: parking.parkingNumber,
                      ),
                      buildRowTitleValue(
                        title: "Category",
                        value: parking.parkingCategory,
                      ),
                      buildRowTitleValue(
                        title: "Type",
                        value: parking.parkingType,
                      ),
                      buildRowTitleValue(
                        title: "Size",
                        value: parking.parkingSubType,
                      ),
                      buildRowTitleValue(
                        title: "Dimension",
                        value: parking.parkingDimensions,
                      ),
                      buildRowTitleValue(
                        title: "EV Charging",
                        value: parking.isEvChargingAvailable.toString(),
                      ),
                      buildRowTitleValue(
                        title: "Parking Status",
                        value: parking.parkingStatus,
                      ),
                      buildRowTitleValue(
                        title: "Building Number",
                        value: parking.buildingNumber,
                      ),
                      buildRowTitleValue(title: "Wing", value: parking.wing),
                      buildRowTitleValue(title: "Floor", value: parking.floor),
                      buildRowTitleValue(
                        title: "Approval Status",
                        value: parking.approvalStatus,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        } else ...{
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "No Parking details to show",
                    style: AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }

  Widget _buildFlatSpecificationRemarkgDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final hasFlatSpecificationRemark =
        state.flatAlterationRequestsModel.isNotEmpty;
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Flat Specification Remark",
                style: AppTextStyle.ts16SB(),
              ),
            ),
            CustomButton(
              leading: Icon(Icons.add, size: 18, color: AppColor.white),
              text: "Create Requests",
              onPressed: () {
                goRouter.pushNamed(AppRoutes.addFlatSpecificationRemarkScreen);
              },
            ),
          ],
        ),
        if (hasFlatSpecificationRemark) ...{
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.flatAlterationRequestsModel.length,
            itemBuilder: (context, index) {
              final remark = state.flatAlterationRequestsModel[index];

              return Container(
                margin: EdgeInsets.only(
                  bottom:
                      index == state.flatAlterationRequestsModel.length - 1
                          ? 0
                          : 10,
                ),
                padding: EdgeInsets.all(12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRowTitleValue(
                      title: "Remark",
                      value: remark.flatAlterationRemark,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Approval Status",
                      value: remark.approvalStatus,
                    ),
                  ],
                ),
              );
            },
          ),
        } else ...{
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "No Flat Specification Remark to show",
                    style: AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }
}
