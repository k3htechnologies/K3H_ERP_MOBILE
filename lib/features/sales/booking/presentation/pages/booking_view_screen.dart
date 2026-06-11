import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
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
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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

  // FOR TERMS AND CONDITIONS EXPANSION TILE
  late ValueNotifier<bool> isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = ValueNotifier(false);
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChange);
    _bookingCubit = context.read<BookingCubit>();
    loadBooking();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    isExpanded.dispose();
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
                    padding: EdgeInsets.all(20.0),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: showSiteSelectedWidget(),
                  ),
                  ChipStyleTabBar(
                    isSecondaryStyle: true,
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
              )
              : Text("data");
        },
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
                    value:
                        "${enquiry.mobileNumberCountryCode} ${enquiry.mobileNumber}",
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
                  infoCard(items, title: "Enquiry Details"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              value:
                                  "${enquiry.channelPartnerMobileNumberCountryCode} ${enquiry.channelPartnerMobileNumber}",
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
                              value:
                                  "${enquiry.channelPartnerTeamMemberMobileNumberCountryCode} ${enquiry.channelPartnerTeamMemberMobileNumber}",
                            ),
                          },
                          {
                            "title": "CP Team E-mail ID",
                            "value": enquiry.channelPartnerTeamMemberEmailId,
                            "widget": CustomClickToContactText(
                              value: enquiry.channelPartnerTeamMemberEmailId,
                              type: ContactType.email,
                            ),
                          },
                        ]),
                    ],
                  ),
                ],
              );
            },
          ), // APPLICANT SECTION
          verticalSpacing(),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Applicant Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                SizedBox(
                  height: 250.0,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: bookingModel!.bookingApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant =
                          bookingModel!.bookingApplicantData[index];
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
                            "widget": CustomClickToContactText(
                              value:
                                  "${applicant.applicantMobileNumberCountryCode} ${applicant.applicantMobileNumber}",
                              type: ContactType.phone,
                            ),
                          },
                          {
                            "title": "Email ID",
                            "value": applicant.applicantEmailId,
                            "widget": CustomClickToContactText(
                              value: applicant.applicantEmailId,
                              type: ContactType.email,
                            ),
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
          verticalSpacing(),
          // PROJECT DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
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
          ),
          verticalSpacing(),
          // PARKING SECTION
          Container(
            height: 450,
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Parking Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child:
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
                ),
              ],
            ),
          ),
          verticalSpacing(),
          // BOOKING DETAILS SECTION
          Container(
            decoration: commonCardDecoration(),
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
                      value: bookingModel!.agreementValue.toIndianCurrency(),
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
                      value: bookingModel!.agreementValueTDS.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "GST (%)",
                      value: "${bookingModel!.agreementValueGSTPercentage}%",
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
                      value: bookingModel!.stampDutyAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: bookingModel!.registrationFees.toIndianCurrency(),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: bookingModel!.bookingAmount.toIndianCurrency(),
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
                        value: bookingModel!.loyaltyAmount.toIndianCurrency(),
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
                        value: bookingModel!.brokerageAmount.toIndianCurrency(),
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
                        value: bookingModel!.referelAmount.toIndianCurrency(),
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
                verticalSpacing(),
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
          ),
          // OTHER CHARGES SECTION
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Other Charges", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                SizedBox(
                  height: 250.0,
                  child:
                      bookingModel!.bookingOtherChargesData.isNotEmpty
                          ? ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                bookingModel!.bookingOtherChargesData.length,
                            itemBuilder: (_, index) {
                              final extraCharge =
                                  bookingModel!.bookingOtherChargesData[index];
                              final bool isLast =
                                  index ==
                                  bookingModel!.bookingOtherChargesData.length -
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Schedule", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                SizedBox(
                  height: 250.0,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: bookingModel!.bookingPaymentScheduleData.length,
                    itemBuilder: (context, index) {
                      final payment =
                          bookingModel!.bookingPaymentScheduleData[index];
                      final bool isLast =
                          index ==
                          bookingModel!.bookingPaymentScheduleData.length - 1;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primary,
                            width: .3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: isLast ? 0.0 : 10),
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildColumnTitleValue(
                                  title: "Percentage (%)",
                                  value:
                                      "${payment.paymentSchedulePercentage} %",
                                ),
                                buildColumnTitleValue(
                                  title: "Amount (₹)",
                                  value:
                                      payment.paymentScheduleAmount
                                          .toIndianCurrency(),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildColumnTitleValue(
                                  title: "Amount (₹) Without TDS",
                                  value:
                                      payment.paymentScheduleAmount
                                          .toIndianCurrency(),
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
                      value: bookingModel!.flatAlterationRemark,
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
                      value: bookingModel!.paymentRemark,
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
                      value: bookingModel!.otherRemark,
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
                    bookingModel!.termsAndConditionsDescription
                        .trim()
                        .isNotEmpty;
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
                            data: bookingModel!.termsAndConditionsDescription,
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
      itemCount: bookingModel!.bookingApplicantData.length,
      itemBuilder: (_, index) {
        final applicant = bookingModel!.bookingApplicantData[index];

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
              "widget": CustomClickToContactText(
                value:
                    "${applicant.applicantMobileNumberCountryCode} ${applicant.applicantMobileNumber}",
                type: ContactType.phone,
              ),
            },
            {
              "title": "Email ID",
              "value": applicant.applicantEmailId,
              "widget": CustomClickToContactText(
                value: applicant.applicantEmailId,
                type: ContactType.email,
              ),
            },
            {"title": "Aadhaar Card No.", "value": applicant.aadharCardNumber},
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
            {"title": "PAN Card No.", "value": applicant.panNumber},
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
            {"title": "Voting ID No.", "value": applicant.votingIdNumber},
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
            {"title": "Passport No.", "value": applicant.passportNumber},
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
                    showFilePreviewDialog(context, applicant.poaurl.split(","));
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
                  if (applicant.statementOfSourceOfFundsURL.isNotEmpty) {
                    showFilePreviewDialog(
                      context,
                      applicant.statementOfSourceOfFundsURL.split(","),
                    );
                  }
                },
                isDisable: applicant.statementOfSourceOfFundsURL.isEmpty,
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
    );
  }

  // BUILD OTHER CHARGES TAB
  Widget _buildOtherChargesTab() {
    if (bookingModel!.bookingOtherChargesData.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Charges Available", iconSize: 180),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: bookingModel!.bookingOtherChargesData.length,
      itemBuilder: (context, index) {
        final extraCharge = bookingModel!.bookingOtherChargesData[index];
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
    );
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    if (bookingModel!.bookingPaymentScheduleData.isEmpty) {
      return noDataWidget();
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shrinkWrap: true,
      itemCount: bookingModel!.bookingPaymentScheduleData.length,
      itemBuilder: (context, index) {
        final payment = bookingModel!.bookingPaymentScheduleData[index];
        return Container(
          decoration: commonCardDecoration(),
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
                  buildColumnTitleValue(title: "Type", value: payment.type),
                  payment.type.contains("Date")
                      ? buildColumnTitleValue(
                        title: "Date",
                        value:
                            payment.date != null
                                ? formatDateTimeAsDDMMMYYYY(payment.date!)
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
                    title: "Amount (₹)",
                    value: payment.paymentScheduleAmount.toIndianCurrency(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "GST Amount (₹)",
                    value: payment.paymentScheduleGSTAmount.toIndianCurrency(),
                  ),
                  buildColumnTitleValue(
                    title: "TDS Amount (₹)",
                    value: payment.paymentScheduleTDSAmount.toIndianCurrency(),
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
                      value: bookingModel!.flatAlterationRemark,
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
                      value: bookingModel!.paymentRemark,
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
                Text("Other Remark", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Other Remark",
                      value: bookingModel!.otherRemark,
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
      ),
    );
  }
}
