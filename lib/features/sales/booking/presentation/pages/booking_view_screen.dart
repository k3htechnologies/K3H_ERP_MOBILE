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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
                    child: showSiteSelectedWidget(),
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
              final bool isDirectWalking = enquiry.source == "Direct Walking";
              final bool isAdvertisement = enquiry.subSource == "Advertisement";
              final bool isEmployeeReference =
                  enquiry.subSource == "Employee Reference";
              final bool isLoyalty = enquiry.subSource == "Loyalty";
              final bool isReference = enquiry.subSource == "Reference";

              final List<Map<String, dynamic>> items = [];

              /// BASIC INFO
              items.addAll([
                {"title": "Unique Code", "value": enquiry.systemGeneratedCode},
                {"title": "Name", "value": enquiry.name},
                {"title": "Mobile No.", "value": enquiry.mobileNumber},
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

              /// CHANNEL PARTNER
              if (isChannelPartner) {
                items.addAll([
                  {"title": "CP Name", "value": enquiry.channelPartnerName},
                  {
                    "title": "CP Mobile No.",
                    "value": enquiry.channelPartnerMobileNumber,
                  },
                  {
                    "title": "CP Designation",
                    "value": enquiry.channelPartnerDesignation,
                  },
                  {
                    "title": "CP Company Name",
                    "value": enquiry.channelPartnerCompany,
                  },
                  {
                    "title": "CP Firm Type",
                    "value": enquiry.channelPartnerFirmsType,
                  },
                  {"title": "CP Type", "value": enquiry.channelPartnerType},
                  if (enquiry.channelPartnerTeamMemberName.isNotEmpty)
                    {
                      "title": "CP Team Member Name",
                      "value": enquiry.channelPartnerTeamMemberName,
                    },
                  if (enquiry.channelPartnerTeamMemberMobileNumber.isNotEmpty)
                    {
                      "title": "CP Team Member Mobile",
                      "value": enquiry.channelPartnerTeamMemberMobileNumber,
                      "customValueWidget": CustomClickToContactText(
                        value: enquiry.channelPartnerTeamMemberMobileNumber,
                        type: ContactType.phone,
                      ),
                    },
                ]);
              }

              /// EMPLOYEE REFERENCE
              if (isDirectWalking && isEmployeeReference) {
                items.addAll([
                  {
                    "title": "Employee Ref Name",
                    "value": enquiry.employeeReferenceName,
                  },
                  {
                    "title": "Employee Ref Mobile",
                    "value": enquiry.employeeReferenceMobileNumber,
                  },
                ]);
              }

              /// LOYALTY
              if (isDirectWalking && isLoyalty) {
                items.addAll([
                  {
                    "title": "Project",
                    "value": enquiry.loyaltyExistingProjectName,
                  },
                  {
                    "title": "Unit No",
                    "value": enquiry.loyaltyExistingUnitNumber,
                  },
                  {
                    "title": "Owner",
                    "value": enquiry.loyaltyExistingUnitOwnerName,
                  },
                ]);
              }

              /// REFERENCE
              if (isDirectWalking && isReference) {
                items.addAll([
                  {"title": "Project", "value": enquiry.referralProjectName},
                  {"title": "Unit No", "value": enquiry.referralUnitNumber},
                  {"title": "Owner", "value": enquiry.referralUnitOwnerName},
                ]);
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

              return infoCard(items, title: "Enquiry Details");
            },
          ), // APPLICANT SECTION
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
                    itemCount: bookingModel!.bookingApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant =
                          bookingModel!.bookingApplicantData[index];
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
                                  title: "Mobile Number",
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
                                  title: "Cancelled Cheque",
                                  value:
                                      applicant.cancelledChequeUrl.isEmpty
                                          ? "-"
                                          : applicant.cancelledChequeUrl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .cancelledChequeUrl
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.cancelledChequeUrl
                                                  .split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant
                                                .cancelledChequeUrl
                                                .isEmpty,
                                      ),
                                ),
                                buildColumnTitleValue(
                                  title: "POA (if NRI Execution)",
                                  value:
                                      applicant.poaurl.isEmpty
                                          ? "-"
                                          : applicant.poaurl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
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
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Income Docs (Form 16 / ITR)",
                                  value:
                                      applicant.incomeForm16Itrurl.isEmpty
                                          ? "-"
                                          : applicant.incomeForm16Itrurl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .incomeForm16Itrurl
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.incomeForm16Itrurl
                                                  .split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant
                                                .cancelledChequeUrl
                                                .isEmpty,
                                      ),
                                ),
                                buildColumnTitleValue(
                                  title: "NRE / NRO Bank Details",
                                  value:
                                      applicant.nreNroBankDetailsUrl.isEmpty
                                          ? "-"
                                          : applicant.nreNroBankDetailsUrl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .nreNroBankDetailsUrl
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.nreNroBankDetailsUrl
                                                  .split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant
                                                .nreNroBankDetailsUrl
                                                .isEmpty,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Nominee Form",
                                  value:
                                      applicant.nomineeFormUrl.isEmpty
                                          ? "-"
                                          : applicant.nomineeFormUrl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .nomineeFormUrl
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.nomineeFormUrl.split(
                                                ",",
                                              ),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant
                                                .cancelledChequeUrl
                                                .isEmpty,
                                      ),
                                ),
                                buildColumnTitleValue(
                                  title: "NRE / NRO Bank Details",
                                  value:
                                      applicant.nreNroBankDetailsUrl.isEmpty
                                          ? "-"
                                          : applicant.nreNroBankDetailsUrl,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        onPressed: () {
                                          if (applicant
                                              .nreNroBankDetailsUrl
                                              .isNotEmpty) {
                                            showFilePreviewDialog(
                                              context,
                                              applicant.nreNroBankDetailsUrl
                                                  .split(","),
                                            );
                                          }
                                        },
                                        isDisable:
                                            applicant
                                                .nreNroBankDetailsUrl
                                                .isEmpty,
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
                        bookingModel!.registrationDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Handover Type",
                      value: bookingModel!.handoverType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Source Of Funding",
                      value: bookingModel!.sourceOfFunding,
                    ),
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
                      value: addCommasToInteger(bookingModel!.agreementValue),
                    ),
                    buildColumnTitleValue(
                      title: "Agreement Value (₹) Without TDS",
                      value: addCommasToInteger(
                        bookingModel!.agreementValue -
                            bookingModel!.agreementValueTDS,
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
                      value: addCommasToInteger(
                        bookingModel!.agreementValueTDS,
                      ),
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
                      value: addCommasToInteger(
                        bookingModel!.agreementValueGSTAmount,
                      ),
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
                      value: addCommasToInteger(bookingModel!.stampDutyAmount),
                    ),
                    buildColumnTitleValue(
                      title: "Registration Fees (₹)",
                      value: addCommasToInteger(bookingModel!.registrationFees),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Booking Amount (₹)",
                      value: addCommasToInteger(bookingModel!.bookingAmount),
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
                        value: addCommasToInteger(bookingModel!.loyaltyAmount),
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
                        value: addCommasToInteger(
                          bookingModel!.brokerageAmount,
                        ),
                      ),
                    ],
                  ),
                if (bookingModel!.employeeReferenceAmount > 0)
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Employee Reference (%)",
                        value: "${bookingModel!.employeeReferencePercentage} %",
                      ),
                      buildColumnTitleValue(
                        title: "Employee Reference Amount (₹)",
                        value: addCommasToInteger(
                          bookingModel!.employeeReferenceAmount,
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
                      bookingModel!.bookingOtherChargesData.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount:
                                bookingModel!.bookingOtherChargesData.length,
                            itemBuilder: (_, index) {
                              final extraCharge =
                                  bookingModel!.bookingOtherChargesData[index];
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
                    itemCount: bookingModel!.bookingPaymentScheduleData.length,
                    itemBuilder: (context, index) {
                      final payment =
                          bookingModel!.bookingPaymentScheduleData[index];
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
                    title: "Mobile Number",
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
                    title: "Cancelled Cheque",
                    value:
                        applicant.cancelledChequeUrl.isEmpty
                            ? "-"
                            : applicant.cancelledChequeUrl,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                  buildColumnTitleValue(
                    title: "POA (if NRI Execution)",
                    value: applicant.poaurl.isEmpty ? "-" : applicant.poaurl,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Income Docs (Form 16 / ITR)",
                    value:
                        applicant.incomeForm16Itrurl.isEmpty
                            ? "-"
                            : applicant.incomeForm16Itrurl,
                    customValueWidget: CustomButton.documentOutline(
                      onPressed: () {
                        if (applicant.incomeForm16Itrurl.isNotEmpty) {
                          showFilePreviewDialog(
                            context,
                            applicant.incomeForm16Itrurl.split(","),
                          );
                        }
                      },
                      isDisable: applicant.cancelledChequeUrl.isEmpty,
                    ),
                  ),
                  buildColumnTitleValue(
                    title: "NRE / NRO Bank Details",
                    value:
                        applicant.nreNroBankDetailsUrl.isEmpty
                            ? "-"
                            : applicant.nreNroBankDetailsUrl,
                    customValueWidget: CustomButton.documentOutline(
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
                  ),
                ],
              ),
              Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Nominee Form",
                    value:
                        applicant.nomineeFormUrl.isEmpty
                            ? "-"
                            : applicant.nomineeFormUrl,
                    customValueWidget: CustomButton.documentOutline(
                      onPressed: () {
                        if (applicant.nomineeFormUrl.isNotEmpty) {
                          showFilePreviewDialog(
                            context,
                            applicant.nomineeFormUrl.split(","),
                          );
                        }
                      },
                      isDisable: applicant.cancelledChequeUrl.isEmpty,
                    ),
                  ),
                  buildColumnTitleValue(
                    title: "NRE / NRO Bank Details",
                    value:
                        applicant.nreNroBankDetailsUrl.isEmpty
                            ? "-"
                            : applicant.nreNroBankDetailsUrl,
                    customValueWidget: CustomButton.documentOutline(
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
                    value: addCommasToInteger(extraCharge.value),
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
                    value: addCommasToInteger(extraCharge.gstValue),
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
                    value: addCommasToInteger(payment.paymentScheduleAmount),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "GST Amount (₹)",
                    value: addCommasToInteger(payment.paymentScheduleGSTAmount),
                  ),
                  buildColumnTitleValue(
                    title: "TDS Amount (₹)",
                    value: addCommasToInteger(payment.paymentScheduleTDSAmount),
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
                      title: "Booking Amount",
                      value: addCommasToInteger(bookingModel!.bookingAmount),
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
