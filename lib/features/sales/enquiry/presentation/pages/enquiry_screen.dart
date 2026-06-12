import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryScreen extends StatefulWidget {
  final String? enquiryName;
  final String? enquiryCode;
  const EnquiryScreen({super.key, this.enquiryName, this.enquiryCode});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  // CUBIT
  late EnquiryCubit _enquiryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _systemCodeC,
      _mobileNumberC,
      _budgetC,
      _requirementTypeC,
      _channelPartnerMobileC,
      _nationalityC,
      _currentLocationC,
      _customerClassificationC,
      _ethnicityC,
      _salesAdvisorC,
      _sourcingManagerC,
      _accommodationC,
      _followUpDaysC,
      _finalStageC;
  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);
  final closedStatuses = ['booking done', 'cancelled', 'lost'];
  final ValueNotifier<Map<String, dynamic>?> _selectedSourceNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSubSourceNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.enquiry]!;
    _initializeTextEditingController();
    _onScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnquiry();
    });
  }

  void _loadEnquiry() {
    if (widget.enquiryName?.isEmpty == true &&
        widget.enquiryCode?.isEmpty == true) {
      _enquiryCubit.getEnquiryList(context, 1, _project.projectId);
      return;
    }
    _searchC.text = widget.enquiryName!;
    _enquiryCubit.getEnquiry(
      context: context,
      enquiryName: widget.enquiryName!,
      projectId: _project.projectId,
      enquiryCode: widget.enquiryCode!,
    );
  }

  Future<void> openWhatsApp({
    required String phoneNumber,
    String message = 'Hi',
  }) async {
    String normalized = _normalizePhone(phoneNumber);

    final encodedMsg = Uri.encodeComponent(message);

    final Uri appUri = Uri.parse(
      "whatsapp://send?phone=$normalized&text=$encodedMsg",
    );

    final Uri webUri = Uri.parse("https://wa.me/$normalized?text=$encodedMsg");

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  String _normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'\D'), '');

    // If 10 digit Indian number → add 91
    if (phone.length == 10) {
      phone = "91$phone";
    }

    // Remove leading +
    if (phone.startsWith("+")) {
      phone = phone.substring(1);
    }

    return phone;
  }

  void _showPopupToDeleteEnquiry({
    required int index,
    required EnquiryModel enquiryModel,
    required BuildContext context,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this Enquiry',
      'Deleting this Enquiry will permanently remove its contents.',
    );

    if (result && context.mounted) {
      _enquiryCubit.deleteEnquiry(
        index: index,
        enquiryModel: enquiryModel,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _searchC.dispose();
    _systemCodeC.dispose();
    _mobileNumberC.dispose();
    _budgetC.dispose();
    _requirementTypeC.dispose();
    _channelPartnerMobileC.dispose();
    _nationalityC.dispose();
    _currentLocationC.dispose();
    _customerClassificationC.dispose();
    _ethnicityC.dispose();
    _salesAdvisorC.dispose();
    _sourcingManagerC.dispose();
    _accommodationC.dispose();
    _followUpDaysC.dispose();
    _finalStageC.dispose();

    scrollController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _systemCodeC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _budgetC = TextEditingController();
    _requirementTypeC = TextEditingController();
    _channelPartnerMobileC = TextEditingController();
    _nationalityC = TextEditingController();
    _currentLocationC = TextEditingController();
    _customerClassificationC = TextEditingController();
    _ethnicityC = TextEditingController();
    _salesAdvisorC = TextEditingController();
    _sourcingManagerC = TextEditingController();
    _accommodationC = TextEditingController();
    _followUpDaysC = TextEditingController();
    _finalStageC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_enquiryCubit.state.isLoading! &&
          _enquiryCubit.state.enquiryList.length <
              _enquiryCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _enquiryCubit.getEnquiryList(
            context,
            _enquiryCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  // <---- FILTER ENQUIRY ---->
  Future<void> _showBottomSheetToFilterEnquiry(BuildContext context) async {
    final state = _enquiryCubit.state;

    // INITIAL DATA
    final DateTime? initialStartDate = state.filterStartDate;
    final DateTime? initialEndDate = state.filterEndDate;

    final String? initialDirection =
        state.currentSortColumn == "Name" ? state.currentSortDirection : null;

    final initialSystemCode = state.filterSystemCode;
    final initialEnquiryName = state.searchText;
    final initialMobile = state.filterMobileNumber;
    final initialBudget = state.filterBudget;
    final initialRequirementType = state.filterRequirementType;
    final initialSource = state.filterSource;
    final initialSubSource = state.filterSubSource;
    final initialChannelPartnerMobile = state.filterChannelPartnerMobile;
    final initialNationality = state.filterNationality;
    final initialCurrentLocation = state.filterCurrentLocation;
    final initialCustomerClassification = state.filterCustomerClassification;
    final initialEthnicity = state.filterEthnicity;
    final initialSalesAdvisor = state.filterSalesAdvisor;
    final initialSourcingManager = state.filterSourcingManager;
    final initialAccommodation = state.filterAccommodation;
    final initialFollowUpDays = state.filterFollowUpDays;
    final initialFinalStage = state.filterFinalStage;

    // CONTROLLERS
    _systemCodeC.text = initialSystemCode;
    _searchC.text = initialEnquiryName;
    _mobileNumberC.text = initialMobile;
    _budgetC.text = initialBudget;
    _requirementTypeC.text = initialRequirementType;
    _channelPartnerMobileC.text = initialChannelPartnerMobile;
    _nationalityC.text = initialNationality;
    _currentLocationC.text = initialCurrentLocation;
    _customerClassificationC.text = initialCustomerClassification;
    _ethnicityC.text = initialEthnicity;
    _salesAdvisorC.text = initialSalesAdvisor;
    _sourcingManagerC.text = initialSourcingManager;
    _accommodationC.text = initialAccommodation;
    _followUpDaysC.text = initialFollowUpDays;
    _finalStageC.text = initialFinalStage;

    _startDateNotifier.value = initialStartDate;
    _endDateNotifier.value = initialEndDate;
    String? selectedDirection = initialDirection;

    bool applied = false;
    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState() {
      final currentSource =
          (_selectedSourceNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedSourceNotifier.value?['DisplayName'] ?? '';

      final currentSubSource =
          (_selectedSubSourceNotifier.value?['zAttributesId'] == -1)
              ? ''
              : _selectedSubSourceNotifier.value?['DisplayName'] ?? '';

      manualClose =
          (_startDateNotifier.value != initialStartDate) ||
          (_endDateNotifier.value != initialEndDate) ||
          (_systemCodeC.text.trim() != initialSystemCode) ||
          (_searchC.text.trim() != initialEnquiryName) ||
          (_mobileNumberC.text.trim() != initialMobile) ||
          (_budgetC.text.trim() != initialBudget) ||
          (_requirementTypeC.text.trim() != initialRequirementType) ||
          (currentSource != initialSource) ||
          (currentSubSource != initialSubSource) ||
          (_channelPartnerMobileC.text.trim() != initialChannelPartnerMobile) ||
          (_nationalityC.text.trim() != initialNationality) ||
          (_currentLocationC.text.trim() != initialCurrentLocation) ||
          (_customerClassificationC.text.trim() !=
              initialCustomerClassification) ||
          (_ethnicityC.text.trim() != initialEthnicity) ||
          (_salesAdvisorC.text.trim() != initialSalesAdvisor) ||
          (_sourcingManagerC.text.trim() != initialSourcingManager) ||
          (_accommodationC.text.trim() != initialAccommodation) ||
          (_followUpDaysC.text.trim() != initialFollowUpDays) ||
          (_finalStageC.text.trim() != initialFinalStage) ||
          (selectedDirection != initialDirection);

      final bool onlyOneDateSet =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value == null) ||
          (_endDateNotifier.value != null && _startDateNotifier.value == null);

      final bool invalidRange =
          (_startDateNotifier.value != null &&
              _endDateNotifier.value != null &&
              _startDateNotifier.value!.isAfter(_endDateNotifier.value!));

      applyEnabled.value = manualClose && !onlyOneDateSet && !invalidRange;
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Enquiry",

      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
              updateApplyState();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SORT
                Text("Sort By Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: 0.5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),

                    horizontalSpacing(),

                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: 0.5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),

                verticalSpacing(height: 20),

                CustomTextField(
                  textController: _systemCodeC,
                  title: "Enquiry Code",
                  hint: "Enter System Code",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                CustomTextField(
                  textController: _searchC,
                  title: "Enquiry Name",
                  hint: "Enter Enquiry Name",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _mobileNumberC,
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  keyboardType: TextInputType.phone,
                  inputFormatterList: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s+]')),
                  ],
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _budgetC,
                  title: "Budget",
                  hint: "Enter Budget",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _requirementTypeC,
                  title: "Requirement Type",
                  hint: "Enter Requirement Type",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                ValueListenableBuilder(
                  valueListenable: _selectedSourceNotifier,
                  builder: (context, selectedSource, _) {
                    final bool isChannelPartner =
                        selectedSource?['zAttributesId'] == 1;

                    return Column(
                      children: [
                        CustomDropDownWidget(
                          title: 'Source',
                          hintText: 'Select Source',
                          initialValue: selectedSource,
                          dataList: sourceTypeList,
                          onSelected: (v) {
                            _selectedSourceNotifier.value = v;
                            updateApplyState();
                          },
                          onValueClear: () {
                            _selectedSourceNotifier.value = null;
                            updateApplyState();
                          },
                        ),

                        if ((selectedSource != null))
                          ValueListenableBuilder(
                            valueListenable: _selectedSubSourceNotifier,
                            builder: (context, selectedSubSource, _) {
                              return CustomDropDownWidget(
                                title: "Sub Source",
                                initialValue: selectedSubSource,
                                dataList:
                                    isChannelPartner
                                        ? channelPartnerActivityList
                                        : directWalkingSubSourceList,
                                onSelected: (v) {
                                  _selectedSubSourceNotifier.value = v;
                                  updateApplyState();
                                },
                                onValueClear: () {
                                  _selectedSubSourceNotifier.value = null;
                                  updateApplyState();
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),

                CustomTextField(
                  textController: _channelPartnerMobileC,
                  title: "Channel Partner Mobile",
                  hint: "Enter Channel Partner Mobile",
                  keyboardType: TextInputType.phone,
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _nationalityC,
                  title: "Nationality",
                  hint: "Enter Nationality",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _currentLocationC,
                  title: "Current Location",
                  hint: "Enter Current Location",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _customerClassificationC,
                  title: "Customer Classification",
                  hint: "Enter Classification",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _ethnicityC,
                  title: "Ethnicity",
                  hint: "Enter Ethnicity",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _salesAdvisorC,
                  title: "Sales Advisor",
                  hint: "Enter Sales Advisor",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _sourcingManagerC,
                  title: "Sourcing Manager",
                  hint: "Enter Sourcing Manager",
                  onChangeFunction: (_) => updateApplyState(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, startDate, _) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: startDate,
                            setValue: (value) {
                              _startDateNotifier.value = value;
                              updateApplyState();
                            },
                            validator: (_) => null,
                          );
                        },
                      ),
                    ),

                    horizontalSpacing(),

                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _endDateNotifier,
                        builder: (context, endDate, _) {
                          return CustomDatePicker(
                            title: "To Date",
                            initialDate: endDate,
                            setValue: (value) {
                              _endDateNotifier.value = value;
                              updateApplyState();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                CustomTextField(
                  textController: _accommodationC,
                  title: "Accommodation",
                  hint: "Enter Accommodation",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _followUpDaysC,
                  title: "Follow Up Days",
                  hint: "Enter Follow Up Days",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _finalStageC,
                  title: "Final Stage",
                  hint: "Enter Final Stage",
                  onChangeFunction: (_) => updateApplyState(),
                ),
              ],
            ),
          );
        },
      ),

      // CLEAR
      onClear: () async {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;

        _systemCodeC.clear();
        _mobileNumberC.clear();
        _budgetC.clear();
        _requirementTypeC.clear();
        _channelPartnerMobileC.clear();
        _nationalityC.clear();
        _currentLocationC.clear();
        _customerClassificationC.clear();
        _ethnicityC.clear();
        _salesAdvisorC.clear();
        _sourcingManagerC.clear();
        _accommodationC.clear();
        _followUpDaysC.clear();
        _finalStageC.clear();

        selectedDirection = null;
        _selectedSourceNotifier.value = null;
        _selectedSubSourceNotifier.value = null;

        await clearFilter();
        _searchC.clear();
      },

      // APPLY
      onApply: () {
        applied = true;

        _enquiryCubit.applyEnquiryFilterAndSort(
          context: context,
          filterStartDate: _startDateNotifier.value,
          filterEndDate: _endDateNotifier.value,
          filterSystemCode: _systemCodeC.text.trim(),
          filterEnquiryName: _searchC.text.trim(),
          filterMobileNumber: _mobileNumberC.text.trim(),
          filterBudget: _budgetC.text.trim(),
          filterRequirementType: _requirementTypeC.text.trim(),
          filterSource:
              (_selectedSourceNotifier.value != null &&
                      _selectedSourceNotifier.value!['zAttributesId'] != -1)
                  ? _selectedSourceNotifier.value!['DisplayName']
                  : '',
          filterSubSource:
              (_selectedSubSourceNotifier.value != null &&
                      _selectedSubSourceNotifier.value!['zAttributesId'] != -1)
                  ? _selectedSubSourceNotifier.value!['DisplayName']
                  : '',
          filterChannelPartnerMobile: _channelPartnerMobileC.text.trim(),
          filterNationality: _nationalityC.text.trim(),
          filterCurrentLocation: _currentLocationC.text.trim(),
          filterCustomerClassification: _customerClassificationC.text.trim(),
          filterEthnicity: _ethnicityC.text.trim(),
          filterSalesAdvisor: _salesAdvisorC.text.trim(),
          filterSourcingManager: _sourcingManagerC.text.trim(),
          filterAccommodation: _accommodationC.text.trim(),
          filterFollowUpDays: _followUpDaysC.text.trim(),
          filterFinalStage: _finalStageC.text.trim(),
          sortColumn: selectedDirection != null ? "Name" : "",
          sortDirection: selectedDirection ?? "",
          projectId: _project.projectId,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied && manualClose) {
      _systemCodeC.clear();
      _searchC.clear();
      _mobileNumberC.clear();
      _budgetC.clear();
      _requirementTypeC.clear();
      _channelPartnerMobileC.clear();
      _nationalityC.clear();
      _currentLocationC.clear();
      _customerClassificationC.clear();
      _ethnicityC.clear();
      _salesAdvisorC.clear();
      _sourcingManagerC.clear();
      _accommodationC.clear();
      _followUpDaysC.clear();
      _finalStageC.clear();

      _startDateNotifier.value = null;
      _endDateNotifier.value = null;

      _selectedSourceNotifier.value = null;
      _selectedSubSourceNotifier.value = null;

      selectedDirection = null;
    }
  }

  Future<void> clearFilter() async {
    _enquiryCubit.applyEnquiryFilterAndSort(
      context: context,
      projectId: _project.projectId,
      filterEnquiryName: "",
      filterStartDate: null,
      filterEndDate: null,
      filterSystemCode: '',
      filterMobileNumber: '',
      filterBudget: '',
      filterRequirementType: '',
      filterSource: '',
      filterSubSource: '',
      filterChannelPartnerMobile: '',
      filterNationality: '',
      filterCurrentLocation: '',
      filterCustomerClassification: '',
      filterEthnicity: '',
      filterSalesAdvisor: '',
      filterSourcingManager: '',
      filterAccommodation: '',
      filterFollowUpDays: '',
      filterFinalStage: '',
      sortColumn: "",
      sortDirection: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnquiryCubit, EnquiryState>(
      listenWhen: (prev, curr) => curr.searchText.trim().isEmpty,
      listener: (context, state) {
        _searchC.clear();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Enquiry",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          searchHintText: "Search by Name",
          onSearchSubmit: (value) {
            _enquiryCubit.searchEnquiry(context, value, _project.projectId);
          },
          onExportCallback: (value) {
            if (_project.projectId == 0) {
              showErrorMessage(context, "Error", "Please select a project");
              return;
            }
            if (_enquiryCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _enquiryCubit.exportExcelPdf(context, value);
          },
          onProjectChangeCallback: (value) async {
            _project = value;
            await clearFilter();
            if (context.mounted) {
              _enquiryCubit.searchEnquiry(context, "", value.projectId);
            }
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterEnquiry(context);
          },
          onAddCallback: () {
            if (_project.projectId == 0) {
              showErrorMessage(context, "Error", "Please select a project");
              return;
            }

            goRouter.pushNamed(AppRoutes.addEnquiry);
          },
        ),
        body: BlocBuilder<EnquiryCubit, EnquiryState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: showSiteSelectedWidget(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _searchC.clear();
                      _enquiryCubit.searchEnquiry(
                        context,
                        "",
                        _project.projectId,
                      );
                    },
                    child: BlocBuilder<EnquiryCubit, EnquiryState>(
                      builder: (context, state) {
                        if ((state.isLoading ?? true) &&
                            state.enquiryList.isEmpty) {
                          return Center(child: loader());
                        }
                        if (state.enquiryList.isEmpty) {
                          return Center(
                            child: noDataWidget(
                              message: "No Enquiry Data Found",
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                itemCount:
                                    _enquiryCubit.state.enquiryList.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == state.enquiryList.length) {
                                    return state.enquiryList.length <
                                            state.totalNumberOfRecord
                                        ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                        : const SizedBox.shrink();
                                  }
                                  var enquiry = state.enquiryList[index];
                                  final editDisable =
                                      !_routeAuthorizationModel.isAction ||
                                      closedStatuses.contains(
                                        enquiry.finalStage.toLowerCase(),
                                      );
                                  final deleteDisable =
                                      !_routeAuthorizationModel.isAction ||
                                      (enquiry.nextFollowUpDate != null ||
                                          closedStatuses.contains(
                                            enquiry.finalStage.toLowerCase(),
                                          ));

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(12),
                                    decoration: commonCardDecoration(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  /// CLEAR PREVIOUS OVERVIEW DATA
                                                  await _enquiryCubit
                                                      .clearCurrentEnquiry();

                                                  ///  CLEAR PREVIOUS FOLLOWUP DATA
                                                  await _enquiryCubit
                                                      .clearEnquiryFollowUp();

                                                  await goRouter.pushNamed(
                                                    AppRoutes.viewEnquiry,
                                                    queryParameters: {
                                                      "enquiryId":
                                                          Uri.encodeQueryComponent(
                                                            EncryptionManager.encryptData(
                                                              enquiry.enquiryId
                                                                  .toString(),
                                                            ),
                                                          ),
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  enquiry.name,
                                                  style: AppTextStyle.ts14M(
                                                    color: AppColor.primary,
                                                  ).copyWith(
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                    decorationColor:
                                                        AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            CustomIconButton(
                                              onPressed: () {
                                                openWhatsApp(
                                                  phoneNumber:
                                                      enquiry.mobileNumber,
                                                );
                                              },
                                              icon: SvgPicture.asset(
                                                AppAssets.whatsAppIcon,
                                                height: 16,
                                                width: 16,
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            CustomIconButton.edit(
                                              isDisabled: editDisable,
                                              onPressed: () {
                                                goRouter.pushNamed(
                                                  AppRoutes.addEnquiry,
                                                  queryParameters: {
                                                    "enquiry":
                                                        Uri.encodeQueryComponent(
                                                          EncryptionManager.encryptData(
                                                            jsonEncode(
                                                              enquiry.toJson(),
                                                            ),
                                                          ),
                                                        ),
                                                    'index': index.toString(),
                                                  },
                                                );
                                              },
                                            ),
                                            horizontalSpacing(),

                                            CustomIconButton.delete(
                                              isDisabled: deleteDisable,
                                              onPressed: () {
                                                _showPopupToDeleteEnquiry(
                                                  context: context,
                                                  enquiryModel: enquiry,
                                                  index: index,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        buildRowTitleValue(
                                          title: "Enquiry Code  ",
                                          value: enquiry.systemGeneratedCode,
                                          customValueWidget: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  enquiry.systemGeneratedCode,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 2),
                                              InkWell(
                                                onTap: () {
                                                  copy(
                                                    context: context,
                                                    text:
                                                        enquiry
                                                            .systemGeneratedCode,
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        buildRowTitleValue(
                                          title: "Mobile Number",
                                          value: enquiry.mobileNumber,
                                          customValueWidget:
                                              CustomClickToContactText(
                                                countryCode:
                                                    enquiry
                                                        .mobileNumberCountryCode,
                                                value: enquiry.mobileNumber,
                                              ),
                                        ),
                                        buildRowTitleValue(
                                          title: "Source",
                                          value: enquiry.source,
                                        ),
                                        buildRowTitleValue(
                                          title: "Customer Classification",
                                          value: enquiry.customerClassification,
                                        ),
                                        buildRowTitleValue(
                                          title: "Enquiry Follow Up Days",
                                          value:
                                              enquiry.nextFollowUpDate
                                                  ?.toIso8601String() ??
                                              'No Follow up',
                                          singleLine: false,
                                          customValueWidget:
                                              followUpStatusTextWidget(
                                                enquiry.nextFollowUpDate,
                                              ),
                                        ),
                                        buildRowTitleValue(
                                          title: "Next Follow-Up Date",
                                          value:
                                              enquiry.nextFollowUpDate != null
                                                  ? formatDateTimeAsDDMMMYYYY(
                                                    enquiry.nextFollowUpDate!,
                                                  )
                                                  : "-",
                                          singleLine: false,
                                        ),
                                        buildRowTitleValue(
                                          title: "Requirement",
                                          value: enquiry.requirement,
                                          singleLine: false,
                                        ),
                                        buildRowTitleValue(
                                          title: "Stage",
                                          value: enquiry.finalStage,
                                          customValueWidget:
                                              enquiry.finalStage.isNotEmpty
                                                  ? enquiryStatusWidget(
                                                    enquiry.finalStage,
                                                  )
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
