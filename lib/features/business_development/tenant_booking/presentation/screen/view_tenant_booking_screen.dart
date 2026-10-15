import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/cubit/tenant_booking_cubit.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/cubit/tenant_booking_state.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
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

class ViewTenantBookingScreen extends StatefulWidget {
  final int bookingId;
  final int projectId;

  const ViewTenantBookingScreen({
    super.key,
    required this.bookingId,
    required this.projectId,
  });

  @override
  State<ViewTenantBookingScreen> createState() =>
      _ViewTenantBookingScreenState();
}

class _ViewTenantBookingScreenState extends State<ViewTenantBookingScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late TenantBookingCubit _bookingCubit;
  late BookingModel? bookingModel;

  // FOR TERMS AND CONDITIONS EXPANSION TILE
  late ValueNotifier<bool> isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = ValueNotifier(false);
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChange);
    _bookingCubit = context.read<TenantBookingCubit>();
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
      _bookingCubit.getTenantList(
        context: context,
        pageNumber: 1,
        projectId: widget.projectId,
        tenantId: bookingModel!.tenantId,
        buildingId: bookingModel!.tenantBuildingId,
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
        screenTitle: "Tenant Booking",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<TenantBookingCubit, TenantBookingState>(
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

  Widget _buildOverviewTab() {
    final isHtml =
        bookingModel!.termsAndConditionsDescription.contains('<') &&
        bookingModel!.termsAndConditionsDescription.contains('>');
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          BlocBuilder<TenantBookingCubit, TenantBookingState>(
            builder: (context, state) {
              if (state.tenantList.isEmpty) {
                return const SizedBox();
              }
              final tenant = state.tenantList.first;
              return Column(
                children: [
                  SectionCard(
                    title: "Existing Unit Details",
                    titleTextColor: AppColor.darkBlue29,
                    headerBackgroundColor: AppColor.darkBlue29.withValues(
                      alpha: 0.1,
                    ),
                    children: [
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Tenant Code",
                            value: tenant.systemGeneratedCode,
                          ),
                          buildColumnTitleValue(
                            title: "Unit / Annexure / Survey Number",
                            value: tenant.unitAnnexureSurveyNumber,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Building Name",
                            value: bookingModel?.tenantBuildingName,
                          ),
                          buildColumnTitleValue(
                            title: "Unit Type",
                            value: tenant.unitType,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildColumnTitleValue(
                            title: "Unit Configuration",
                            value: tenant.unitConfiguration,
                          ),
                          buildColumnTitleValue(
                            title: "Unit Carpet Area (SqFt)",
                            value: tenant.unitCarpetAreaSqFt.addCommas(),
                          ),
                        ],
                      ),
                      buildColumnTitleValue(
                        title: "Unit Facing",
                        value: tenant.unitFacing,
                        removeExpanded: true,
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Eligibility Details in Carpet Area (SqFt)',
                    titleTextColor: AppColor.brown,
                    headerBackgroundColor: AppColor.lightYellow,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "Extra Free Carpet Area Offered (%)",
                            value:
                                tenant.extraFreeCarpetAreaOfferedPercent
                                    .addCommas(),
                          ),
                          buildColumnTitleValue(
                            title: "Free MOFA Carpet Area (SqFt)",
                            value: tenant.freeMOFACarpetAreaSqFt.addCommas(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "Existing Terrace Area (SqFt)",
                            value: tenant.existingTerraceAreaSqFt.addCommas(),
                          ),
                          buildColumnTitleValue(
                            title: "New Eligibility MOFA Carpet Area (SqFt)",
                            value:
                                tenant.newEligibilityMOFACarpetAreaSqFt
                                    .addCommas(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "New Eligibility RERA Carpet Area (SqFt)",
                            value:
                                tenant.newEligibilityRERACarpetAreaSqFt
                                    .addCommas(),
                          ),
                          buildColumnTitleValue(
                            title: "(A) Area Against Terrace (SqFt)",
                            value: tenant.areaAgainstTerraceSqFt.addCommas(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "MOFA Carpet Area Purchased (SqFt)",
                            value:
                                tenant.mofaCarpetAreaPurchasedSqFt.addCommas(),
                          ),
                          buildColumnTitleValue(
                            title: "RERA Carpet Area Purchased (SqFt)",
                            value:
                                tenant.reraCarpetAreaPurchasedSqFt.addCommas(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "(B) Deck Area (SqFt)",
                            value: tenant.deckAreaSqFt.addCommas(),
                          ),
                          buildColumnTitleValue(
                            title: "Total New MOFA Carpet Area (SqFt)",
                            value:
                                tenant.totalNewMOFACarpetAreaSqFt.addCommas(),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          buildColumnTitleValue(
                            title: "(C) Total New RERA Carpet Area (SqFt)",
                            value:
                                tenant.totalNewRERACarpetAreaSqFt.addCommas(),
                          ),
                        ],
                      ),
                      buildRowWrapper(
                        child: buildColumnTitleValue(
                          title:
                              "Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)",
                          value:
                              (tenant.totalNewRERACarpetAreaSqFt +
                                      tenant.deckAreaSqFt +
                                      tenant.areaAgainstTerraceSqFt)
                                  .addCommas(),
                        ),
                      ),
                      buildRowWrapper(
                        child: buildColumnTitleValue(
                          title: "Remark",
                          value: tenant.remark,
                        ),
                      ),
                    ],
                  ),
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
                                  _buildApplicantTypeWidget(
                                    applicant.applicantType,
                                  ),
                                ],
                              ),

                              [
                                {
                                  "title": "Mobile Number",
                                  "value": applicant.applicantMobileNumber,
                                  "widget": CustomClickToContactText(
                                    countryCode:
                                        applicant
                                            .applicantMobileNumberCountryCode,
                                    value: applicant.applicantMobileNumber,
                                    type: ContactType.phone,
                                  ),
                                },
                                {
                                  "title": "E-Mail ID",
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
                                          title: "Aadhaar Card",
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
                                          title: "PAN Card.",
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
                                      if (applicant
                                          .drivingLicenseURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "Driving License",
                                          applicant.drivingLicenseURL.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant.drivingLicenseURL.isEmpty,
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
                                          title: "Voting ID",
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
                                          title: "Passport",
                                          applicant.passportURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable: applicant.passportURL.isEmpty,
                                  ),
                                },
                                {
                                  "title": "GST No.",
                                  "value": applicant.gstNumber,
                                },
                                {
                                  "title": "GST Certificate",
                                  "value": applicant.gstNumberURL,
                                  "widget": CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant.gstNumberURL.isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "GST Certificate",
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
                                      if (applicant
                                          .cancelledChequeUrl
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "Cancelled Cheque",
                                          applicant.cancelledChequeUrl.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant.cancelledChequeUrl.isEmpty,
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
                                          title: "POA (if NRI Execution)",
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
                                      if (applicant
                                          .incomeForm16Itrurl
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "Income Docs (Form 16 / ITR)",
                                          applicant.incomeForm16Itrurl.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant.incomeForm16Itrurl.isEmpty,
                                  ),
                                },
                                {
                                  "title": "NRE / NRO Bank Details",
                                  "value": applicant.nreNroBankDetailsUrl,
                                  "widget": CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .nreNroBankDetailsUrl
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "NRE / NRO Bank Details",
                                          applicant.nreNroBankDetailsUrl.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant.nreNroBankDetailsUrl.isEmpty,
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
                                          title: "Nominee Form",
                                          applicant.nomineeFormUrl.split(","),
                                        );
                                      }
                                    },
                                    isDisable: applicant.nomineeFormUrl.isEmpty,
                                  ),
                                },
                                {
                                  "title": "Statement Of Source Of Funds",
                                  "value":
                                      applicant.statementOfSourceOfFundsURL,
                                  "widget": CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .statementOfSourceOfFundsURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "Statement Of Source Of Funds",
                                          applicant.statementOfSourceOfFundsURL
                                              .split(","),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant
                                            .statementOfSourceOfFundsURL
                                            .isEmpty,
                                  ),
                                },

                                {
                                  "title": "Payment Proof",
                                  "value": applicant.paymentProofURL,
                                  "widget": CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .paymentProofURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          title: "Payment Proof",
                                          applicant.paymentProofURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable:
                                        applicant.paymentProofURL.isEmpty,
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
                                          title: "Profile Photo",
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
                  SectionCard(
                    title: "Unit / Modulation / Customization Remark",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      buildColumnTitleValue(
                        title: "Remarks",
                        value: bookingModel!.flatAlterationRemark,
                        removeExpanded: true,
                      ),
                    ],
                  ),
                  SectionCard(
                    title: "Payment Remarks",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      buildColumnTitleValue(
                        title: "Remarks",
                        value: bookingModel!.paymentRemark,
                        removeExpanded: true,
                      ),
                    ],
                  ),
                  SectionCard(
                    title: "Other Remarks",
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    children: [
                      buildColumnTitleValue(
                        title: "Remarks",
                        value: bookingModel!.otherRemark,
                        removeExpanded: true,
                      ),
                    ],
                  ),
                  SectionCard(
                    title: "Terms & Conditions",
                    headerBackgroundColor: AppColor.lightRed,
                    titleTextColor: AppColor.missingInformationRed,
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
                                //TODO : ASK DESIGNER
                                //
                                // InkWell(
                                //   onTap: () {
                                //     isExpanded.value = !isExpanded.value;
                                //   },
                                //   child: SizedBox(
                                //     width: double.infinity,
                                //     child: Row(
                                //       children: [
                                //         Expanded(
                                //           child: Text(
                                //             "Terms & Conditions",
                                //             style: AppTextStyle.ts16SB(),
                                //           ),
                                //         ),
                                //         Icon(
                                //           value
                                //               ? Icons.keyboard_arrow_up
                                //               : Icons.keyboard_arrow_down,
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                if (hasData) ...[
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
                                        bookingModel!
                                            .termsAndConditionsDescription,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                ] else if (value && !hasData) ...[
                                  Center(
                                    child: noDataWidget(
                                      message:
                                          "No Terms & Conditions Available",
                                      iconSize: 180,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildApplicantDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SectionCard(
        title: "Applicant Details",
        headerBackgroundColor: AppColor.lightYellowBg2,
        titleTextColor: AppColor.brownYellowText,
        border: Border.all(
          color: AppColor.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        children: [
          for (final applicant in bookingModel!.bookingApplicantData)
            infoCard(
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
                    countryCode: applicant.applicantMobileNumberCountryCode,
                    value: applicant.applicantMobileNumber,
                    type: ContactType.phone,
                  ),
                },
                {
                  "title": "E-Mail ID",
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
                _docEntry(context, "Aadhaar Card", applicant.aadharCardURL),
                {"title": "PAN Card No.", "value": applicant.panNumber},
                _docEntry(context, "PAN Card", applicant.panCardURL),
                {
                  "title": "Driving License No.",
                  "value": applicant.drivingLicenseNumber,
                },
                _docEntry(
                  context,
                  "Driving License",
                  applicant.drivingLicenseURL,
                ),
                {"title": "Voting ID No.", "value": applicant.votingIdNumber},
                _docEntry(context, "Voting ID", applicant.votingIdURL),
                {"title": "Passport No.", "value": applicant.passportNumber},
                _docEntry(context, "Passport", applicant.passportURL),
                {"title": "GST No.", "value": applicant.gstNumber},
                _docEntry(context, "GST Certificate", applicant.gstNumberURL),
                _docEntry(
                  context,
                  "Cancelled Cheque",
                  applicant.cancelledChequeUrl,
                ),
                _docEntry(context, "POA (if NRI Execution)", applicant.poaurl),
                _docEntry(
                  context,
                  "Income Docs (Form 16 / ITR)",
                  applicant.incomeForm16Itrurl,
                ),
                _docEntry(
                  context,
                  "NRE / NRO Bank Details",
                  applicant.nreNroBankDetailsUrl,
                ),
                _docEntry(context, "Nominee Form", applicant.nomineeFormUrl),
                _docEntry(
                  context,
                  "Statement Of Source Of Funds",
                  applicant.statementOfSourceOfFundsURL,
                ),
                _docEntry(context, "Payment Proof", applicant.paymentProofURL),
                _docEntry(context, "Profile Photo", applicant.photoURL),
              ],
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _docEntry(
    BuildContext context,
    String title,
    String url,
  ) {
    return {
      "title": title,
      "value": url,
      "widget": CustomButton.documentOutline(
        onPressed: () {
          if (url.isNotEmpty) {
            showFilePreviewDialog(context, title: title, url.split(","));
          }
        },
        isDisable: url.isEmpty,
      ),
    };
  }

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

  Widget _buildRemarkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: "Unit / Modulation / Customization Remark",
            children: [
              Text(
                bookingModel!.flatAlterationRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Payment Related Remark",
            children: [
              Text(
                bookingModel!.paymentRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
          SectionCard(
            title: "Other Remark",
            children: [
              Text(
                bookingModel!.otherRemark,
                style: AppTextStyle.ts14M(color: AppColor.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
