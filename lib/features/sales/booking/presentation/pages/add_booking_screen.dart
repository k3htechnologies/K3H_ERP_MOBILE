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
      _communicationAddressC;

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
    super.dispose();
  }

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
  }

  // DISPOSE TEXT CONTROLLERS
  void _disposeTextControllers() {
    _enquiryUniqueCodeC.dispose();
    _permanentAddressC.dispose();
    _communicationAddressC.dispose();
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
                          readOnly: _isEditMode,
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
            margin: EdgeInsets.only(top: 10),
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
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              return Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Project Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.lightBlue,
                        border: Border.all(color: AppColor.primary, width: .5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "Building",
                                value: "",
                              ),
                            ],
                          ),
                        ],
                      ),
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
