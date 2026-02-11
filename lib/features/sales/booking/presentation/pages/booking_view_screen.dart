import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _bookingCubit = context.read<BookingCubit>();
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
            child: Text(
              widget.bookingModel.applicantName,
              style: AppTextStyle.ts16SB(color: AppColor.primary),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: AppColor.grey,
                  indicator: BoxDecoration(
                    color: AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyle.ts14M(),
                  unselectedLabelStyle: AppTextStyle.ts14M(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Extra Charges'),
                    Tab(text: 'Payment Schedule'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [_buildDetailsTab(), _buildExtraChargesTab(),_buildPaymentSchedule()],
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
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
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
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address Details", style: AppTextStyle.ts16SB()),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Permanent Address",
                      value: widget.bookingModel.permanentAddress,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Communication Address",
                      value: widget.bookingModel.communicationAddress,
                    ),
                  ],
                ),
              ],
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
                Text("Project & Unit Details", style: AppTextStyle.ts16SB()),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Site Name",
                      value: widget.bookingModel.projectName,
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
                      title: "Flat",
                      value: widget.bookingModel.flat,
                    ),
                    buildColumnTitleValue(
                      title: "RERA Carpet Area",
                      value: widget.bookingModel.reraCarpetAreaSqFt.toString(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Category",
                      value: widget.bookingModel.flatType,
                    ),
                    buildColumnTitleValue(
                      title: "Configuration",
                      value: widget.bookingModel.flatConfiguration,
                    ),
                  ],
                ),
              ],
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
                Text("Agreement Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit Value (With TDS)",
                      value: "₹ ${widget.bookingModel.agreementValue}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "TDS Amount",
                      value: "₹ ${widget.bookingModel.agreementValueTDS}",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "TDS Amount (Without TDS)",
                      value:
                          "₹ ${(widget.bookingModel.agreementValue - widget.bookingModel.agreementValueTDS).toString()}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tax Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "GST Amount",
                      value:
                          "₹ ${widget.bookingModel.agreementValueGSTAmount} (${widget.bookingModel.agreementValueGSTPercentage}%)",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Stamp Duty Amount",
                      value:
                          "₹ ${widget.bookingModel.stampDutyAmount} (${widget.bookingModel.stampDutyPercentage}%)",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Registration Fees",
                      value: "₹ ${widget.bookingModel.registrationFees}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Management Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // buildColumnTitleValue(title: "Sourcing Manager", value: widget.bookingModel.)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD EXTRA CHARGES TAB
  Widget _buildExtraChargesTab() {
    if(widget.bookingModel.bookingOtherChargesData.isEmpty){
      return noDataWidget();
    }
    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: widget.bookingModel.bookingOtherChargesData.length,
      itemBuilder: (context,index) {
        final extraCharge = widget.bookingModel.bookingOtherChargesData[index];
        return Container(
          decoration: commonCardDecoration(),
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          child:Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildColumnTitleValue(title: "Name", value: extraCharge.chargeName)
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(title: "Value (In ₹)", value: "${extraCharge.value} ${extraCharge.calculatedOn}"),
                  buildColumnTitleValue(title: "Gst (%)", value: extraCharge.gstPercentage.toString()),
                ],
              )
            ],
          )
        );
      }
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    if(widget.bookingModel.bookingPaymentScheduleData.isEmpty){
      return noDataWidget();
    }
    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shrinkWrap: true,
        itemCount: widget.bookingModel.bookingPaymentScheduleData.length,
        itemBuilder: (context,index) {
          final payment = widget.bookingModel.bookingPaymentScheduleData[index];
          return Container(
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              child:Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildColumnTitleValue(title: "Ranking", value: payment.type),
                      buildColumnTitleValue(title: "Name", value: payment.name),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(title: "Percentage (%)", value: payment.paymentSchedulePercentage.toString()),
                      // buildColumnTitleValue(title: "Cumulative(%)", value: payment..toString()),
                    ],
                  )
                ],
              )
          );
        }
    );
  }

}
