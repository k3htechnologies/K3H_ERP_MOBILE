import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/presentation/pages/call_logs.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/pages/files.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/pages/flat_handover_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/pages/flat_handover_checklist.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/pages/loan_details_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/pages/payment_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/request_management_screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/snag_checklist.screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayTrackViewScreen extends StatefulWidget {
  final String applicantName;
  final int projectId;
  final int bookingId;
  final int enquiryId;
  const PayTrackViewScreen({
    super.key,
    required this.applicantName,
    required this.projectId,
    required this.bookingId,
    required this.enquiryId,
  });

  @override
  State<PayTrackViewScreen> createState() => _PayTrackViewScreenState();
}

class _PayTrackViewScreenState extends State<PayTrackViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;
  late PayTrackCubit _payTrackCubit;
  late ValueNotifier<bool> isExpanded;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
    _payTrackCubit = context.read<PayTrackCubit>();
    isExpanded = ValueNotifier(false);
    initOverview();
  }

  void initOverview() async {
    await _payTrackCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
    await _payTrackCubit.getEnquiryById(
      enquiryId: widget.enquiryId,
      projectId: widget.projectId,
    );
    if (context.mounted) {
      await _payTrackCubit.getPayTrackCallLog(
        context,
        1,
        widget.projectId,
        widget.bookingId,
      );
    }
    if (context.mounted) {
      await _payTrackCubit.getPayTrackList(context, 1, widget.projectId);
    }
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          initOverview();
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    isExpanded.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Pay Tarck",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            isSecondaryStyle: true,
            tabs: [
              'Overview',
              'Bank Loans',
              'Account',
              'Modified Request',
              'Flat Handover',
              'Files',
              'Call Logs',
              'Snag Cheklist',
              'Flat Handover Checklist',
            ],
          ),
          BlocBuilder<PayTrackCubit, PayTrackState>(
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildOverviewTab(state),
                    LoanDetailsScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    PaymentScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    RequestManagementScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    FlatHandoverScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    FilesScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    CallLogsScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    SnagCheckListScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                    FlatHandoverChecklistScreen(
                      projectId: widget.projectId,
                      bookingId: widget.bookingId,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PayTrackState state) {
    if ((state.isLoading ?? false)) {
      return const Center(child: CircularProgressIndicator());
    }

    final booking = state.bookingData;
    if (booking == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final enquiry = state.currentEnquiryDetails;
    if (enquiry == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final bool isDirectWalking = enquiry.source == "Direct Walking";

    final bool isAdvertisement = enquiry.subSource == "Advertisement";
    final isHtml =
        booking.termsAndConditionsDescription.contains('<') &&
        booking.termsAndConditionsDescription.contains('>');
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(height: 5),
          Text(
            widget.applicantName,
            style: AppTextStyle.ts16M(color: AppColor.primary),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enquiry Details",
                  style: AppTextStyle.ts16SB(color: AppColor.black),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unique Code",
                      value: enquiry.systemGeneratedCode,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Name",
                      value: booking.applicantName,
                    ),
                    buildColumnTitleValue(
                      title: "Mobile No.",
                      value:
                          booking
                              .bookingApplicantData
                              .first
                              .applicantMobileNumber,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source",
                      value: enquiry.source,
                    ),
                    buildColumnTitleValue(
                      title: "Sub Source",
                      value: enquiry.subSource,
                    ),
                  ],
                ),
                if (isDirectWalking && isAdvertisement)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Sub Sub Source",
                        value: enquiry.subSubSource,
                      ),
                    ],
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Sales Advisor",
                      value: enquiry.salesAdvisor,
                    ),
                    buildColumnTitleValue(
                      title: "Sourcing Manager",
                      value: enquiry.sourcingManager,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Current Location",
                      value: enquiry.currentLocation,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Channel Partner",
                      value: enquiry.channelPartnerName,
                    ),
                    buildColumnTitleValue(
                      title: "CP Mobile",
                      value: enquiry.channelPartnerMobileNumber,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "CP Team Member",
                      value: enquiry.channelPartnerTeamMemberName,
                    ),
                    buildColumnTitleValue(
                      title: "CP Team Mobile",
                      value: enquiry.channelPartnerTeamMemberMobileNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 450,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Applicant Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: booking.bookingApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant = booking.bookingApplicantData[index];
                      return infoCard(
                        bgColor: AppColor.white,
                        borderColor: AppColor.primary,

                        titleWidget: Row(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                applicant.applicantName,
                                style: AppTextStyle.ts14M(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            horizontalSpacing(),
                            _buildApplicantTypeWidget(applicant.applicantType),
                          ],
                        ),

                        [
                          {
                            "title": "Mobile Number",
                            "value": applicant.applicantMobileNumber,
                          },
                          {
                            "title": "Email ID",
                            "value": applicant.applicantEmailId,
                          },
                          {
                            "title": "Aadhaar Card No.",
                            "value": applicant.aadharCardNumber,
                          },
                          {
                            "title": "Aadhaar Card",
                            "value": applicant.aadharCardURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.aadharCardURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.aadharCardURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.aadharCardURL.isEmpty,
                            ),
                          },
                          {
                            "title": "PAN Card No.",
                            "value": applicant.panNumber,
                          },
                          {
                            "title": "PAN Card.",
                            "value": applicant.panCardURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.panCardURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.panCardURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.panCardURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Driving License",
                            "value": applicant.drivingLicenseNumber,
                          },
                          {
                            "title": "Driving License",
                            "value": applicant.drivingLicenseURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.drivingLicenseURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.drivingLicenseURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.drivingLicenseURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Voting ID No.",
                            "value": applicant.votingIdNumber,
                          },
                          {
                            "title": "Voting ID",
                            "value": applicant.votingIdURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.votingIdURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.votingIdURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.votingIdURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Passport No.",
                            "value": applicant.passportNumber,
                          },
                          {
                            "title": "Passport",
                            "value": applicant.passportURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.passportURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.passportURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.passportURL.isEmpty,
                            ),
                          },
                          {"title": "GST No.", "value": applicant.gstNumber},
                          {
                            "title": "GST Certificate",
                            "value": applicant.gstNumberURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.gstNumberURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.gstNumberURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.gstNumberURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Cancelled Cheque",
                            "value": applicant.cancelledChequeUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.cancelledChequeUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.cancelledChequeUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.cancelledChequeUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "POA (if NRI Execution)",
                            "value": applicant.poaurl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.poaurl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.poaurl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.poaurl.isEmpty,
                            ),
                          },
                          {
                            "title": "Income Docs (Form 16 / ITR)",
                            "value": applicant.incomeForm16Itrurl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.incomeForm16Itrurl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.incomeForm16Itrurl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.incomeForm16Itrurl.isEmpty,
                            ),
                          },
                          {
                            "title": "NRE / NRO Bank Details",
                            "value": applicant.nreNroBankDetailsUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.nreNroBankDetailsUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.nreNroBankDetailsUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.nreNroBankDetailsUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "Nominee Form",
                            "value": applicant.nomineeFormUrl,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.nomineeFormUrl.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.nomineeFormUrl.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.nomineeFormUrl.isEmpty,
                            ),
                          },
                          {
                            "title": "Statement Of Source Of Funds",
                            "value": applicant.statementOfSourceOfFundsURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant
                                    .statementOfSourceOfFundsURL
                                    .isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.statementOfSourceOfFundsURL.split(
                                      ",",
                                    ),
                                  );
                                }
                              },
                              isDisable:
                                  applicant.statementOfSourceOfFundsURL.isEmpty,
                            ),
                          },

                          {
                            "title": "Payment Proof",
                            "value": applicant.paymentProofURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.paymentProofURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.paymentProofURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.paymentProofURL.isEmpty,
                            ),
                          },
                          {
                            "title": "Profile Photo",
                            "value": applicant.photoURL,
                            "widget": CustomButton.documentOutline(
                              onPressed: () {
                                if (applicant.photoURL.isNotEmpty) {
                                  showFilePreviewDialog(
                                    context,
                                    applicant.photoURL.split(","),
                                  );
                                }
                              },
                              isDisable: applicant.photoURL.isEmpty,
                            ),
                          },
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // PROJECT DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Name",
                      value: booking.projectName,
                    ),
                    buildColumnTitleValue(
                      title: "Booking Type",
                      value: booking.bookingType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit No.",
                      value: booking.flat,
                    ),
                    buildColumnTitleValue(title: "Wing", value: booking.wing),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Floor", value: booking.floor),
                    buildColumnTitleValue(
                      title: "Building Number",
                      value: booking.buildingNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat Type",
                      value: booking.flatType,
                    ),
                    buildColumnTitleValue(
                      title: "Flat Configuration",
                      value: booking.flatConfiguration,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Carpet Area (SqFt)",
                      value: booking.reraCarpetAreaSqFt.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Parking Number",
                      value: booking.parkingNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PARKING SECTION
          Container(
            height: 450,
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
                      booking.parkingData.isEmpty
                          ? Center(child: noDataWidget(message: 'No Parking'))
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: booking.parkingData.length,
                            itemBuilder: (_, index) {
                              final parking = booking.parkingData[index];
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
                                  spacing: 10,
                                  children: [
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
          // BOOKING DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Expected Registration Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        booking.registrationDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Handover Type",
                      value: booking.handoverType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source Of Funding",
                      value: booking.sourceOfFunding,
                    ),
                    buildColumnTitleValue(
                      title: "Number Of Parking",
                      value: booking.numberOfParking.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // BOOKING SUMMARY
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Summary", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) With TDS",
                      value: addCommasToInteger(booking.agreementValue),
                    ),
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) Without TDS",
                      value: addCommasToInteger(
                        booking.agreementValue - booking.agreementValueTDS,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "TDS (₹)",
                      value: addCommasToInteger(booking.agreementValueTDS),
                    ),
                    buildColumnTitleValue(
                      title: "GST (%)",
                      value: "${booking.agreementValueGSTPercentage}%",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST (₹)",
                      value: addCommasToInteger(
                        booking.agreementValueGSTAmount,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Stamp Duty (%)",
                      value: "${booking.stampDutyPercentage}%",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stamp Duty (₹)",
                      value: addCommasToInteger(booking.stampDutyAmount),
                    ),
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: addCommasToInteger(booking.registrationFees),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: addCommasToInteger(booking.bookingAmount),
                    ),
                  ],
                ),
                if (booking.loyaltyAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Loyalty (%)",
                        value: "${booking.loyaltyPercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Loyalty Amount (₹)",
                        value: addCommasToInteger(booking.loyaltyAmount),
                      ),
                    ],
                  ),
                if (booking.brokerageAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Brokerage (%)",
                        value: "${booking.brokeragePercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Brokerage Amount (₹)",
                        value: addCommasToInteger(booking.brokerageAmount),
                      ),
                    ],
                  ),
                if (booking.employeeReferenceAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Employee Reference (%)",
                        value: "${booking.employeeReferencePercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Employee Reference Amount (₹)",
                        value: addCommasToInteger(
                          booking.employeeReferenceAmount,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // PAYMENT DETAILS
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Cheque / RTGS No.",
                      value: booking.chequeRTGSNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Cheque / RTGS Date",
                      value:
                          booking.chequeRTGSDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                booking.chequeRTGSDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Bank Name",
                      value: booking.bankName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // OTHER CHARGES SECTION
          Container(
            height: 450,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Other Charges", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child:
                      booking.bookingOtherChargesData.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: booking.bookingOtherChargesData.length,
                            itemBuilder: (_, index) {
                              final extraCharge =
                                  booking.bookingOtherChargesData[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.primary,
                                    width: .3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Name",
                                          value: extraCharge.chargeName,
                                        ),
                                        buildColumnTitleValue(
                                          title: "Calculated On",
                                          value: extraCharge.calculatedOn,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Value (In ₹)",
                                          value: addCommasToInteger(
                                            extraCharge.value,
                                          ),
                                        ),
                                        buildColumnTitleValue(
                                          title: "GST (%)",
                                          value:
                                              extraCharge.gstPercentage
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "GST Value (₹)",
                                          value: addCommasToInteger(
                                            extraCharge.gstValue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                          : Center(
                            child: noDataWidget(
                              message: "No Charges Available",
                              iconSize: 180,
                            ),
                          ),
                ),
              ],
            ),
          ),
          // PAYMENT SCHEDULE SECTION
          Container(
            height: 450,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Schedule", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: booking.bookingPaymentScheduleData.length,
                    itemBuilder: (context, index) {
                      final payment = booking.bookingPaymentScheduleData[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primary,
                            width: .3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Type",
                                  value: payment.type,
                                ),
                                payment.type.contains("Date")
                                    ? buildColumnTitleValue(
                                      title: "Date",
                                      value:
                                          payment.date != null
                                              ? formatDateTimeAsDDMMMYYYY(
                                                payment.date!,
                                              )
                                              : "-",
                                    )
                                    : buildColumnTitleValue(
                                      title: "Stage",
                                      value: payment.name,
                                    ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Percentage (%)",
                                  value:
                                      "${payment.paymentSchedulePercentage} %",
                                ),
                                buildColumnTitleValue(
                                  title: "Amount (₹)",
                                  value: addCommasToInteger(
                                    payment.paymentScheduleAmount,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "GST Amount (₹)",
                                  value: addCommasToInteger(
                                    payment.paymentScheduleGSTAmount,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "TDS Amount (₹)",
                                  value: addCommasToInteger(
                                    payment.paymentScheduleTDSAmount,
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
              ],
            ),
          ),
          // FLAT ALTERATION REMARKS SECTION
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Flat Alteration Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.flatAlterationRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PAYMENT REMARK
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.paymentRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // OTHER REMARK
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Other Remarks", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: booking.otherRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // TERMS AND CONDITIONS
          Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, value, child) {
                final hasData =
                    booking.termsAndConditionsDescription.trim().isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        isExpanded.value = !isExpanded.value;
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Terms & Conditions",
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            Icon(
                              value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (value && hasData) ...[
                      const SizedBox(height: 10),
                      isHtml
                          ? Html(
                            data: booking.termsAndConditionsDescription,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
                          )
                          : Text(
                            booking.termsAndConditionsDescription,
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                    ] else if (value && !hasData) ...[
                      Center(
                        child: noDataWidget(
                          message: "No Terms & Conditions Available",
                          iconSize: 180,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: booking.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDate(booking.createdDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value: booking.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value: formatDate(booking.modifiedDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Approval Status",
                      value: booking.approvalStatus,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Call Log History", style: AppTextStyle.ts16SB()),

                const SizedBox(height: 20),

                state.payTrackCallLogList.isEmpty
                    ? Center(
                      child: noDataWidget(
                        message: "No Call Logs Available",
                        iconSize: 180,
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.payTrackCallLogList.length,
                      itemBuilder: (context, index) {
                        final callLog = state.payTrackCallLogList[index];

                        final bool isLast =
                            index == state.payTrackCallLogList.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT TIMELINE
                              Column(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColor.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 3,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        color: AppColor.primary,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 16),

                              // RIGHT CONTENT
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // DATE + STATUS
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatDateTimeAsDDMMMYYYY(
                                                callLog.createdDate,
                                              ),
                                              style: AppTextStyle.ts16SB(),
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(
                                                callLog.callStatus,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              callLog.callStatus.toUpperCase(),
                                              style: AppTextStyle.ts12M(
                                                color: _getStatusTextColor(
                                                  callLog.callStatus,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // CREATED BY
                                      Text(
                                        callLog.createdBy,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // PURPOSE
                                      RichText(
                                        text: TextSpan(
                                          text: "Purpose: ",
                                          style: AppTextStyle.ts14SB(
                                            color: AppColor.black,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: callLog.callPurpose,
                                              style: AppTextStyle.ts14SB(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // PROMISE AMOUNT
                                      Text(
                                        "Promise Amount: ₹${addCommasToInteger(callLog.promiseAmount)}",
                                        style: AppTextStyle.ts14SB(
                                          color: Colors.green,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // REMARK
                                      Text(
                                        callLog.remark,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return Colors.green.withValues(alpha: .12);

      case "assigned":
        return Colors.blue.withValues(alpha: .12);

      case "in progress":
        return Colors.orange.withValues(alpha: .12);

      case "resolved":
        return Colors.amber.withValues(alpha: .18);

      case "pending":
        return Colors.grey.withValues(alpha: .15);

      default:
        return Colors.grey.withValues(alpha: .12);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return AppColor.green;

      case "assigned":
        return AppColor.primary;

      case "in progress":
        return AppColor.orange;

      case "resolved":
        return Colors.brown;

      case "pending":
        return AppColor.black;

      default:
        return AppColor.black;
    }
  }

  // BUILD APPLICANT TYPE WIDGET
  Widget _buildApplicantTypeWidget(String type) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            type.toLowerCase() == "applicant"
                ? AppColor.lightBlue
                : AppColor.purple.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: AppTextStyle.ts12M(
          color:
              type.toLowerCase() == "applicant"
                  ? AppColor.primary
                  : AppColor.purple,
        ),
      ),
    );
  }
}
