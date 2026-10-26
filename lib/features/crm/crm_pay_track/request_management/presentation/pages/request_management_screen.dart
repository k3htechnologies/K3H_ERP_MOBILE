// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/activity_tab.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/refund_payment_ledger.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_tab.screen.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/widgets/applicant_card.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RequestManagementScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? approvalStatus;
  const RequestManagementScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.approvalStatus,
  });

  @override
  State<RequestManagementScreen> createState() =>
      _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RequestManagementCubit _requestManagementCubit;

  bool _showRefundTab = false;
  late AuthorizationModel _modifiedRequestsAuthorization;

  @override
  void initState() {
    super.initState();
    _modifiedRequestsAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.modificationRequest] ??
        AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    await _requestManagementCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );

    final show = _requestManagementCubit.state.showRefundPaymentLedgerTab;

    if (_showRefundTab != show) {
      _showRefundTab = show;
      _recreateController();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _recreateController() {
    final currentIndex = _tabController.index;

    _tabController.dispose();

    _tabController = TabController(
      length: _showRefundTab ? 4 : 3,
      vsync: this,
      initialIndex: currentIndex.clamp(0, (_showRefundTab ? 4 : 3) - 1),
    );

    _tabController.addListener(_handleTabChange);
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _requestManagementCubit.getBookingById(
            context,
            1,
            widget.projectId,
            widget.bookingId,
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestManagementCubit, RequestManagementState>(
      listenWhen:
          (previous, current) =>
              previous.showRefundPaymentLedgerTab !=
                  current.showRefundPaymentLedgerTab ||
              previous.showRefundPaymentSuccessMessage !=
                  current.showRefundPaymentSuccessMessage,
      listener: (context, state) {
        if (state.showRefundPaymentSuccessMessage) {
          showSuccessMessage(
            context,
            subTitle: "Refund Amount Initiated successfully",
          );

          context
              .read<RequestManagementCubit>()
              .clearRefundPaymentSuccessMessage();
        }
      },
      child: BlocBuilder<RequestManagementCubit, RequestManagementState>(
        builder: (context, state) {
          final tabs = ['Summary', 'Requests', 'Activity'];

          if (_showRefundTab) {
            tabs.add('Refund Payment Ledger');
          }

          final pages = [
            _buildSummaryTab(context),
            RequestTabScreen(
              projectId: widget.projectId,
              bookingId: widget.bookingId,
              approvalStatus: widget.approvalStatus,
            ),
            ActivityTabScreen(
              bookingId: widget.bookingId,
              projectId: widget.projectId,
            ),
          ];

          if (_showRefundTab) {
            pages.add(RefundPaymentLedgerScreen(booking: state.bookingData!));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              ChipStyleTabBar(controller: _tabController, tabs: tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.bookingData == null) {
          return Center(child: CircularProgressIndicator());
        }
        final bookingData = state.bookingData;
        if (bookingData == null || bookingData.bookingApplicantData.isEmpty) {
          return const Center(child: Text("No Applicant Data Found"));
        }
        final booking = bookingData;
        final isBookingCancelled = booking.cancelRemark.trim().isNotEmpty;

        final isRefundStatus =
            booking.approvalStatus.trim().toUpperCase() == "REFUND";

        final isCancelApproved =
            (booking.cancelBookingApprovalStatus.trim().toUpperCase() ==
                "APPROVED");

        final canMakePayment =
            booking.totalAmountRefundedAgainstBooking >
            booking.refundedAmountOnTillDate;

        final noAgreementValue =
            state.bookingData?.agreementValue == 0 &&
            state.bookingData?.tenantId != 0;
        Widget? actionButton;
        if (!isBookingCancelled &&
            !isRefundStatus &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Cancel Booking",
            backgroundColor: AppColor.missingInformationRed.withValues(
              alpha: 0.3,
            ),
            textColor: AppColor.missingInformationRed,
            onPressed: () async {
              final result = await goRouter.pushNamed<bool>(
                AppRoutes.cancelBookingScreen,
                extra: booking,
              );

              if (result == true && context.mounted) {
                await context.read<PayTrackCubit>().getPayTrackList(
                  context,
                  1,
                  booking.projectId,
                );

                if (context.mounted) {
                  await context.read<RequestManagementCubit>().getBookingById(
                    context,
                    1,
                    booking.projectId,
                    booking.bookingId,
                  );
                }
              }
            },
          );
        } else if (isBookingCancelled &&
            !isRefundStatus &&
            isCancelApproved &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Initiate Refund",
            backgroundColor: AppColor.primary.withValues(alpha: 0.15),
            textColor: AppColor.primary,
            onPressed: () async {
              await goRouter.pushNamed(
                AppRoutes.addRefundScreen,
                extra: {"booking": booking},
              );

              if (!context.mounted) return;

              context.read<PayTrackCubit>().getPayTrackList(
                context,
                1,
                booking.projectId,
              );
            },
          );
        } else if (isRefundStatus &&
            canMakePayment &&
            _modifiedRequestsAuthorization.isAction) {
          actionButton = CustomButton(
            text: "Make Payment",
            backgroundColor: AppColor.green,
            textColor: AppColor.white,
            onPressed: () async {
              final result = await goRouter.pushNamed(
                AppRoutes.modifiedRequestsMakePayment,
                extra: {
                  "uniquekey": booking.uniquekey,
                  "bookingId": booking.bookingId,
                  "projectId": booking.projectId,
                },
              );

              if (result == true && context.mounted) {
                await context.read<RequestManagementCubit>().getBookingById(
                  context,
                  1,
                  booking.projectId,
                  booking.bookingId,
                );

                if (context.mounted) {
                  await context
                      .read<RequestManagementCubit>()
                      .getRefundAmountPaymentLedger(
                        context,
                        booking.projectId,
                        booking.bookingId,
                      );
                }

                _tabController.animateTo(3);
              }
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bookingData.bookingApplicantData.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: commonCardDecoration(),
                          child: Center(
                            child: Text(
                              "No Applicant Details Found",
                              style: AppTextStyle.ts14M(),
                            ),
                          ),
                        )
                      else
                        SectionCard(
                          title: "Applicant Details",
                          headerBackgroundColor: AppColor.lightYellowBg2,
                          titleTextColor: AppColor.brownYellowText,
                          border: Border.all(
                            color: AppColor.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          children: [
                            SizedBox(
                              height: 0.4.sh,
                              child: ListView.builder(
                                itemCount:
                                    bookingData.bookingApplicantData.length,
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final applicantDetails =
                                      bookingData.bookingApplicantData[index];
                                  return ApplicantCard(
                                    applicant: applicantDetails,
                                    additionalKeys: [
                                      AdditionalKey(
                                        title: 'Created By',
                                        value: applicantDetails.createdBy,
                                      ),
                                      AdditionalKey(
                                        title: 'Created Date',
                                        value: formatDateTimeAsDDMMMYYYY(
                                          applicantDetails.createdDate,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      SectionCard(
                        title: "Parking Details",
                        titleTextColor: AppColor.blueBgColor,
                        headerBackgroundColor: Color(0xffF6F9FF),
                        border: Border.all(
                          color: AppColor.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        maxContentHeight: 0.3.sh,
                        children: [
                          bookingData.parkingData.isNotEmpty
                              ? Column(
                                children: List.generate(
                                  booking.parkingData.length,
                                  (index) {
                                    final parking = booking.parkingData[index];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColor.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 10.0,
                                        children: [
                                          Text(
                                            "Parking ${index + 1}",
                                            style: AppTextStyle.ts14SB(
                                              color: AppColor
                                                  .greyTitleAndValueColor
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          verticalSpacing(),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Parking Number",
                                                value: parking.parkingNumber,
                                              ),
                                              horizontalSpacing(),
                                              buildColumnTitleValue(
                                                title: "Building",
                                                value: parking.buildingNumber,
                                              ),
                                            ],
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Type",
                                                value: parking.parkingType,
                                              ),
                                              horizontalSpacing(),
                                              buildColumnTitleValue(
                                                title: "Size",
                                                value: parking.parkingSubType,
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Wing",
                                                value: parking.wing,
                                              ),
                                              horizontalSpacing(),
                                              buildColumnTitleValue(
                                                title: "Floor",
                                                value: parking.floor,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Category",
                                                value: parking.parkingCategory,
                                              ),
                                              horizontalSpacing(),
                                              buildColumnTitleValue(
                                                title: "Dimensions",
                                                value:
                                                    parking.parkingDimensions,
                                              ),
                                            ],
                                          ),

                                          horizontalSpacing(),
                                          buildRowWrapper(
                                            child: buildColumnTitleValue(
                                              title: "EV Charging",
                                              value:
                                                  parking.isEVChargingAvailable
                                                      ? "Yes"
                                                      : "No",
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                              : Center(
                                child: noDataWidget(
                                  message: "No Parking Data Found",
                                  iconSize: 160.0,
                                ),
                              ),
                        ],
                      ),
                      SectionCard(
                        title: "Unit / Modulation / Customization Remark",
                        border: Border.all(
                          color: AppColor.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        children: [
                          Text(
                            bookingData.flatAlterationRemark.isEmpty
                                ? "-"
                                : bookingData.flatAlterationRemark,
                            style: AppTextStyle.ts14M(color: AppColor.black),
                          ),
                        ],
                      ),
                      if (bookingData.approvalStatus.trim().toUpperCase() ==
                              "CANCEL" ||
                          bookingData.cancelRemark.trim().isNotEmpty)
                        SectionCard(
                          title: "Cancellation Summary",
                          headerBackgroundColor: AppColor.grey10,
                          titleTextColor: AppColor.black,
                          border: Border.all(
                            color: AppColor.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppColor.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Cancelled Date",
                                        value: formatDateTimeAsDDMMMYYYY(
                                          bookingData.cancelledDate,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      buildColumnTitleValue(
                                        title: "Cancelled By",
                                        value: bookingData.cancelledBy,
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Remark",
                                        value: bookingData.cancelRemark,
                                      ),
                                      horizontalSpacing(),
                                      buildColumnTitleValue(
                                        title: "Proof Of Document",
                                        value: bookingData.cancelledBy,
                                        customValueWidget:
                                            CustomButton.documentOutline(
                                              onPressed: () {
                                                if (bookingData
                                                    .proofOfDocumentUrl
                                                    .isNotEmpty) {
                                                  showFilePreviewDialog(
                                                    context,
                                                    title: "Proof Of Document",
                                                    bookingData
                                                        .proofOfDocumentUrl
                                                        .split(","),
                                                  );
                                                }
                                              },
                                              isDisable:
                                                  booking
                                                      .proofOfDocumentUrl
                                                      .isEmpty,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (bookingData.approvalStatus.trim().toUpperCase() ==
                          "REFUND")
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Refund Amount Details",
                                style: AppTextStyle.ts14SB(),
                              ),
                              verticalSpacing(),
                              Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: AppColor.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Total Refunded",
                                          value:
                                              bookingData
                                                  .totalAmountRefundedAgainstBooking
                                                  .toIndianCurrency(),
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValue(
                                          title: "Paid",
                                          value:
                                              bookingData
                                                  .refundedAmountOnTillDate
                                                  .toIndianCurrency(),
                                        ),
                                      ],
                                    ),
                                    verticalSpacing(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Pending",
                                          value:
                                              (bookingData.totalAmountRefundedAgainstBooking -
                                                      bookingData
                                                          .refundedAmountOnTillDate)
                                                  .toIndianCurrency(),
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValue(
                                          title: "Refund Status",
                                          value: bookingData.approvalStatus,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // HIDE ON AGREEMENT VALUE ZERO
              if (!noAgreementValue)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: actionButton,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
