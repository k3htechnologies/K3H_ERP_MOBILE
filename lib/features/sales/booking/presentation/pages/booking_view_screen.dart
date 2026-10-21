import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/widgets/applicant_card.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BookingViewScreen extends StatefulWidget {
  final int bookingId;
  final int projectId;
  const BookingViewScreen({
    super.key,
    required this.bookingId,
    required this.projectId,
  });

  @override
  State<BookingViewScreen> createState() => _BookingViewScreenState();
}

class _BookingViewScreenState extends State<BookingViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late BookingCubit _bookingCubit;
  late BookingModel? bookingModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChange);
    _bookingCubit = context.read<BookingCubit>();
    loadBooking();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> loadBooking() async {
    bookingModel = await _bookingCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
    if (mounted && bookingModel != null) {
      _bookingCubit.getEnquiryList(
        context,
        1,
        widget.projectId,
        null,
        bookingModel!.enquiryId,
      );
    }
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
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return (state.isLoading ?? true)
              ? Center(child: loader())
              : bookingModel != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            bookingModel!.applicantName,
                            style: AppTextStyle.ts16SB(color: AppColor.primary),
                          ),
                        ),
                        if (bookingModel!.approvalStatus.toLowerCase().contains(
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
                            text: "PDF",
                            onPressed: () async {
                              final RenderBox button =
                                  context.findRenderObject() as RenderBox;
                              final RenderBox overlay =
                                  Overlay.of(context).context.findRenderObject()
                                      as RenderBox;

                              final Offset position = button.localToGlobal(
                                Offset.zero,
                                ancestor: overlay,
                              );

                              final selected = await showMenu<String>(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  position.dx + button.size.width,
                                  position.dy + 55,
                                  position.dx,
                                  position.dy + button.size.height,
                                ),
                                items: [
                                  PopupMenuItem(
                                    value: 'generate',
                                    child: Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf, size: 18),
                                        SizedBox(width: 8),
                                        Text('Generate'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'email',
                                    child: Row(
                                      children: [
                                        Icon(Icons.email, size: 18),
                                        SizedBox(width: 8),
                                        Text('Send E-mail'),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                              if (selected == 'generate') {
                                if (context.mounted) {
                                  _bookingCubit.generateBookingPDF(
                                    context,
                                    bookingModel!,
                                    isSendEmail: false,
                                  );
                                }
                              } else if (selected == 'email') {
                                if (context.mounted) {
                                  _bookingCubit.generateBookingPDF(
                                    context,
                                    bookingModel!,
                                    isSendEmail: true,
                                  );
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: showSiteSelectedWidget(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ChipStyleTabBar(
                      style: ChipTabBarStyle.underline,
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
              )
              : Text("data");
        },
      ),
    );
  }

  // BUILD DETAILS TAB
  Widget _buildOverviewTab() {
    final isHtml =
        bookingModel!.termsAndConditionsDescription.contains('<') &&
        bookingModel!.termsAndConditionsDescription.contains('>');
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // ENQUIRY SECTION
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state.enquiryList.isEmpty) {
                return const SizedBox();
              }

              final enquiry = state.enquiryList.first;

              final bool isChannelPartner = enquiry.source == "Channel Partner";
              final bool isDirectWalking = enquiry.source == "Direct Walkin";
              final bool isAdvertisement = enquiry.subSource == "Advertisement";
              final bool isEmployeeReference =
                  enquiry.subSource == "Employee Reference";
              final bool isLoyalty = enquiry.subSource == "Loyalty";
              final bool isReference = enquiry.subSource == "Reference";

              final List<Map<String, dynamic>> items = [];

              /// BASIC INFO
              items.addAll([
                {"title": "Enquiry Code", "value": enquiry.systemGeneratedCode},
                {"title": "Name", "value": enquiry.name},
                {
                  "title": "Mobile No.",
                  "value": enquiry.mobileNumber,
                  "widget": CustomClickToContactText(
                    countryCode: enquiry.mobileNumberCountryCode,
                    value: enquiry.mobileNumber,
                  ),
                },
                {
                  "title": "E-Mail ID",
                  "value": enquiry.emailId,
                  "widget": CustomClickToContactText(
                    value: enquiry.emailId,
                    type: ContactType.email,
                  ),
                },
                {"title": "Source", "value": enquiry.source},
              ]);

              /// SUB SOURCE
              items.add({"title": "Sub Source", "value": enquiry.subSource});

              if (isDirectWalking && isAdvertisement) {
                items.add({
                  "title": "Sub Sub Source",
                  "value": enquiry.subSubSource,
                });
              }

              /// SALES
              items.addAll([
                {"title": "Sales Advisor", "value": enquiry.salesAdvisor},
                {"title": "Sourcing Manager", "value": enquiry.sourcingManager},
              ]);

              /// LOCATION
              items.add({
                "title": "Current Location",
                "value": enquiry.currentLocation,
              });

              return Column(
                children: [
                  SectionCard(
                    title: "Enquiry Details",
                    titleTextColor: AppColor.blueBgColor,
                    headerBackgroundColor: Color(0xffF6F9FF),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      infoCard(items),
                      if (isReference)
                        infoCard([
                          {
                            "title": "Referral Name",
                            "value": enquiry.referralName,
                          },
                          {
                            "title": "Referral Project",
                            "value": enquiry.referralProjectName,
                          },
                          {
                            "title": "Referral Unit No",
                            "value": enquiry.referralUnitNumber,
                          },
                          {
                            "title": "Referral Unit Owner",
                            "value": enquiry.referralUnitOwnerName,
                          },
                        ]),

                      if (isEmployeeReference)
                        infoCard([
                          {
                            "title": "Employee Name",
                            "value": enquiry.employeeReferenceName,
                          },
                          {
                            "title": "Employee Mobile",
                            "value": enquiry.employeeReferenceMobileNumber,
                          },
                        ]),

                      if (isLoyalty)
                        infoCard([
                          {
                            "title": "Existing Project",
                            "value": enquiry.loyaltyExistingProjectName,
                          },
                          {
                            "title": "Existing Unit No",
                            "value": enquiry.loyaltyExistingUnitNumber,
                          },
                          {
                            "title": "Existing Unit Owner",
                            "value": enquiry.loyaltyExistingUnitOwnerName,
                          },
                        ]),
                      if (isChannelPartner)
                        infoCard([
                          {
                            "title": "CP Code",
                            "value": enquiry.channelPartnerCode,
                          },
                          {
                            "title": "CP Name",
                            "value": enquiry.channelPartnerName,
                          },
                          {
                            "title": "CP Mobile",
                            "value": enquiry.channelPartnerMobileNumber,
                            "widget": CustomClickToContactText(
                              countryCode:
                                  enquiry.channelPartnerMobileNumberCountryCode,
                              value: enquiry.channelPartnerMobileNumber,
                            ),
                          },
                          {
                            "title": "CP E-Mail ID",
                            "value": enquiry.channelPartnerEmailId,
                            "widget": CustomClickToContactText(
                              value: enquiry.channelPartnerEmailId,
                              type: ContactType.email,
                            ),
                          },
                          {
                            "title": "CP Team Member",
                            "value": enquiry.channelPartnerTeamMemberName,
                          },
                          {
                            "title": "CP Team Mobile",
                            "value":
                                enquiry.channelPartnerTeamMemberMobileNumber,
                            "widget": CustomClickToContactText(
                              countryCode:
                                  enquiry
                                      .channelPartnerTeamMemberMobileNumberCountryCode,
                              value:
                                  enquiry.channelPartnerTeamMemberMobileNumber,
                            ),
                          },
                          {
                            "title": "CP Team E-Mail ID",
                            "value": enquiry.channelPartnerTeamMemberEmailId,
                            "widget": CustomClickToContactText(
                              value: enquiry.channelPartnerTeamMemberEmailId,
                              type: ContactType.email,
                            ),
                          },
                        ]),
                    ],
                  ),
                  // APPLICANT DETAILS
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
                        height: 250.0,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount: bookingModel!.bookingApplicantData.length,
                          itemBuilder: (_, index) {
                            final applicant =
                                bookingModel!.bookingApplicantData[index];
                            return ApplicantCard(applicant: applicant);
                          },
                        ),
                      ),
                    ],
                  ),
                  // ADDRESS DETAILS
                  SectionCard(
                    title: "Address Details",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      buildRowWrapper(
                        child: buildColumnTitleValue(
                          title: "Permanent Address",
                          value: bookingModel!.permanentAddress,
                        ),
                      ),
                      buildRowWrapper(
                        child: buildColumnTitleValue(
                          title: "Communication Address",
                          value: bookingModel!.communicationAddress,
                        ),
                      ),
                    ],
                  ),
                  //  PROJECT DETAILS
                  SectionCard(
                    title: "Project Details",
                    titleTextColor: AppColor.blueBgColor,
                    headerBackgroundColor: Color(0xffF6F9FF),
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
                            title: "Project Name",
                            value: bookingModel!.projectName,
                          ),
                          buildColumnTitleValue(
                            title: "Booking Type",
                            value: bookingModel!.bookingType,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Unit No.",
                            value: bookingModel!.flat,
                          ),
                          buildColumnTitleValue(
                            title: "Wing",
                            value: bookingModel!.wing,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Floor",
                            value: bookingModel!.floor,
                          ),
                          buildColumnTitleValue(
                            title: "Building Number",
                            value: bookingModel!.buildingNumber,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Flat Type",
                            value: bookingModel!.flatType,
                          ),
                          buildColumnTitleValue(
                            title: "Flat Configuration",
                            value: bookingModel!.flatConfiguration,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "RERA Carpet Area (SqFt)",
                            value: bookingModel!.reraCarpetAreaSqFt.toString(),
                          ),
                          buildColumnTitleValue(
                            title: "Parking Number",
                            value: bookingModel!.parkingNumber,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // PARKING DETAILS
                  SectionCard(
                    title: "Parking Details",
                    titleTextColor: AppColor.blueBgColor,
                    headerBackgroundColor: Color(0xffF6F9FF),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      bookingModel!.parkingData.isEmpty
                          ? Center(child: noDataWidget(message: 'No Parking'))
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: bookingModel!.parkingData.length,
                            itemBuilder: (_, index) {
                              final parking = bookingModel!.parkingData[index];
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
                    ],
                  ),
                  // BOOKING DETAILS
                  SectionCard(
                    title: "Booking Details",
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
                            title: "Expected Registration Date",
                            value: formatDateTimeAsDDMMMYYYY(
                              bookingModel!.registrationDate,
                            ),
                          ),
                          buildColumnTitleValue(
                            title: "Final Registration Date",
                            value:
                                bookingModel!.finalRegistrationDate != null
                                    ? formatDateTimeAsDDMMMYYYY(
                                      bookingModel!.finalRegistrationDate!,
                                    )
                                    : "-",
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Handover Type",
                            value: bookingModel!.handoverType,
                          ),
                          buildColumnTitleValue(
                            title: "Source Of Funding",
                            value: bookingModel!.sourceOfFunding,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Number Of Parking",
                            value: bookingModel!.numberOfParking.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // BOOKING SUMMARY
                  SectionCard(
                    title: "Booking Summary",
                    headerBackgroundColor: AppColor.lightPurpleBg2,
                    titleTextColor: AppColor.purpleColor,
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
                            title: "Agreement Value (₹) With TDS",
                            value:
                                bookingModel!.agreementValue.toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "Agreement Value (₹) Without TDS",
                            value:
                                (bookingModel!.agreementValue -
                                        bookingModel!.agreementValueTDS)
                                    .toIndianCurrency(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "TDS (₹)",
                            value:
                                bookingModel!.agreementValueTDS
                                    .toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "GST (%)",
                            value:
                                "${bookingModel!.agreementValueGSTPercentage}%",
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "GST (₹)",
                            value:
                                bookingModel!.agreementValueGSTAmount
                                    .toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "Stamp Duty (%)",
                            value: "${bookingModel!.stampDutyPercentage}%",
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Stamp Duty (₹)",
                            value:
                                bookingModel!.stampDutyAmount
                                    .toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "Registration Fees (₹)",
                            value:
                                bookingModel!.registrationFees
                                    .toIndianCurrency(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Booking Amount (₹)",
                            value:
                                bookingModel!.bookingAmount.toIndianCurrency(),
                          ),
                        ],
                      ),
                      if (bookingModel!.loyaltyAmount > 0)
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Loyalty (%)",
                              value: "${bookingModel!.loyaltyPercentage} %",
                            ),
                            buildColumnTitleValue(
                              title: "Loyalty Amount (₹)",
                              value:
                                  bookingModel!.loyaltyAmount
                                      .toIndianCurrency(),
                            ),
                          ],
                        ),
                      if (bookingModel!.brokerageAmount > 0)
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Brokerage (%)",
                              value: "${bookingModel!.brokeragePercentage} %",
                            ),
                            buildColumnTitleValue(
                              title: "Brokerage Amount (₹)",
                              value:
                                  bookingModel!.brokerageAmount
                                      .toIndianCurrency(),
                            ),
                          ],
                        ),
                      if (bookingModel!.referelAmount > 0)
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Employee Reference (%)",
                              value: "${bookingModel!.referelPercentage} %",
                            ),
                            buildColumnTitleValue(
                              title: "Employee Reference Amount (₹)",
                              value:
                                  bookingModel!.referelAmount
                                      .toIndianCurrency(),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // PAYMENT DETAILS
                  SectionCard(
                    title: "Payment Details",
                    headerBackgroundColor: AppColor.lightYellow,
                    titleTextColor: AppColor.brown,
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "Cheque / RTGS No.",
                            value: bookingModel!.chequeRTGSNumber,
                          ),
                          buildColumnTitleValue(
                            title: "Cheque / RTGS Date",
                            value:
                                bookingModel?.chequeRTGSDate != null
                                    ? formatDateTimeAsDDMMMYYYY(
                                      bookingModel!.chequeRTGSDate!,
                                    )
                                    : "-",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "Bank Name",
                            value: bookingModel!.bankName,
                          ),
                        ],
                      ),
                    ],
                  ),
                  //  OTHER CHARGES
                  SectionCard(
                    title: "Other Charges",
                    headerBackgroundColor: AppColor.lightPurpleBg2,
                    titleTextColor: AppColor.purple,
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      SizedBox(
                        height: 250.0,
                        child:
                            bookingModel!.bookingOtherChargesData.isNotEmpty
                                ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      bookingModel!
                                          .bookingOtherChargesData
                                          .length,
                                  itemBuilder: (_, index) {
                                    final extraCharge =
                                        bookingModel!
                                            .bookingOtherChargesData[index];
                                    final bool isLast =
                                        index ==
                                        bookingModel!
                                                .bookingOtherChargesData
                                                .length -
                                            1;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primary,
                                          width: .3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: isLast ? 0.0 : 10.0,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        spacing: 10,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Value (In ₹)",
                                                value:
                                                    extraCharge.value
                                                        .toIndianCurrency(),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "GST Value (₹)",
                                                value:
                                                    extraCharge.gstValue
                                                        .toIndianCurrency(),
                                              ),
                                              buildColumnTitleValue(
                                                title: "Total Value (₹)",
                                                value:
                                                    (extraCharge.value +
                                                            extraCharge
                                                                .gstValue)
                                                        .toIndianCurrency(),
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
                  // PAYMENT SCHEDULE
                  SectionCard(
                    headerBackgroundColor: AppColor.lightBlueBg2,
                    titleTextColor: AppColor.blue,
                    title:
                        "Payment Schedule (${bookingModel?.paymentScheduleScheme ?? ""})",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      SizedBox(
                        height: 250.0,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 10,
                          ),
                          shrinkWrap: true,
                          itemCount:
                              bookingModel!.bookingPaymentScheduleData.length,
                          itemBuilder: (context, index) {
                            final payment =
                                bookingModel!.bookingPaymentScheduleData[index];
                            final bool isLast =
                                index ==
                                bookingModel!
                                        .bookingPaymentScheduleData
                                        .length -
                                    1;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.only(
                                bottom: isLast ? 0.0 : 10,
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Percentage (%)",
                                        value:
                                            "${payment.paymentSchedulePercentage} %",
                                      ),
                                      buildColumnTitleValue(
                                        title: "Amount Without TDS (₹)",
                                        value:
                                            payment.paymentScheduleAmount
                                                .toIndianCurrency(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "GST Amount (₹)",
                                        value:
                                            payment.paymentScheduleGSTAmount
                                                .toIndianCurrency(),
                                      ),
                                      buildColumnTitleValue(
                                        title: "TDS Amount (₹)",
                                        value:
                                            payment.paymentScheduleTDSAmount
                                                .toIndianCurrency(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      buildColumnTitleValue(
                                        title: "Total Amount With TDS (₹)",
                                        value:
                                            (payment.paymentScheduleAmount +
                                                    payment
                                                        .paymentScheduleTDSAmount)
                                                .toIndianCurrency(),
                                      ),
                                      Spacer(),
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
                  // FLAT ALTERATION REMARKS
                  SectionCard(
                    title: "Unit / Modulation / Customization Remark",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      Text(
                        bookingModel!.flatAlterationRemark.isEmpty
                            ? "-"
                            : bookingModel!.flatAlterationRemark,
                        style: AppTextStyle.ts14M(color: AppColor.black),
                      ),
                    ],
                  ),
                  // PAYMENT REMARK
                  SectionCard(
                    title: "Payment Remarks",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      Text(
                        bookingModel!.paymentRemark.isEmpty
                            ? "-"
                            : bookingModel!.paymentRemark,
                        style: AppTextStyle.ts14M(color: AppColor.black),
                      ),
                    ],
                  ),
                  // OTHER REMARK
                  SectionCard(
                    title: "Other Remarks",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      Text(
                        bookingModel!.otherRemark.isEmpty
                            ? "-"
                            : bookingModel!.otherRemark,
                        style: AppTextStyle.ts14M(color: AppColor.black),
                      ),
                    ],
                  ),
                  // TERMS AND CONDITIONS
                  SectionCard(
                    title: "Terms & Conditions",
                    headerBackgroundColor: AppColor.lightRed,
                    titleTextColor: AppColor.missingInformationRed,
                    maxContentHeight: 450,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            width: 1,
                            color: AppColor.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bookingModel!.termsAndConditionsDescription
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              isHtml
                                  ? Html(
                                    data:
                                        bookingModel!
                                            .termsAndConditionsDescription,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(14),
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                      ),
                                    },
                                  )
                                  : Text(
                                    bookingModel!.termsAndConditionsDescription,
                                    style: AppTextStyle.ts14R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                            ] else ...[
                              Center(
                                child: noDataWidget(
                                  message: "No Terms & Conditions Available",
                                  iconSize: 180,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ACTION DETAILS
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
                            value: bookingModel!.createdBy,
                          ),
                          buildColumnTitleValue(
                            title: "Created Date",
                            value: formatDate(bookingModel!.createdDate),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Modified By",
                            value: bookingModel!.modifiedBy,
                          ),
                          buildColumnTitleValue(
                            title: "Modified Date",
                            value: formatDate(bookingModel!.modifiedDate),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Approval Status",
                            value: bookingModel!.approvalStatus,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // BUILD APPLICANT DETAILS
  Widget _buildApplicantDetailsTab() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SectionCard(
        title: "Applicant Details",
        headerBackgroundColor: AppColor.lightYellowBg2,
        titleTextColor: AppColor.brownYellowText,
        border: Border.all(
          color: AppColor.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: bookingModel!.bookingApplicantData.length,
              itemBuilder: (_, index) {
                final applicant = bookingModel!.bookingApplicantData[index];
                return ApplicantCard(applicant: applicant);
              },
            ),
          ),
        ],
      ),
    );
  }

  // BUILD OTHER CHARGES TAB
  Widget _buildOtherChargesTab() {
    if (bookingModel!.bookingOtherChargesData.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Charges Available", iconSize: 180),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookingModel!.bookingOtherChargesData.length,
              itemBuilder: (context, index) {
                final extraCharge =
                    bookingModel!.bookingOtherChargesData[index];
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
                            value: extraCharge.value.toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "GST (%)",
                            value: extraCharge.gstPercentage.toString(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          buildColumnTitleValue(
                            title: "GST Value (₹)",
                            value: extraCharge.gstValue.toIndianCurrency(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          verticalSpacing(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Builder(
              builder: (_) {
                final extraCharges = bookingModel!.bookingOtherChargesData;
                final double totalGstPercentage = extraCharges.fold(
                  0.0,
                  (sum, item) => sum + item.gstPercentage,
                );
                final double totalValue = extraCharges.fold(
                  0.0,
                  (sum, item) => sum + item.value,
                );

                final double totalGstAmount = extraCharges.fold(
                  0.0,
                  (sum, item) => sum + item.gstValue,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildRowTitleValue(
                      title: "Percentage (%)",
                      value: totalGstPercentage.toString(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                    buildRowTitleValue(
                      title: "Total Value",
                      value: totalValue.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                    buildRowTitleValue(
                      title: "Gst Amount",
                      value: totalGstAmount.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    if (bookingModel!.bookingPaymentScheduleData.isEmpty) {
      return noDataWidget();
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: bookingModel!.bookingPaymentScheduleData.length,
              separatorBuilder: (context, index) => verticalSpacing(),
              itemBuilder: (context, index) {
                final payment = bookingModel!.bookingPaymentScheduleData[index];

                return Container(
                  decoration: commonCardDecoration(),
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
                            value: "${payment.paymentSchedulePercentage} %",
                          ),
                          buildColumnTitleValue(
                            title: "Amount Without TDS(₹)",
                            value:
                                payment.paymentScheduleAmount
                                    .toIndianCurrency(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "GST Amount (₹)",
                            value:
                                payment.paymentScheduleGSTAmount
                                    .toIndianCurrency(),
                          ),
                          buildColumnTitleValue(
                            title: "TDS Amount (₹)",
                            value:
                                payment.paymentScheduleTDSAmount
                                    .toIndianCurrency(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Total Amount With TDS (₹)",
                            value:
                                (payment.paymentScheduleAmount +
                                        payment.paymentScheduleTDSAmount)
                                    .toIndianCurrency(),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          verticalSpacing(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Builder(
              builder: (_) {
                final payments = bookingModel!.bookingPaymentScheduleData;

                final double totalPercentage = payments.fold(
                  0.0,
                  (sum, item) => sum + item.paymentSchedulePercentage,
                );

                final double totalAmount = payments.fold(
                  0.0,
                  (sum, item) => sum + item.paymentScheduleAmount,
                );

                final double totalGSTAmount = payments.fold(
                  0.0,
                  (sum, item) => sum + item.paymentScheduleGSTAmount,
                );

                final double totalTDSAmount = payments.fold(
                  0.0,
                  (sum, item) => sum + item.paymentScheduleTDSAmount,
                );

                final double totalAmountWithTDS = payments.fold(
                  0.0,
                  (sum, item) =>
                      sum +
                      item.paymentScheduleAmount +
                      item.paymentScheduleTDSAmount,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildRowTitleValue(
                      title: "Percentage (%)",
                      value: totalPercentage.addCommas(),
                      singleLine: false,
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                    buildRowTitleValue(
                      title: "Amount Without TDS (₹)",
                      singleLine: false,
                      value: totalAmount.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                    buildRowTitleValue(
                      title: "GST Amount (₹)",
                      singleLine: false,
                      value: totalGSTAmount.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),

                    buildRowTitleValue(
                      title: "TDS Amount (₹)",
                      singleLine: false,
                      value: totalTDSAmount.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),

                    buildRowTitleValue(
                      singleLine: false,
                      title: "Total Amount With TDS (₹)",
                      value: totalAmountWithTDS.toIndianCurrency(),
                      valueTextStyle: AppTextStyle.ts14SB(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // BUILD REMARKS TAB
  Widget _buildRemarkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: "Unit / Modulation / Customization Remark",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                bookingModel!.flatAlterationRemark.isEmpty
                    ? "-"
                    : bookingModel!.flatAlterationRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Payment Related Remark",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                bookingModel!.paymentRemark.isEmpty
                    ? "-"
                    : bookingModel!.paymentRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Other Remark",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Text(
                bookingModel!.otherRemark.isEmpty
                    ? "-"
                    : bookingModel!.otherRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUILD TERMS AND CONDITION TAB
  Widget _buildTermsAndConditionTab() {
    final isHtml =
        bookingModel!.termsAndConditionsDescription.contains('<') &&
        bookingModel!.termsAndConditionsDescription.contains('>');
    return Container(
      padding: EdgeInsets.all(16),
      child:
          bookingModel!.termsAndConditionsDescription.isNotEmpty
              ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: commonCardDecoration(),
                      padding: EdgeInsets.all(16),
                      child:
                          isHtml
                              ? Html(
                                data:
                                    bookingModel!.termsAndConditionsDescription,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(14),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                },
                              )
                              : Text(
                                bookingModel!.termsAndConditionsDescription,
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                  ],
                ),
              )
              : Center(
                child: noDataWidget(message: "No Terms & Conditions Available"),
              ),
    );
  }

  // BUILD PAYMENT DETAILS TAB
  Widget _buildPaymentDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: SectionCard(
            title: "Payment Details",
            border: Border.all(
              color: AppColor.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            children: [
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Booking Amount (₹)",
                    value: bookingModel!.bookingAmount.toIndianCurrency(),
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Cheque/ RTGS Number",
                    value: bookingModel!.chequeRTGSNumber,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Cheque/ RTGS Date",
                    value:
                        bookingModel!.chequeRTGSDate != null
                            ? formatDateTimeAsDDMMMYYYY(
                              bookingModel!.chequeRTGSDate!,
                            )
                            : '-',
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Payment Bank",
                    value: bookingModel!.bankName,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
