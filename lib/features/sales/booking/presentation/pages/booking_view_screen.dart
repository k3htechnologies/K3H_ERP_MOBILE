import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BookingViewScreen extends StatefulWidget {
  final BookingModel bookingModel;
  const BookingViewScreen({super.key, required this.bookingModel});

  @override
  State<BookingViewScreen> createState() => _BookingViewScreenState();
}

class _BookingViewScreenState extends State<BookingViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late BookingCubit _bookingCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChange);
    _bookingCubit = context.read<BookingCubit>();
    _bookingCubit.getEnquiryList(
      context,
      1,
      widget.bookingModel.projectId,
      null,
      widget.bookingModel.enquiryId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _bookingCubit.onTabChanged(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.bookingModel.applicantName,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
                if (widget.bookingModel.approvalStatus.toLowerCase().contains(
                  'approved',
                ))
                  CustomButton(
                    leading: Image.asset(
                      AppAssets.pdfLogo,
                      height: 20,
                      width: 20,
                    ),
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.primary,
                    textColor: AppColor.primary,
                    text: "Generate PDF",
                    onPressed: () {
                      _bookingCubit.generateBookingPDF(
                        context,
                        widget.bookingModel,
                      );
                    },
                  ),
              ],
            ),
          ),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: [
              'Overview',
              'Applicant Details',
              'Other Charges',
              'Payment Schedule',
              'Remark',
              'Terms & Condition',
              'Payment Details',
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildApplicantDetailsTab(),
                _buildOtherChargesTab(),
                _buildPaymentSchedule(),
                _buildRemarkTab(),
                _buildTermsAndConditionTab(),
                _buildPaymentDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
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

  // BUILD DETAILS TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // ENQUIRY SECTION
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state.enquiryList.isEmpty) {
                return SizedBox();
              }

              final enquiry = state.enquiryList.first;

              return Container(
                decoration: BoxDecoration(
                  color: AppColor.lightBlue.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.primary, width: .3),
                ),
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enquiry Details", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
                    Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Unique Code",
                              value: enquiry.systemGeneratedCode,
                            ),
                            buildColumnTitleValue(
                              title: "Name",
                              value: enquiry.name,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Mobile No",
                              value: enquiry.mobileNumber,
                            ),
                            buildColumnTitleValue(
                              title: "Source",
                              value: enquiry.source,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Sub Source",
                              value: enquiry.subSource,
                            ),
                            buildColumnTitleValue(
                              title: "Sub Sub Source",
                              value: enquiry.subSubSource,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
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
                  ],
                ),
              );
            },
          ),
          // APPLICANT SECTION
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
                    itemCount: widget.bookingModel.bookingApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant =
                          widget.bookingModel.bookingApplicantData[index];
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
                                _buildApplicantTypeWidget(
                                  applicant.applicantType,
                                ),
                              ],
                            ),

                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Contact Number",
                                  value:
                                      applicant.applicantMobileNumber.isEmpty
                                          ? "-"
                                          : applicant.applicantMobileNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Email ID",
                                  value:
                                      applicant.applicantEmailId.isEmpty
                                          ? "-"
                                          : applicant.applicantEmailId,
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Aadhaar Card No.",
                                  value:
                                      applicant.aadharCardNumber.isEmpty
                                          ? "-"
                                          : applicant.aadharCardNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Aadhaar Card",
                                  value:
                                      applicant.aadharCardURL.isEmpty
                                          ? "-"
                                          : applicant.aadharCardURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .aadharCardURL
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.aadharCardURL.split(
                                                ",",
                                              ),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant.aadharCardURL.isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "PAN Card No.",
                                  value:
                                      applicant.panNumber.isEmpty
                                          ? "-"
                                          : applicant.panNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "PAN Card.",
                                  value:
                                      applicant.panCardURL.isEmpty
                                          ? "-"
                                          : applicant.panCardURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
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
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Driving License",
                                  value:
                                      applicant.drivingLicenseNumber.isEmpty
                                          ? "-"
                                          : applicant.drivingLicenseNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Driving License",
                                  value:
                                      applicant.drivingLicenseURL.isEmpty
                                          ? "-"
                                          : applicant.drivingLicenseURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .drivingLicenseURL
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.drivingLicenseURL.split(
                                                ",",
                                              ),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant.drivingLicenseURL.isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Voting ID No.",
                                  value:
                                      applicant.votingIdNumber.isEmpty
                                          ? "-"
                                          : applicant.votingIdNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Voting ID",
                                  value:
                                      applicant.votingIdURL.isEmpty
                                          ? "-"
                                          : applicant.votingIdURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .votingIdURL
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.votingIdURL.split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant.votingIdURL.isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Passport No.",
                                  value:
                                      applicant.passportNumber.isEmpty
                                          ? "-"
                                          : applicant.passportNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Passport",
                                  value:
                                      applicant.passportURL.isEmpty
                                          ? "-"
                                          : applicant.passportURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .passportURL
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.passportURL.split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant.passportURL.isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "GST No.",
                                  value:
                                      applicant.gstNumber.isEmpty
                                          ? "-"
                                          : applicant.gstNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "GST",
                                  value:
                                      applicant.gstNumberURL.isEmpty
                                          ? "-"
                                          : applicant.gstNumberURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .gstNumberURL
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.gstNumberURL.split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant.gstNumberURL.isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Profile Photo",
                                  value:
                                      applicant.photoURL.isEmpty
                                          ? "-"
                                          : applicant.photoURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
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
                                ),
                                Expanded(child: SizedBox()),
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
                      value: widget.bookingModel.projectName,
                    ),
                    buildColumnTitleValue(
                      title: "Booking Type",
                      value: widget.bookingModel.bookingType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat",
                      value: widget.bookingModel.flat,
                    ),
                    buildColumnTitleValue(
                      title: "Wing",
                      value: widget.bookingModel.wing,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Floor",
                      value: widget.bookingModel.floor,
                    ),
                    buildColumnTitleValue(
                      title: "Building Number",
                      value: widget.bookingModel.buildingNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat Type",
                      value: widget.bookingModel.flatType,
                    ),
                    buildColumnTitleValue(
                      title: "Flat Configuration",
                      value: widget.bookingModel.flatConfiguration,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Carpet Area (SqFt)",
                      value: widget.bookingModel.reraCarpetAreaSqFt.toString(),
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
                      widget.bookingModel.parkingData.isEmpty
                          ? Center(child: noDataWidget(message: 'No Parking'))
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: widget.bookingModel.parkingData.length,
                            itemBuilder: (_, index) {
                              final parking =
                                  widget.bookingModel.parkingData[index];
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
                        widget.bookingModel.registrationDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Handover Type",
                      value: widget.bookingModel.handoverType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Mode Of Payment",
                      value: widget.bookingModel.modeOfPayment,
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
                      title: "Agreement Value (₹)",
                      value: "₹ ${widget.bookingModel.agreementValue}",
                    ),
                    buildColumnTitleValue(
                      title: "TDS (₹)",
                      value: "₹ ${widget.bookingModel.agreementValueTDS}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST (%)",
                      value:
                          "${widget.bookingModel.agreementValueGSTPercentage}%",
                    ),
                    buildColumnTitleValue(
                      title: "GST (₹)",
                      value: "₹ ${widget.bookingModel.agreementValueGSTAmount}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stamp Duty (%)",
                      value: "${widget.bookingModel.stampDutyPercentage}%",
                    ),
                    buildColumnTitleValue(
                      title: "Stamp Duty (₹)",
                      value: "₹ ${widget.bookingModel.stampDutyAmount}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: "₹ ${widget.bookingModel.registrationFees}",
                    ),
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: "₹ ${widget.bookingModel.bookingAmount}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Brokerage (%)",
                      value: "${widget.bookingModel.brokeragePercentage}%",
                    ),
                    buildColumnTitleValue(
                      title: "Brokerage Amount (₹)",
                      value: "₹ ${widget.bookingModel.brokerageAmount}",
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
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount:
                        widget.bookingModel.bookingOtherChargesData.length,
                    itemBuilder: (_, index) {
                      final extraCharge =
                          widget.bookingModel.bookingOtherChargesData[index];
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
                                  value:
                                      "${extraCharge.value} ${extraCharge.calculatedOn}",
                                ),
                                buildColumnTitleValue(
                                  title: "Gst (%)",
                                  value: extraCharge.gstPercentage.toString(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "GST Value (₹)",
                                  value: "₹ ${extraCharge.gstValue}",
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
          // ACTION DETAILS
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
                      value: widget.bookingModel.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDate(widget.bookingModel.createdDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value: widget.bookingModel.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value: formatDate(widget.bookingModel.modifiedDate),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Approval Status",
                      value: widget.bookingModel.approvalStatus,
                    ),
                  ],
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
                      value: widget.bookingModel.flatAlterationRemark,
                    ),
                  ],
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
                    itemCount:
                        widget.bookingModel.bookingPaymentScheduleData.length,
                    itemBuilder: (context, index) {
                      final payment =
                          widget.bookingModel.bookingPaymentScheduleData[index];
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
                                  title: "Type",
                                  value: payment.type,
                                ),
                                buildColumnTitleValue(
                                  title: "Name",
                                  value: payment.name,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Date",
                                  value:
                                      payment.date != null
                                          ? formatDateTimeAsDDMMMYYYY(
                                            payment.date!,
                                          )
                                          : "-",
                                ),
                                buildColumnTitleValue(
                                  title: "Percentage (%)",
                                  value:
                                      payment.paymentSchedulePercentage
                                          .toString(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "Amount (₹)",
                                  value: "₹ ${payment.paymentScheduleAmount}",
                                ),
                                buildColumnTitleValue(
                                  title: "GST (₹)",
                                  value:
                                      "₹ ${payment.paymentScheduleGSTAmount}",
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                buildColumnTitleValue(
                                  title: "TDS (₹)",
                                  value:
                                      "₹ ${payment.paymentScheduleTDSAmount}",
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
        ],
      ),
    );
  }

  // BUILD APPLICANT DETAILS
  Widget _buildApplicantDetailsTab() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: widget.bookingModel.bookingApplicantData.length,
      itemBuilder: (_, index) {
        final applicant = widget.bookingModel.bookingApplicantData[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.primary, width: .3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            spacing: 10,
            children: [
              Row(
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

              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Contact Number",
                    value:
                        applicant.applicantMobileNumber.isEmpty
                            ? "-"
                            : applicant.applicantMobileNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Email ID",
                    value:
                        applicant.applicantEmailId.isEmpty
                            ? "-"
                            : applicant.applicantEmailId,
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Aadhaar Card No.",
                    value:
                        applicant.aadharCardNumber.isEmpty
                            ? "-"
                            : applicant.aadharCardNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Aadhaar Card",
                    value:
                        applicant.aadharCardURL.isEmpty
                            ? "-"
                            : applicant.aadharCardURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "PAN Card No.",
                    value:
                        applicant.panNumber.isEmpty ? "-" : applicant.panNumber,
                  ),
                  buildColumnTitleValue(
                    title: "PAN Card.",
                    value:
                        applicant.panCardURL.isEmpty
                            ? "-"
                            : applicant.panCardURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Driving License",
                    value:
                        applicant.drivingLicenseNumber.isEmpty
                            ? "-"
                            : applicant.drivingLicenseNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Driving License",
                    value:
                        applicant.drivingLicenseURL.isEmpty
                            ? "-"
                            : applicant.drivingLicenseURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Voting ID No.",
                    value:
                        applicant.votingIdNumber.isEmpty
                            ? "-"
                            : applicant.votingIdNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Voting ID",
                    value:
                        applicant.votingIdURL.isEmpty
                            ? "-"
                            : applicant.votingIdURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Passport No.",
                    value:
                        applicant.passportNumber.isEmpty
                            ? "-"
                            : applicant.passportNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Passport",
                    value:
                        applicant.passportURL.isEmpty
                            ? "-"
                            : applicant.passportURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "GST No.",
                    value:
                        applicant.gstNumber.isEmpty ? "-" : applicant.gstNumber,
                  ),
                  buildColumnTitleValue(
                    title: "GST",
                    value:
                        applicant.gstNumberURL.isEmpty
                            ? "-"
                            : applicant.gstNumberURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Profile Photo",
                    value:
                        applicant.photoURL.isEmpty ? "-" : applicant.photoURL,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD OTHER CHARGES TAB
  Widget _buildOtherChargesTab() {
    if (widget.bookingModel.bookingOtherChargesData.isEmpty) {
      return noDataWidget();
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: widget.bookingModel.bookingOtherChargesData.length,
      itemBuilder: (context, index) {
        final extraCharge = widget.bookingModel.bookingOtherChargesData[index];
        return Container(
          decoration: commonCardDecoration(),
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
                    value: "${extraCharge.value} ${extraCharge.calculatedOn}",
                  ),
                  buildColumnTitleValue(
                    title: "Gst (%)",
                    value: extraCharge.gstPercentage.toString(),
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "GST Value (₹)",
                    value: "₹ ${extraCharge.gstValue}",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    if (widget.bookingModel.bookingPaymentScheduleData.isEmpty) {
      return noDataWidget();
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: widget.bookingModel.bookingPaymentScheduleData.length,
      itemBuilder: (context, index) {
        final payment = widget.bookingModel.bookingPaymentScheduleData[index];
        return Container(
          decoration: commonCardDecoration(),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildColumnTitleValue(title: "Type", value: payment.type),
                  buildColumnTitleValue(title: "Name", value: payment.name),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Date",
                    value:
                        payment.date != null
                            ? formatDateTimeAsDDMMMYYYY(payment.date!)
                            : "-",
                  ),
                  buildColumnTitleValue(
                    title: "Percentage (%)",
                    value: payment.paymentSchedulePercentage.toString(),
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Amount (₹)",
                    value: "₹ ${payment.paymentScheduleAmount}",
                  ),
                  buildColumnTitleValue(
                    title: "GST (₹)",
                    value: "₹ ${payment.paymentScheduleGSTAmount}",
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "TDS (₹)",
                    value: "₹ ${payment.paymentScheduleTDSAmount}",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD REMARKS TAB
  Widget _buildRemarkTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unit / Modulation / Customization Remark",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: widget.bookingModel.flatAlterationRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Related Remark", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Remarks",
                      value: widget.bookingModel.paymentRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Unit Remark", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Other Remark",
                      value: widget.bookingModel.otherRemark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD TERMS AND CONDITION TAB
  Widget _buildTermsAndConditionTab() {
    return Container(
      padding: EdgeInsets.all(16),
      child:
          widget.bookingModel.termsAndConditionsDescription.isNotEmpty
              ? Column(
                children: [
                  Text("Terms & Conditions", style: AppTextStyle.ts16SB()),
                  verticalSpacing(),
                  Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      widget.bookingModel.termsAndConditionsDescription,
                      style: AppTextStyle.ts14M(),
                    ),
                  ),
                ],
              )
              : Center(child: noDataWidget()),
    );
  }

  // BUILD PAYMENT DETAILS TAB
  Widget _buildPaymentDetailsTab() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Details", style: AppTextStyle.ts16SB()),
          verticalSpacing(),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Amount",
                      value: "₹ ${widget.bookingModel.bookingAmount}",
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Cheque/ RTGS Number",
                      value: widget.bookingModel.chequeRTGSNumber,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Cheque/ RTGS Date",
                      value:
                          widget.bookingModel.chequeRTGSDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.bookingModel.chequeRTGSDate!,
                              )
                              : '-',
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Payment Bank",
                      value: widget.bookingModel.bankName,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
