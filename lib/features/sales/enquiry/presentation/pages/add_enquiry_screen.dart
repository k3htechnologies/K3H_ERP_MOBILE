// SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/presentation/cubit/enquiry_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AddEnquiryScreen extends StatefulWidget {
  final EnquiryModel? enquiryModel;
  final int index;

  const AddEnquiryScreen({super.key, this.enquiryModel, this.index = 0});

  @override
  State<AddEnquiryScreen> createState() => _AddEnquiryScreenState();
}

class _AddEnquiryScreenState extends State<AddEnquiryScreen> {
  late EnquiryCubit _enquiryCubit;
  bool get _isEditMode => widget.enquiryModel != null;

  final _formKey = GlobalKey<FormState>();
  String? _timeInC;
  String? _timeOutC;
  String nationality = 'Indian';
  late TextEditingController uniqueCodeC,
      _nameC,
      _mobileC,
      _emailC,
      _ageC,
      _locationC,
      _areaPrefC,
      _budgetC,
      // Employee Reference
      _employeeName,
      _employeeMobileNumber,
      // Loyalty
      _existingProjectName,
      _existingUnitNumber,
      // Referral (Reference)
      _referralName,
      _referralMobile,
      _referralProjectName,
      _referralUnitNumber,
      _remarkC;

  DateTime? dateOfBirth;
  DateTime? enquiryDate;
  DateTime? nextFollowUpDate;

  late Map<String, dynamic> selectedAccommodation;
  late Map<String, dynamic> selectedOccupationType;
  late Map<String, dynamic> selectedPossessionType;
  late Map<String, dynamic> selectedLocation;
  late Map<String, dynamic> selectedTimeline;
  late Map<String, dynamic> selectedFloorBand;
  late Map<String, dynamic> selectedRequirement;
  late Map<String, dynamic> selectedResidentialType;
  late Map<String, dynamic> selectedCommercialType;
  late Map<String, dynamic> selectedCommercialLeasing;
  late Map<String, dynamic> selectLocation;
  late Map<String, dynamic> selectTimeline;
  late Map<String, dynamic> selectedFunding;
  late Map<String, dynamic> selectedEthnicity;
  late Map<String, dynamic> selectedSource;
  late Map<String, dynamic> selectedSubSource;
  late Map<String, dynamic> selectedChannelPartner;
  late Map<String, dynamic> selectedSubSubSource;
  late Map<String, dynamic> selectedFinalStage;
  late Map<String, dynamic> selectedSaleAdvisor;
  late Map<String, dynamic> selectedSourcingManager;

  final List<Map<String, dynamic>> currentAccommodation = [
    {'zAttributesId': -1, 'DisplayName': 'Select Current Accomodation'},

    {'zAttributesId': 1, 'DisplayName': 'Rented'},
    {'zAttributesId': 2, 'DisplayName': 'Self-Owned'},
  ];
  final List<Map<String, dynamic>> occupationType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Occupation Type'},

    {'zAttributesId': 1, 'DisplayName': 'Business'},
    {'zAttributesId': 2, 'DisplayName': 'Homemaker'},
    {'zAttributesId': 3, 'DisplayName': 'Professional'},
    {'zAttributesId': 4, 'DisplayName': 'Salaried'},
    {'zAttributesId': 5, 'DisplayName': 'Retired'},
  ];
  final List<Map<String, dynamic>> sourceTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Source'},

    {'zAttributesId': 1, 'DisplayName': 'Channel Partner'},
    {'zAttributesId': 2, 'DisplayName': 'Direct Walking'},
  ];

  final List<Map<String, dynamic>> residentialType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Unit Type'},

    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 7, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 8, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 9, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 10, 'DisplayName': 'PENTHOUSE'},
  ];
  final List<Map<String, dynamic>> floorBrand = [
    {'zAttributesId': -1, 'DisplayName': 'Select Floor Brand'},

    {'zAttributesId': 1, 'DisplayName': 'Higher'},
    {'zAttributesId': 2, 'DisplayName': 'Middle'},
    {'zAttributesId': 3, 'DisplayName': 'Lower'},
  ];
  final List<Map<String, dynamic>> possessionType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Possession Type'},

    {'zAttributesId': 1, 'DisplayName': 'RTMI'},
    {'zAttributesId': 2, 'DisplayName': 'Under 1 Year'},
    {'zAttributesId': 3, 'DisplayName': '1 Years To 2 Years'},
    {'zAttributesId': 4, 'DisplayName': '2 Years To 3 Years'},
    {'zAttributesId': 5, 'DisplayName': '3 Years & Above'},
  ];

  final List<Map<String, dynamic>> requirementType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Requirement'},
    {'zAttributesId': 1, 'DisplayName': 'Commercial'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial Leasing'},
    {'zAttributesId': 3, 'DisplayName': 'Residential'},
  ];
  final List<Map<String, dynamic>> commercialUnitTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Type'},
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];
  final List<Map<String, dynamic>> timelineTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Timeline'},

    {'zAttributesId': 1, 'DisplayName': 'Within 1 Month'},
    {'zAttributesId': 2, 'DisplayName': 'Beyond 1 Month'},
  ];
  final List<Map<String, dynamic>> fundingSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Funding Source'},

    {'zAttributesId': 1, 'DisplayName': 'Loan'},
    {'zAttributesId': 2, 'DisplayName': 'Self-funded'},
    {'zAttributesId': 3, 'DisplayName': 'Sale Of Property Funding'},
  ];
  final List<Map<String, dynamic>> ethnicityList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Ethnicity'},

    {'zAttributesId': 1, 'DisplayName': 'Bengali'},
    {'zAttributesId': 2, 'DisplayName': 'Christian'},
    {'zAttributesId': 3, 'DisplayName': 'Gujarati'},
    {'zAttributesId': 4, 'DisplayName': 'Jain'},
    {'zAttributesId': 5, 'DisplayName': 'Muslim'},
    {'zAttributesId': 6, 'DisplayName': 'Marwari'},
    {'zAttributesId': 7, 'DisplayName': 'Maharashtrian'},
    {'zAttributesId': 8, 'DisplayName': 'North Indian'},
    {'zAttributesId': 9, 'DisplayName': 'Parsi'},
    {'zAttributesId': 10, 'DisplayName': 'Punjabi'},
    {'zAttributesId': 11, 'DisplayName': 'Sindhi'},
    {'zAttributesId': 12, 'DisplayName': 'South Indian'},
    {'zAttributesId': 13, 'DisplayName': 'Others'},
  ];
  final List<Map<String, dynamic>> stageTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Stage'},

    {'zAttributesId': 1, 'DisplayName': 'Site Visit'},
    {'zAttributesId': 2, 'DisplayName': 'Re-Visit Proposed'},
    {'zAttributesId': 3, 'DisplayName': 'Re-Visit Scheduled'},
    {'zAttributesId': 4, 'DisplayName': 'Negotiation'},
    {'zAttributesId': 5, 'DisplayName': 'Unit Selection / Blocked'},
    {'zAttributesId': 6, 'DisplayName': 'Blocked'},
    {'zAttributesId': 7, 'DisplayName': 'Booking Done'},
    {'zAttributesId': 8, 'DisplayName': 'Retention'},
    {'zAttributesId': 9, 'DisplayName': 'Lost'},
    {'zAttributesId': 10, 'DisplayName': 'Cancelled'},
  ];
  final List<Map<String, dynamic>> channelPartnerActivityList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Activity'},

    {'zAttributesId': 1, 'DisplayName': 'Channel Partner Data Calling'},
    {'zAttributesId': 2, 'DisplayName': 'Channel Partner Walked In'},
    {'zAttributesId': 3, 'DisplayName': 'Digital Activity'},
  ];
  final List<Map<String, dynamic>> directWalkingSubSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Sub Source'},

    {'zAttributesId': 1, 'DisplayName': 'Advertisement'},
    {'zAttributesId': 2, 'DisplayName': 'Exhibition'},
    {'zAttributesId': 3, 'DisplayName': 'Employee Reference'},
    {'zAttributesId': 4, 'DisplayName': 'HRR Website'},
    {'zAttributesId': 5, 'DisplayName': 'Loyalty'},
    {'zAttributesId': 6, 'DisplayName': 'Management Reference'},
    {'zAttributesId': 7, 'DisplayName': 'Property Search Portal'},
    {'zAttributesId': 8, 'DisplayName': 'SMS'},
    {'zAttributesId': 9, 'DisplayName': 'Site Branding'},
    {'zAttributesId': 10, 'DisplayName': 'Reference'},
    {'zAttributesId': 11, 'DisplayName': 'Other'},
  ];
  final List<Map<String, dynamic>> subSubSourceList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Sub-Sub Source'},

    {'zAttributesId': 1, 'DisplayName': 'Facebook'},
    {'zAttributesId': 2, 'DisplayName': 'Hoarding'},
    {'zAttributesId': 3, 'DisplayName': 'Instagram'},
    {'zAttributesId': 4, 'DisplayName': 'Google Ads'},
    {'zAttributesId': 5, 'DisplayName': 'Newspaper'},
  ];

  double _budgetValue = 1.5;

  @override
  void initState() {
    super.initState();
    _enquiryCubit = context.read<EnquiryCubit>();
    _initControllers();

    selectedAccommodation = currentAccommodation.first;
    selectedOccupationType = occupationType.first;
    selectedPossessionType = possessionType.first;
    selectedResidentialType = residentialType.first;
    selectedFloorBand = floorBrand.first;
    selectedRequirement = requirementType.first;
    selectedCommercialType = commercialUnitTypeList.first;
    selectedCommercialLeasing = commercialUnitTypeList.first;
    selectTimeline = timelineTypeList.first;
    selectedFunding = fundingSourceList.first;
    selectedEthnicity = ethnicityList.first;
    selectedSource = sourceTypeList.first;
    selectedFinalStage = sourceTypeList.first;
    selectedTimeline = timelineTypeList.first;

    /// ADD THESE ↓↓↓
    selectedSubSource = directWalkingSubSourceList.first;
    selectedSubSubSource = subSubSourceList.first;
    selectedLocation = {'zAttributesId': -1, 'DisplayName': 'Select Location'};
    selectedSaleAdvisor = {
      'zAttributesId': -1,
      'DisplayName': 'Select Advisor',
    };
    selectedSourcingManager = {
      'zAttributesId': -1,
      'DisplayName': 'Select Manager',
    };

    if (_isEditMode) {
      _populateForm(widget.enquiryModel!);
    } else {
      _timeInC = DateTime.now().toIso8601String();
    }
  }

  void _initControllers() {
    _nameC = TextEditingController();
    _mobileC = TextEditingController();
    _emailC = TextEditingController();
    _ageC = TextEditingController();
    _locationC = TextEditingController();
    _areaPrefC = TextEditingController();
    _budgetC = TextEditingController();

    // Employee Reference
    _employeeName = TextEditingController();
    _employeeMobileNumber = TextEditingController();

    // Loyalty
    _existingProjectName = TextEditingController();
    _existingUnitNumber = TextEditingController();

    // Referral
    _referralName = TextEditingController();
    _referralMobile = TextEditingController();
    _referralProjectName = TextEditingController();
    _referralUnitNumber = TextEditingController();

    _remarkC = TextEditingController();
  }

  void _populateForm(EnquiryModel model) {
    _nameC.text = model.name;
    _mobileC.text = model.mobileNumber;
    _emailC.text = model.emailId;
    _locationC.text = model.currentLocation;
    _areaPrefC.text = model.areaPreferred.toString();
    _budgetC.text = model.budget;
    _remarkC.text = model.remark;

    dateOfBirth = model.dateOfBirth;
    enquiryDate = model.enquiryDate;
    nextFollowUpDate = model.nextFollowUpDate;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      if (_isEditMode) "Uniquekey": widget.enquiryModel!.uniquekey,
      "EnquiryId": _isEditMode ? widget.enquiryModel!.enquiryId : 0,
      "ProjectId": getProject().projectId,
      "EnquiryTimeIn": _timeInC!,
      "Name": _nameC.text.trim(),
      "MobileNumber": _mobileC.text.trim(),
      "EmailId": _emailC.text.trim(),
      "DateOfBirth": dateOfBirth?.toIso8601String(),
      "Accommodation": selectedAccommodation["name"],
      "CurrentLocation": _locationC.text.trim(),
      "PossessionType": selectedPossessionType["name"],
      "AreaPreferred": int.tryParse(_areaPrefC.text) ?? 0,
      "DesiredFloorBand": selectedFloorBand["name"],
      "Budget": _budgetC.text.trim(),
      "Requirement": selectedRequirement["name"],
      //Need confirmation
      "CustomerClassification": "",
      "SourceOfFunding": selectedFunding["name"],
      "Ethnicity": selectedEthnicity["name"],
      "Source": selectedSource["name"],
      "SubSource": selectedSubSource["name"],
      "FinalStage": selectedFinalStage["name"],
      "EnquiryDate": enquiryDate?.toIso8601String(),
      "NextFollowUpDate": nextFollowUpDate?.toIso8601String(),
      "Remark": _remarkC.text.trim(),
    };

    if (_isEditMode) {
      _enquiryCubit.addUpdateEnquiry(
        context: context,
        index: widget.index,
        body: payload,
      );
    } else {
      _enquiryCubit.addUpdateEnquiry(context: context, body: payload);
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _locationC.dispose();
    _areaPrefC.dispose();
    _budgetC.dispose();

    _employeeName.dispose();
    _employeeMobileNumber.dispose();

    _existingProjectName.dispose();
    _existingUnitNumber.dispose();

    _referralName.dispose();
    _referralMobile.dispose();
    _referralProjectName.dispose();
    _referralUnitNumber.dispose();

    _remarkC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Enquiry" : "Add Enquiry",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _basicCard(),
              verticalSpacing(height: 16),
              _sourceCard(),
              verticalSpacing(height: 16),
              _addressCard(),
              verticalSpacing(height: 16),
              _propertyPrefCard(),
              verticalSpacing(height: 16),
              _customerDetailsCard(),
              verticalSpacing(height: 16),
              _enquiryInfoCard(),
              verticalSpacing(height: 16),
              _followUpCard(),
              verticalSpacing(height: 16),
              _salesCard(),
              verticalSpacing(height: 24),
              CustomButton(
                text: _isEditMode ? "Update" : "Submit",
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _basicCard() {
    return _card("Basic Enquiry Details", [
      Text('Customer Time In *'),
      CustomTimePicker(
        isRequired: true,
        initialTime: parseTimeOfDayFromHHmm(_timeInC),
        setValue: (val) => _timeInC = formatTimeOfDayHHmm(val),
      ),
      CustomTextField(
        isRequired: true,
        title: "Full Name",
        textController: _nameC,
        hint: "Enter Name",
      ),
      CustomTextField(
        title: "Mobile Number",
        isRequired: true,
        textController: _mobileC,
        hint: "Enter Mobile",
      ),
      CustomTextField(
        title: "E-mail ID",
        textController: _emailC,
        hint: "Enter Email",
      ),
      CustomDatePicker(
        title: "DOB",
        isRequired: true,
        initialDate: dateOfBirth,
        setValue: (v) => dateOfBirth = v,
      ),
      CustomTextField(
        isRequired: true,
        readOnly: true,
        title: "Age",
        textController: _ageC,
        hint: "System calculated Age",
      ),
      CustomDropDownWidget(
        isRequired: true,
        title: "Current Accommodation",
        initialValue: selectedAccommodation,
        dataList: currentAccommodation,
        onSelected: (v) => selectedAccommodation = v,
      ),
      CustomDropDownWidget(
        title: "Occupation Type",
        isRequired: true,
        initialValue: selectedOccupationType,
        dataList: occupationType,
        onSelected: (v) => selectedOccupationType = v,
      ),
    ]);
  }

  Widget _sourceCard() {
    final bool isDirectWalking =
        selectedSource['zAttributesId'] == sourceTypeList[2]['zAttributesId'];

    final int subSourceId = selectedSubSource['zAttributesId'];

    return _card("Source", [
      CustomDropDownWidget(
        title: "Source*",
        initialValue: selectedSource,
        dataList: sourceTypeList,
        onSelected: (v) {
          setState(() {
            selectedSource = v;

            // Reset SubSource when Source changes
            selectedSubSource =
                selectedSource['zAttributesId'] ==
                        sourceTypeList[1]['zAttributesId']
                    ? channelPartnerActivityList.first
                    : directWalkingSubSourceList.first;

            selectedSubSubSource = subSubSourceList.first;
          });
        },
      ),

      CustomDropDownWidget(
        title: "Sub Source*",
        initialValue: selectedSubSource,
        dataList:
            selectedSource['zAttributesId'] ==
                    sourceTypeList[1]['zAttributesId']
                ? channelPartnerActivityList
                : directWalkingSubSourceList,
        onSelected: (v) {
          setState(() {
            selectedSubSource = v;
            selectedSubSubSource = subSubSourceList.first;
          });
        },
      ),
      if (!isDirectWalking)
        CustomDropDownWidget(
          title: "Channel Partner*",
          initialValue: selectedChannelPartner,
          dataList: channelPartnerActivityList,
          onSelected: (v) {
            setState(() {
              selectedChannelPartner = v;
            });
          },
        ),

      /// ---------------- DIRECT WALKING CASES ----------------

      /// Advertisement → show SubSubSource dropdown
      if (isDirectWalking && subSourceId == 1)
        CustomDropDownWidget(
          title: "Sub Sub Source*",
          initialValue: selectedSubSubSource,
          dataList: subSubSourceList,
          onSelected: (v) {
            setState(() {
              selectedSubSubSource = v;
            });
          },
        ),

      /// Employee Reference → 2 fields
      if (isDirectWalking && subSourceId == 3) ...[
        CustomTextField(
          title: "Employee Name",
          hint: "Enter Employee Name",
          textController: _employeeName,
        ),
        CustomTextField(
          title: "Employee Mobile Number",
          hint: "Enter Mobile Number",
          textController: _employeeMobileNumber,
        ),
      ],

      /// Loyalty → 2 fields
      if (isDirectWalking && subSourceId == 5) ...[
        CustomTextField(
          title: "Existing Project Name",
          hint: "Enter Project Name",
          textController: _existingProjectName,
        ),
        CustomTextField(
          title: "Existing Unit Number",
          hint: "Enter Unit Number",
          textController: _existingUnitNumber,
        ),
      ],

      /// Reference → 4 fields
      if (isDirectWalking && subSourceId == 10) ...[
        CustomTextField(
          title: "Referral Name*",
          hint: "Enter Referral Name",
          textController: _referralName,
        ),
        CustomTextField(
          title: "Referral Mobile Number*",
          hint: "Enter Referral Mobile Number",
          textController: _referralMobile,
        ),
        CustomTextField(
          title: "Referral Project Name*",
          hint: "Enter Referral Project Name",
          textController: _referralProjectName,
        ),
        CustomTextField(
          title: "Referral Unit Number*",
          hint: "Enter Referral Unit Number",
          textController: _referralUnitNumber,
        ),
      ],
    ]);
  }

  Widget _addressCard() {
    return _card("Address", [
      CustomTextField(title: "Current Location*", textController: _locationC),
    ]);
  }

  Widget _propertyPrefCard() {
    return _card("Property Preferences", [
      const Text("Budget (In Cr)"),
      SfSlider(
        min: 1.5,
        max: 6,
        value: _budgetValue,
        interval: 1,
        showTicks: true,
        showLabels: true,
        enableTooltip: true,
        activeColor: AppColor.primary,
        inactiveColor: AppColor.primary.withOpacity(0.25),
        onChanged: (dynamic value) {
          setState(() {
            _budgetValue = value;
            _budgetC.text = value == 6 ? "5 & Above" : value.toString();
          });
        },
      ),

      verticalSpacing(height: 20),
      CustomDropDownWidget(
        title: "Possession Type",
        initialValue: selectedPossessionType,
        dataList: possessionType,
        onSelected: (v) => selectedPossessionType = v,
      ),
      CustomDropDownWidget(
        title: "Requirement",
        initialValue: selectedRequirement,
        dataList: requirementType,
        onSelected: (v) => selectedRequirement = v,
      ),
      CustomDropDownWidget(
        title: "Location",
        initialValue: selectedLocation,
        dataList: [],
        onSelected: (v) => selectedLocation = v,
      ),
      CustomDropDownWidget(
        title: "Timeline",
        initialValue: selectedTimeline,
        dataList: timelineTypeList,
        onSelected: (v) => selectedTimeline = v,
      ),
      CustomTextField(textController: _areaPrefC),
    ]);
  }

  Widget _customerDetailsCard() {
    return _card("Customer Details", [
      CustomDropDownWidget(
        title: "Source Of Funding",
        initialValue: selectedFunding,
        dataList: fundingSourceList,
        onSelected: (v) => selectedFunding = v,
      ),
      CustomDropDownWidget(
        title: "Ethnicity",
        initialValue: selectedEthnicity,
        dataList: ethnicityList,
        onSelected: (v) => selectedEthnicity = v,
      ),
    ]);
  }

  Widget _enquiryInfoCard() {
    return _card("Enquiry Information", [
      CustomDropDownWidget(
        title: "Stage",
        initialValue: selectedFinalStage,
        dataList: stageTypeList,
        onSelected: (v) => selectedFinalStage = v,
      ),
    ]);
  }

  Widget _followUpCard() {
    return _card("Follow Up Details", [
      CustomDatePicker(
        title: "Enquiry Date*",
        initialDate: enquiryDate,
        setValue: (v) => enquiryDate = v,
      ),
      CustomDatePicker(
        title: "Next Follow-Up Date*",
        initialDate: nextFollowUpDate,
        setValue: (v) => nextFollowUpDate = v,
      ),
    ]);
  }

  Widget _salesCard() {
    return _card("Sales Details", [
      const Text("Customer Time Out"),
      CustomTimePicker(
        initialTime: parseTimeOfDayFromHHmm(_timeOutC),
        setValue: (val) => _timeOutC = formatTimeOfDayHHmm(val),
      ),

      CustomTextField(title: "Remarks", textController: _remarkC, maxLines: 3),
    ]);
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          ...children,
        ],
      ),
    );
  }
}
