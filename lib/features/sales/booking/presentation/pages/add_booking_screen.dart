import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/pages/add_booking_applicant_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBookingScreen extends StatefulWidget {
  final BookingModel? bookingModel;
  final int? index;

  const AddBookingScreen({super.key, this.bookingModel, this.index});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late BookingCubit _bookingCubit;

  // TAB CONTROLLER
  late TabController _tabController;

  // TEXT EDITING CONTROLLER
  late TextEditingController _enquiryUniqueCodeC,
      _permanentAddressC,
      _communicationAddressC,
      _agreementValueWithTdsC,
      _tdsC,
      _agreementValueWithoutTdsC,
      _agreementGstPercentageC,
      _agreementGstAmountC,
      _stampDutyPercentageC,
      _stampDutyAmountC,
      _registrationFeesC;

  final ValueNotifier<double> _agreementValueNotifier = ValueNotifier<double>(
    0.0,
  );

  final ValueNotifier<double> _tdsNotifier = ValueNotifier<double>(0.0);

  final ValueNotifier<double> _withoutTdsNotifier = ValueNotifier<double>(0.0);

  final ValueNotifier<double> _agreementGstAmountNotifier =
      ValueNotifier<double>(0.0);

  final ValueNotifier<double> _stampDutyAmountNotifier = ValueNotifier<double>(
    0.0,
  );

  final ValueNotifier<double> _registrationFeesNotifier = ValueNotifier<double>(
    0.0,
  );

  // SEARCH SYSTEM GENERATED CODE
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  bool _hasPrimaryApplicant(List<BookingApplicantData> applicants) =>
      applicants.any((e) => _isApplicantType(e.applicantType));

  // APPLICANT LIST
  final ValueNotifier<List<BookingApplicantData>> _applicants =
      ValueNotifier<List<BookingApplicantData>>([]);

  //EDIT MODE
  bool get _isEditMode => widget.bookingModel != null;

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _bookingCubit = context.read<BookingCubit>();
    _project = getProject();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _agreementValueNotifier.addListener(_calculateTds);
    if (_isEditMode) {
      _bookingCubit.getBookingListById(
        context,
        1,
        _project.projectId,
        widget.bookingModel!.bookingId,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeTextControllers();
    _bookingCubit.clearEnquiryList();
    _agreementValueNotifier.dispose();
    _tdsNotifier.dispose();
    _withoutTdsNotifier.dispose();
    _agreementGstAmountNotifier.dispose();
    _stampDutyAmountNotifier.dispose();
    _registrationFeesNotifier.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _bookingCubit.onTabChangedAddForm(_tabController.index, context);
    }
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextControllers() {
    _enquiryUniqueCodeC = TextEditingController();
    _permanentAddressC = TextEditingController();
    _communicationAddressC = TextEditingController();
    _agreementValueWithTdsC = TextEditingController();
    _tdsC = TextEditingController();
    _agreementValueWithoutTdsC = TextEditingController();
    _agreementGstPercentageC = TextEditingController();
    _agreementGstAmountC = TextEditingController();
    _stampDutyPercentageC = TextEditingController();
    _stampDutyAmountC = TextEditingController();
    _registrationFeesC = TextEditingController();
  }

  // DISPOSE TEXT CONTROLLERS
  void _disposeTextControllers() {
    _enquiryUniqueCodeC.dispose();
    _permanentAddressC.dispose();
    _communicationAddressC.dispose();
    _agreementValueWithTdsC.dispose();
    _tdsC.dispose();
    _agreementValueWithoutTdsC.dispose();
    _agreementGstPercentageC.dispose();
    _agreementGstAmountC.dispose();
    _stampDutyPercentageC.dispose();
    _stampDutyAmountC.dispose();
    _registrationFeesC.dispose();
  }

  void _calculateTds() {
    final value = _agreementValueNotifier.value;

    const limit = 4999999.99;

    double tds = 0;
    double withoutTds = value;

    if (value > limit) {
      tds = value * 0.01;
      withoutTds = value - tds;
    }

    _tdsNotifier.value = tds;
    _withoutTdsNotifier.value = withoutTds;

    _tdsC.text = tds == 0 ? "" : tds.toStringAsFixed(2);
    _agreementValueWithoutTdsC.text =
        tds == 0 ? "" : withoutTds.toStringAsFixed(2);

    // 🔥 IMPORTANT → always run
    _calculateGst();
    _calculateStampDuty();
    _calculateRegistrationFees();
  }

  void _calculateGst() {
    final agreementValue = _agreementValueNotifier.value;
    final percent = double.tryParse(_agreementGstPercentageC.text) ?? 0;

    if (agreementValue == 0 || percent == 0) {
      _agreementGstAmountNotifier.value = 0;
      _agreementGstAmountC.clear();
      return;
    }

    final amount = agreementValue * percent / 100;

    _agreementGstAmountNotifier.value = amount;
    _agreementGstAmountC.text = amount.toStringAsFixed(2);
  }

  void _calculateStampDuty() {
    final agreementValue = _agreementValueNotifier.value;
    final percent = double.tryParse(_stampDutyPercentageC.text) ?? 0;

    if (agreementValue == 0 || percent == 0) {
      _stampDutyAmountNotifier.value = 0;
      _stampDutyAmountC.clear();
      return;
    }

    final amount = agreementValue * percent / 100;

    _stampDutyAmountNotifier.value = amount;
    _stampDutyAmountC.text = amount.toStringAsFixed(2);
  }

  void _calculateRegistrationFees() {
    final value = _agreementValueNotifier.value;

    if (value == 0) {
      _registrationFeesNotifier.value = 0;
      _registrationFeesC.clear();
      return;
    }

    const limit = 4999999.99;

    double fees;

    if (value <= limit) {
      fees = 30000;
    } else {
      fees = value * 0.01;
    }

    _registrationFeesNotifier.value = fees;
    _registrationFeesC.text = fees.toStringAsFixed(2);
  }

  // OPEN APPLICANT FORM
  Future<void> _openApplicantForm({
    BookingApplicantData? applicant,
    int? index,
  }) async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddBookingApplicantScreen(
              applicant: applicant,
              index: index,
              hasPrimaryApplicant: _hasPrimaryApplicant(_applicants.value),
            ),
      ),
    );

    if (result == null || result['applicant'] == null) return;

    final BookingApplicantData updatedApplicant = result['applicant'];
    final int? updatedIndex = result['index'] as int?;

    final currentApplicants = List<BookingApplicantData>.from(
      _applicants.value,
    );
    final existingApplicantIndex = currentApplicants.indexWhere(
      (e) => _isApplicantType(e.applicantType),
    );
    final bool isUpdatingExisting =
        updatedIndex != null && updatedIndex < currentApplicants.length;
    if (_isApplicantType(updatedApplicant.applicantType) &&
        existingApplicantIndex != -1 &&
        (!isUpdatingExisting || existingApplicantIndex != updatedIndex) &&
        mounted) {
      await showErrorMessage(
        context,
        'Error',
        'Only one Applicant type is allowed.',
      );
      return;
    }

    if (isUpdatingExisting) {
      final int targetIndex = updatedIndex;
      currentApplicants[targetIndex] = updatedApplicant;
    } else {
      currentApplicants.add(updatedApplicant);
    }
    _applicants.value = currentApplicants;
  }

  void _deleteApplicant(int index) {
    final currentApplicants = List<BookingApplicantData>.from(
      _applicants.value,
    );
    if (index < 0 || index >= currentApplicants.length) return;
    currentApplicants.removeAt(index);
    _applicants.value = currentApplicants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking Form",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
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
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [_buildDetails(), _buildExtraCharges()],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD DETAILS
  Widget _buildDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // ENQUIRY SYSTEM GENERATED CODE
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                BlocConsumer<BookingCubit, BookingState>(
                  listener: (context, state) {
                    if (state.enquiryList.isNotEmpty) {
                      final enquiry = state.enquiryList.first;

                      _permanentAddressC.text = enquiry.currentLocation;
                      _communicationAddressC.text = enquiry.currentLocation;
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        CustomTextField(
                          title: "Enquiry Unique Code",
                          isRequired: true,
                          inputFormatterList: [
                            LengthLimitingTextInputFormatter(18),
                          ],
                          hint: "Enter Enquiry Unique Code",
                          textController: _enquiryUniqueCodeC,
                          onChangeFunction: (value) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            if (value.length != 18) {
                              _bookingCubit.clearEnquiryList();
                              _permanentAddressC.clear();
                              _communicationAddressC.clear();
                              return;
                            }

                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                if (value.length == 18) {
                                  _bookingCubit.getEnquiryList(
                                    context,
                                    1,
                                    _project.projectId,
                                    value,
                                  );
                                }
                              },
                            );
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Enquiry Unique Code';
                            }
                            return null;
                          },
                        ),
                        if (state.enquiryList.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.lightBlue,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.primary,
                                width: .5,
                              ),
                            ),
                            child: Column(
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Enquiry Code',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .systemGeneratedCode,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'Name',
                                      value: state.enquiryList.first.name,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Mobile No',
                                      value:
                                          state.enquiryList.first.mobileNumber,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'Source',
                                      value: state.enquiryList.first.source,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Sub Source',
                                      value: state.enquiryList.first.subSource,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'Sales Advisor',
                                      value:
                                          state.enquiryList.first.salesAdvisor,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Sub Source',
                                      value: state.enquiryList.first.subSource,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'Sales Advisor',
                                      value:
                                          state.enquiryList.first.salesAdvisor,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Sourcing Manager',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .sourcingManager,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'Current Location',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .currentLocation,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          verticalSpacing(),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.lightBlue,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.primary,
                                width: .5,
                              ),
                            ),
                            child: Column(
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'Channel Partner',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .channelPartnerName,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'CP Mobile',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .channelPartnerMobileNumber,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: 'CP Team Member',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .channelPartnerTeamMemberName,
                                    ),
                                    buildColumnTitleValue(
                                      title: 'CP Team Mobile',
                                      value:
                                          state
                                              .enquiryList
                                              .first
                                              .channelPartnerTeamMemberMobileNumber,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // APPLICANT
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Applicant Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
                Row(
                  children: [
                    Text("Add Applicant Details", style: AppTextStyle.ts14M()),
                    Spacer(),
                    CustomButton(
                      leading: Icon(Icons.add, size: 18, color: AppColor.white),
                      text: "Add Applicant",
                      onPressed: () async => _openApplicantForm(),
                      backgroundColor: AppColor.primary,
                    ),
                  ],
                ),
                verticalSpacing(),
                ValueListenableBuilder<List<BookingApplicantData>>(
                  valueListenable: _applicants,
                  builder: (context, applicants, child) {
                    if (applicants.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No applicants added yet',
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            applicants
                                .asMap()
                                .entries
                                .map(
                                  (entry) => SizedBox(
                                    width: 320,
                                    child: _buildApplicantCard(
                                      entry.value,
                                      entry.key,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // ADDRESS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Address Details",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Permanent Address",
                  isRequired: true,
                  hint: "Enter Permanent Address",
                  textController: _permanentAddressC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Permanent Address is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Communication Address",
                  isRequired: true,
                  hint: "Enter Communication Address",
                  textController: _communicationAddressC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Communication Address is required";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          // PROJECT DETAILS
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
                      value: widget.bookingModel!.projectName,
                    ),
                    buildColumnTitleValue(
                      title: "Booking Type",
                      value: widget.bookingModel!.bookingType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat",
                      value: widget.bookingModel!.flat,
                    ),
                    buildColumnTitleValue(
                      title: "Wing",
                      value: widget.bookingModel!.wing,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Floor",
                      value: widget.bookingModel!.floor,
                    ),
                    buildColumnTitleValue(
                      title: "Building Number",
                      value: widget.bookingModel!.buildingNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Flat Type",
                      value: widget.bookingModel!.flatType,
                    ),
                    buildColumnTitleValue(
                      title: "Flat Configuration",
                      value: widget.bookingModel!.flatConfiguration,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Carpet Area (SqFt)",
                      value: widget.bookingModel!.reraCarpetAreaSqFt.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PARKING SECTION
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
                      widget.bookingModel!.parkingData.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: widget.bookingModel!.parkingData.length,
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
                          )
                          : Center(child: Text("No Parking")),
                ),
              ],
            ),
          ),
          // AGREEMENT DETAILS
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Agreement Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                CustomTextField(
                  title: "Agreement Value (With TDS) (₹)",
                  hint: "Enter Agreement Value (with TDS)",
                  isRequired: true,
                  textController: _agreementValueWithTdsC,
                  keyboardType: TextInputType.number,
                  onChangeFunction: (value) {
                    final parsed = double.tryParse(value) ?? 0.0;
                    _agreementValueNotifier.value = parsed;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Agreement Value (with TDS) is required";
                    }
                    return null;
                  },
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _tdsNotifier,
                  builder: (_, tds, __) {
                    return CustomTextField(
                      readOnly: true,
                      title: "TDS (₹)",
                      hint: "TDS",
                      textController: _tdsC,
                    );
                  },
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _withoutTdsNotifier,
                  builder: (_, value, __) {
                    return CustomTextField(
                      readOnly: true,
                      title: "Agreement Value (Without TDS) (₹)",
                      hint: "Agreement Value (without TDS)",
                      textController: _agreementValueWithoutTdsC,
                    );
                  },
                ),
              ],
            ),
          ),
          // TAX DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tax Details", style: AppTextStyle.ts16SB()),
                Column(
                  children: [
                    CustomTextField(
                      isRequired: true,
                      title: "Agreement GST (%)",
                      hint: "Enter Agreement GST Percentage",
                      textController: _agreementGstPercentageC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Agreement GST Percentage is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _agreementGstAmountNotifier,
                      builder: (_, value, __) {
                        return CustomTextField(
                          readOnly: true,
                          title: "Agreement GST Amount (₹)",
                          hint: "Agreement GST Amount",
                          textController: _agreementGstAmountC,
                        );
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Stamp Duty (%)",
                      hint: "Enter Stamp Duty Percentage",
                      textController: _stampDutyPercentageC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Stamp Duty Percentage is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _stampDutyAmountNotifier,
                      builder: (_, value, __) {
                        return CustomTextField(
                          readOnly: true,
                          title: "Stamp Duty Amount (₹)",
                          hint: "Stamp Duty Amount",
                          textController: _stampDutyAmountC,
                        );
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _registrationFeesNotifier,
                      builder: (_, value, __) {
                        return CustomTextField(
                          readOnly: true,
                          title: "Registration Fees (₹)",
                          hint: "Registration Fees",
                          textController: _registrationFeesC,
                        );
                      },
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

  // BUILD EXTRA CHARGES
  Widget _buildExtraCharges() {
    return Container();
  }

  // BUILD APPLICANT CARD
  Widget _buildApplicantCard(BookingApplicantData applicant, int index) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.applicantName, style: AppTextStyle.ts14M()),
                    verticalSpacing(height: 4),
                    Text(
                      applicant.applicantType,
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  CustomIconButton.edit(
                    onPressed:
                        () => _openApplicantForm(
                          applicant: applicant,
                          index: index,
                        ),
                  ),
                  horizontalSpacing(width: 8),
                  CustomIconButton.delete(
                    onPressed: () => _deleteApplicant(index),
                  ),
                ],
              ),
            ],
          ),
          verticalSpacing(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailField(
                  "Contact No.",
                  applicant.applicantMobileNumber,
                ),
              ),
              Expanded(
                child: _buildDetailField("Email", applicant.applicantEmailId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUILD DETAIL FIELD
  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts12R(color: AppColor.grey)),
          Text(
            value.isEmpty ? "-" : value,
            style: AppTextStyle.ts14R(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
