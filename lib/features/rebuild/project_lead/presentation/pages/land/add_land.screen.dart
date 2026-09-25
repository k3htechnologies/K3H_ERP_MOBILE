import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/land.model.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLandScreen extends StatefulWidget {
  final LandModel? land;
  final int? index;
  const AddLandScreen({super.key, this.land, this.index});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  late ProjectLeadCubit _projectLeadCubit;
  late TextEditingController _ownerNameC,
      _pinCodeC,
      _plotCTSSurveySubdivisionNumberC,
      _addressC,
      _wardNumberC,
      _totalPlotAreaSqMtC,
      _latitudeLongitudeMappingC,
      _identificationAndLocationC,
      _contactPersonC,
      _mobileNumberC,
      _emailIdC,
      _deptPlotC,
      _fsiPermissibleC,
      _nearestTownC,
      _distanceFromHighwayC,
      _distanceFromRailwayC,
      _distanceFromAirportC,
      _numberOfTreesOnSiteC,
      _frontageC,
      _remarksC;

  // EDIT MODE
  bool get _isEditMode => widget.land != null;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<Map<String, dynamic>?> selectedCountry = ValueNotifier({
    "zAttributesId": 1,
    "DisplayName": "India",
  });
  ValueNotifier<Map<String, dynamic>?> selectedStateVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedDistrictVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedCityVN = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedPlotShape = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedRoadWidth = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedSoilType = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedExistingGroundConditions =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedETypeOfWaterSupplyAvailable = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedSurroundingLandUse =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedTypeOfLandTenure =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedLandOwnershipType =
      ValueNotifier(null);
  final ValueNotifier<bool> _isPoaInvolved = ValueNotifier(false);
  final ValueNotifier<bool> _isFencingPresent = ValueNotifier(false);
  final ValueNotifier<bool> _isLandConvertedToNA = ValueNotifier(false);
  final ValueNotifier<bool> _isAccessRoadAvailable = ValueNotifier(false);
  final ValueNotifier<bool> _isElectricityConnectionNearby = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> _isUnderLitigation = ValueNotifier(false);
  final ValueNotifier<bool> _is712Available = ValueNotifier(false);

  MultiFilePickerModel projectPhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    _projectLeadCubit = context.read<ProjectLeadCubit>();
    initialiseControllers();
    if (_isEditMode) {
      prefillLand(widget.land!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _ownerNameC.dispose();
    _pinCodeC.dispose();
    _plotCTSSurveySubdivisionNumberC.dispose();
    _addressC.dispose();
    _wardNumberC.dispose();
    _totalPlotAreaSqMtC.dispose();
    _latitudeLongitudeMappingC.dispose();
    _identificationAndLocationC.dispose();
    _mobileNumberC.dispose();
    _contactPersonC.dispose();
    _emailIdC.dispose();
    _deptPlotC.dispose();
    _fsiPermissibleC.dispose();
    selectedCountry.dispose();
    selectedStateVN.dispose();
    selectedDistrictVN.dispose();
    selectedCityVN.dispose();
    _nearestTownC.dispose();
    _distanceFromHighwayC.dispose();
    _distanceFromRailwayC.dispose();
    _distanceFromAirportC.dispose();
    _numberOfTreesOnSiteC.dispose();
    _isPoaInvolved.dispose();
    _isFencingPresent.dispose();
    _isLandConvertedToNA.dispose();
    _isAccessRoadAvailable.dispose();
    _isElectricityConnectionNearby.dispose();
    _isUnderLitigation.dispose();
    _is712Available.dispose();
    _remarksC.dispose();
    _frontageC.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _ownerNameC = TextEditingController();
    _pinCodeC = TextEditingController();
    _plotCTSSurveySubdivisionNumberC = TextEditingController();
    _addressC = TextEditingController();
    _wardNumberC = TextEditingController();
    _totalPlotAreaSqMtC = TextEditingController();
    _latitudeLongitudeMappingC = TextEditingController();
    _identificationAndLocationC = TextEditingController();
    _contactPersonC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _emailIdC = TextEditingController();
    _deptPlotC = TextEditingController();
    _fsiPermissibleC = TextEditingController();
    _nearestTownC = TextEditingController();
    _distanceFromHighwayC = TextEditingController();
    _distanceFromRailwayC = TextEditingController();
    _distanceFromAirportC = TextEditingController();
    _numberOfTreesOnSiteC = TextEditingController();
    _remarksC = TextEditingController();
    _frontageC = TextEditingController();
  }

  void prefillLand(LandModel land) {
    _ownerNameC.text = land.landOwnerName;
    selectedCountry.value = {
      "DisplayName": land.countryName,
      "zAttributesId": land.countryMasterId,
    };
    selectedStateVN.value = {
      "DisplayName": land.stateName,
      "zAttributesId": land.stateMasterId,
    };

    selectedDistrictVN.value = {
      "DisplayName": land.districtName,
      "zAttributesId": land.districtMasterId,
    };

    selectedCityVN.value = {
      "DisplayName": land.cityName,
      "zAttributesId": land.cityMasterId,
    };
    _pinCodeC.text = land.pinCode;
    _plotCTSSurveySubdivisionNumberC.text =
        land.plotNumberCtsNumberSurveyNumberSubdivisionNumber;
    projectPhotoImage.fileNameList =
        land.photoUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    _addressC.text = land.landAddress;
    _wardNumberC.text = land.wardNumberZone;
    _totalPlotAreaSqMtC.text = land.totalPlotAreaSqM.toString();
    _latitudeLongitudeMappingC.text = land.latitudeLongitude;
    _identificationAndLocationC.text = land.identificationLocation;
    _contactPersonC.text = land.contactPersonName;
    _mobileNumberC.text = land.contactPersonMobile;
    _emailIdC.text = land.contactPersonEmail;
    _selectedPlotShape.value = plotShapeList.firstWhere(
      (e) => e['DisplayName'] == land.plotShape,
      orElse: () => plotShapeList.first,
    );
    _deptPlotC.text = land.plotDepth.toString();
    _selectedRoadWidth.value = roadWidthList.firstWhere(
      (e) => e['DisplayName'] == land.roadWidth,
      orElse: () => roadWidthList.first,
    );
    _selectedSoilType.value = soilTypeList.firstWhere(
      (e) => e['DisplayName'] == land.soilType,
      orElse: () => soilTypeList.first,
    );
    _selectedExistingGroundConditions
        .value = selectedExistingGroundConditionsList.firstWhere(
      (e) => e['DisplayName'] == land.existingGroundCondition,
      orElse: () => selectedExistingGroundConditionsList.first,
    );
    _fsiPermissibleC.text = land.fsiPermissible.toString();
    _selectedETypeOfWaterSupplyAvailable
        .value = selectedETypeOfWaterSupplyAvailableList.firstWhere(
      (e) => e['DisplayName'] == land.waterSupplyAvailable,
      orElse: () => selectedETypeOfWaterSupplyAvailableList.first,
    );
    _selectedSurroundingLandUse.value =
        land.surroundingLandUse.isEmpty
            ? null
            : selectedSurroundingLandUseList.firstWhere(
              (e) => e['DisplayName'] == land.surroundingLandUse,
              orElse: () => selectedSurroundingLandUseList.first,
            );
    _selectedTypeOfLandTenure.value = selectedTypeOfLandTenureList.firstWhere(
      (e) => e['DisplayName'] == land.typeOfLandTenureType,
      orElse: () => selectedTypeOfLandTenureList.first,
    );

    _selectedLandOwnershipType.value =
        land.landOwnershipType.isEmpty
            ? null
            : selectedselectedLandOwnershipList.firstWhere(
              (e) => e['DisplayName'] == land.landOwnershipType,
              orElse: () => selectedselectedLandOwnershipList.first,
            );
    _nearestTownC.text = land.distanceFromNearestTownKm.toString();
    _distanceFromHighwayC.text = land.distanceFromHighwayKm.toString();
    _distanceFromRailwayC.text = land.distanceFromRailwayStationKm.toString();
    _distanceFromAirportC.text = land.distanceFromAirportKm.toString();
    _numberOfTreesOnSiteC.text = land.totalNumberOfTreesonSite.toString();
    _isPoaInvolved.value = land.isAnyPowerofAttorneyInvolved;
    _isFencingPresent.value = land.isFencingBoundaryWallPresent;
    _isLandConvertedToNA.value = land.isLandConvertedToNonAgricultural;
    _isAccessRoadAvailable.value = land.isAccessRoadAvailable;
    _isElectricityConnectionNearby.value = land.isElectricityConnectionNearby;
    _isUnderLitigation.value = land.isUnderLitigationOrStayOrder;
    _is712Available.value = land.is712Available;
    _remarksC.text = land.remark;
    _frontageC.text = land.frontage.toString();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      _projectLeadCubit.updateLand(
        context: context,
        projectLandId: widget.land!.projectLandId,
        uniquekey: widget.land!.uniquekey,
        ownerName: _ownerNameC.text.trim(),
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        pinCode: _pinCodeC.text.trim(),
        plotCTSSurveySubdivisionNumberC:
            _plotCTSSurveySubdivisionNumberC.text.trim(),
        projectPhotoMap: projectPhotoImage,
        wardNumberZone: _wardNumberC.text.trim(),
        totalPlotAreaSqM: _totalPlotAreaSqMtC.text.trim(),
        isAnyPowerOfAttorneyInvolved: _isPoaInvolved.value,
        isFencingBoundaryWallPresent: _isFencingPresent.value,
        isLandConvertedToNonAgricultural: _isLandConvertedToNA.value,
        isAccessRoadAvailable: _isAccessRoadAvailable.value,
        isElectricityConnectionNearby: _isElectricityConnectionNearby.value,
        isUnderLitigationOrStayOrder: _isUnderLitigation.value,
        is712Available: _is712Available.value,
        landAddress: _addressC.text.trim(),
        identificationLocation: _identificationAndLocationC.text.trim(),
        latitudeLongitude: _latitudeLongitudeMappingC.text.trim(),
        contactPersonName: _contactPersonC.text.trim(),
        contactPersonMobile: _mobileNumberC.text.trim(),
        contactPersonEmail: _emailIdC.text.trim(),
        typeOfLandTenureType: _selectedTypeOfLandTenure.value!["DisplayName"],
        plotShape: _selectedPlotShape.value!["DisplayName"],
        frontage: _frontageC.text.trim(),
        plotDepth: _deptPlotC.text.trim(),
        roadWidth: _selectedRoadWidth.value!["DisplayName"],
        soilType: _selectedSoilType.value!["DisplayName"],
        existingGroundCondition:
            _selectedExistingGroundConditions.value!["DisplayName"],
        fsiPermissible: _fsiPermissibleC.text.trim(),
        waterSupplyAvailable:
            _selectedETypeOfWaterSupplyAvailable.value!["DisplayName"],
        surroundingLandUse:
            _selectedSurroundingLandUse.value?["DisplayName"] ?? '',
        landOwnershipType:
            _selectedLandOwnershipType.value?["DisplayName"] ?? '',
        distanceFromNearestTownKM: _nearestTownC.text.trim(),
        distanceFromHighwayKM: _distanceFromHighwayC.text.trim(),
        distanceFromRailwayStationKM: _distanceFromRailwayC.text.trim(),
        distanceFromAirportKM: _distanceFromAirportC.text.trim(),
        totalNumberOfTreesonSite: _numberOfTreesOnSiteC.text.trim(),
        remark: _remarksC.text.trim(),
      );
    } else {
      _projectLeadCubit.addLand(
        context: context,
        ownerName: _ownerNameC.text.trim(),
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        pinCode: _pinCodeC.text.trim(),
        plotCTSSurveySubdivisionNumberC:
            _plotCTSSurveySubdivisionNumberC.text.trim(),
        projectPhotoMap: projectPhotoImage,
        wardNumberZone: _wardNumberC.text.trim(),
        totalPlotAreaSqM: _totalPlotAreaSqMtC.text.trim(),
        isAnyPowerOfAttorneyInvolved: _isPoaInvolved.value,
        isFencingBoundaryWallPresent: _isFencingPresent.value,
        isLandConvertedToNonAgricultural: _isLandConvertedToNA.value,
        isAccessRoadAvailable: _isAccessRoadAvailable.value,
        isElectricityConnectionNearby: _isElectricityConnectionNearby.value,
        isUnderLitigationOrStayOrder: _isUnderLitigation.value,
        is712Available: _is712Available.value,
        landAddress: _addressC.text.trim(),
        identificationLocation: _identificationAndLocationC.text.trim(),
        latitudeLongitude: _latitudeLongitudeMappingC.text.trim(),
        contactPersonName: _contactPersonC.text.trim(),
        contactPersonMobile: _mobileNumberC.text.trim(),
        contactPersonEmail: _emailIdC.text.trim(),
        typeOfLandTenureType: _selectedTypeOfLandTenure.value!["DisplayName"],
        plotShape: _selectedPlotShape.value!["DisplayName"],
        frontage: _frontageC.text.trim(),
        plotDepth: _deptPlotC.text.trim(),
        roadWidth: _selectedRoadWidth.value!["DisplayName"],
        soilType: _selectedSoilType.value!["DisplayName"],
        existingGroundCondition:
            _selectedExistingGroundConditions.value!["DisplayName"],
        fsiPermissible: _fsiPermissibleC.text.trim(),
        waterSupplyAvailable:
            _selectedETypeOfWaterSupplyAvailable.value!["DisplayName"],
        surroundingLandUse:
            _selectedSurroundingLandUse.value?["DisplayName"] ?? '',
        landOwnershipType:
            _selectedLandOwnershipType.value?["DisplayName"] ?? '',
        distanceFromNearestTownKM: _nearestTownC.text.trim(),
        distanceFromHighwayKM: _distanceFromHighwayC.text.trim(),
        distanceFromRailwayStationKM: _distanceFromRailwayC.text.trim(),
        distanceFromAirportKM: _distanceFromAirportC.text.trim(),
        totalNumberOfTreesonSite: _numberOfTreesOnSiteC.text.trim(),
        remark: _remarksC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Land",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Land" : "Add Land",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card("Land : Property Details", [
                    CustomTextField(
                      title: "Land Owner Name",
                      hint: "Enter Land Owner Name",
                      textController: _ownerNameC,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Land Owner Name is required";
                        }
                        return null;
                      },
                    ),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        selectedCountry,
                        selectedStateVN,
                      ]),
                      builder: (context, _) {
                        return AddressWidget(
                          key: ValueKey(
                            "${selectedStateVN.value?['zAttributesId']}_${selectedCityVN.value?['zAttributesId']}",
                          ),
                          formKey: _formKey,
                          incomingCountryId:
                              selectedCountry.value?['zAttributesId'] ?? 1,

                          incomingStateId:
                              selectedStateVN.value?['zAttributesId'],
                          incomingDistrictId:
                              selectedDistrictVN.value?['zAttributesId'],
                          incomingCityId:
                              selectedCityVN.value?['zAttributesId'],
                          stateChange: (val) => selectedStateVN.value = val,
                          districtChange:
                              (val) => selectedDistrictVN.value = val,
                          cityChange: (val) => selectedCityVN.value = val,
                          countryChange: (val) => selectedCountry.value = val,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Pin Code",
                      hint: "Enter Pin Code",
                      textController: _pinCodeC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(6),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Pin Code is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Plot / CTS / Survey / Subdivision Number",
                      hint: "Enter Plot / CTS / Survey / Subdivision Number",
                      textController: _plotCTSSurveySubdivisionNumberC,
                      inputFormatterList: InputValidator.digitAndCharacterOnly(
                        100,
                      ),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Plot / CTS / Survey / Subdivision Number is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      initialFileList: projectPhotoImage.fileNameList,
                      title: "Land Photo",
                      filePickType: FilePickType.both,
                      isRequired: true,
                      onFilePickedCallback: (bytes, fileName) {
                        projectPhotoImage.fileBytesList = bytes;
                        projectPhotoImage.fileNameList = fileName;
                      },
                      onFileDeleteCallback: (bytes, fileName, deletedFiles) {
                        projectPhotoImage.fileBytesList = bytes;
                        projectPhotoImage.fileNameList = fileName;
                        projectPhotoImage.deletedFileList = deletedFiles;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Land Photo is required.";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Land Address",
                      hint: "Enter Land Address",
                      textController: _addressC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Land Address is required";
                        }
                        return null;
                      },
                    ),
                  ]),
                  verticalSpacing(),
                  _card("Plot Information", [
                    CustomTextField(
                      title: "Ward Number (Zone)",
                      hint: "Enter Ward Number (Zone)",
                      textController: _wardNumberC,
                    ),
                    CustomTextField(
                      title: "Total Plot Area (SqMt)",
                      hint: "Enter Total Plot Area",
                      textController: _totalPlotAreaSqMtC,
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total plot area is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Latitude & Longitude (For GIS Mapping)",
                      hint: "Enter Latitude & Longitude (For GIS Mapping)",
                      textController: _latitudeLongitudeMappingC,
                    ),
                    CustomTextField(
                      title: "Identification And Location",
                      hint: "Enter Identification And Location",
                      textController: _identificationAndLocationC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Identification And Location is required";
                        }
                        final googleMapRegex = RegExp(
                          r'^(https?:\/\/)?(www\.)?(google\.[a-z.]+\/maps(\?|\/)|maps\.google\.[a-z.]+|maps\.app\.goo\.gl|goo\.gl\/maps|share\.google)\/?.*$',
                          caseSensitive: false,
                        );
                        if (!googleMapRegex.hasMatch(value.trim())) {
                          return "Please enter a valid Google Maps location link";
                        }
                        return null;
                      },
                    ),
                  ]),
                  verticalSpacing(),
                  _card("Contact Information", [
                    CustomTextField(
                      title: 'Contact Person For Land Name',
                      textController: _contactPersonC,
                      hint: "Enter Contact Person For Land Name",
                      inputFormatterList: InputValidator.textOnly(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Contact Person For Land Name is required.";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Contact Person Mobile Number',
                      textController: _mobileNumberC,
                      keyboardType: TextInputType.number,
                      hint: "Enter Contact Person Mobile Number",
                      isRequired: true,
                      inputFormatterList: InputValidator.digit(10),
                      prefixType: CustomTextFieldPrefix.mobile,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Contact Person Mobile Number is required.";
                        }
                        if (!InputValidator.isValidMobileNumber(value)) {
                          return "Invalid Contact Person Mobile Number";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _emailIdC,
                      title: "Contact Person E-Mail ID",
                      hint: "Enter Contact Person E-Mail ID",
                    ),
                  ]),
                  verticalSpacing(),
                  _card("Land & Plot Characteristics", [
                    ValueListenableBuilder(
                      valueListenable: _selectedPlotShape,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Plot Shape',
                          hintText: 'Select Plot Shape',
                          isRequired: true,
                          dataList: plotShapeList,
                          initialValue: value,
                          onSelected: (v) => _selectedPlotShape.value = v,
                          validator:
                              (v) =>
                                  v == null ? "Plot Shape is required" : null,
                          onValueClear: () => _selectedPlotShape.value = null,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Depth Of The Plot",
                      hint: "Enter Depth Of The Plot",
                      textController: _deptPlotC,
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Depth Of The Plot is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedRoadWidth,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Road Width',
                          hintText: 'Select Road Width',
                          isRequired: true,
                          dataList: roadWidthList,
                          initialValue: value,
                          onSelected: (v) => _selectedRoadWidth.value = v,
                          validator:
                              (v) =>
                                  v == null ? "Road Width is required" : null,
                          onValueClear: () => _selectedRoadWidth.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedSoilType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Soil Type',
                          hintText: 'Select Soil Type',
                          isRequired: true,
                          dataList: soilTypeList,
                          initialValue: value,
                          onSelected: (v) => _selectedSoilType.value = v,
                          validator:
                              (v) => v == null ? "Soil Type is required" : null,
                          onValueClear: () => _selectedSoilType.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedExistingGroundConditions,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Existing Ground Conditions',
                          hintText: 'Select Existing Ground Conditions',
                          isRequired: true,
                          dataList: selectedExistingGroundConditionsList,
                          initialValue: value,
                          onSelected:
                              (v) =>
                                  _selectedExistingGroundConditions.value = v,
                          validator:
                              (v) =>
                                  v == null
                                      ? "Existing Ground Conditions is required"
                                      : null,
                          onValueClear:
                              () =>
                                  _selectedExistingGroundConditions.value =
                                      null,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "FSI Permissible (Base + TDR if allowed)",
                      hint: "Enter FSI Permissible (Base + TDR if allowed)",
                      textController: _fsiPermissibleC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedETypeOfWaterSupplyAvailable,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Type Of Water Supply Available',
                          hintText: 'Select Type Of Water Supply Available',
                          isRequired: true,
                          dataList: selectedETypeOfWaterSupplyAvailableList,
                          initialValue: value,
                          onSelected:
                              (v) =>
                                  _selectedETypeOfWaterSupplyAvailable.value =
                                      v,
                          validator:
                              (v) =>
                                  v == null
                                      ? "Type Of Water Supply Available is required"
                                      : null,
                          onValueClear:
                              () =>
                                  _selectedETypeOfWaterSupplyAvailable.value =
                                      null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedSurroundingLandUse,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Surrounding Land Use',
                          hintText: 'Select Surrounding Land Use',
                          dataList: selectedSurroundingLandUseList,
                          initialValue: value,
                          onSelected:
                              (v) => _selectedSurroundingLandUse.value = v,
                          onValueClear:
                              () => _selectedSurroundingLandUse.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedTypeOfLandTenure,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Type Of Land Tenure',
                          hintText: 'Select Type Of Land Tenure',
                          isRequired: true,
                          dataList: selectedTypeOfLandTenureList,
                          initialValue: value,
                          onSelected:
                              (v) => _selectedTypeOfLandTenure.value = v,
                          validator:
                              (v) =>
                                  v == null
                                      ? "Type Of Land Tenure is required"
                                      : null,
                          onValueClear:
                              () => _selectedTypeOfLandTenure.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedLandOwnershipType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Land Ownership Type',
                          hintText: 'Select Land Ownership Type',
                          dataList: selectedselectedLandOwnershipList,
                          initialValue: value,
                          onSelected:
                              (v) => _selectedLandOwnershipType.value = v,
                          onValueClear:
                              () => _selectedLandOwnershipType.value = null,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Distance From Nearest Town (KM)",
                      hint: "Nearest Town (KM)",
                      textController: _nearestTownC,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                    ),
                    CustomTextField(
                      title: "Distance From Highway (KM)",
                      hint: "Highway (KM)",
                      textController: _distanceFromHighwayC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                    ),
                    CustomTextField(
                      title: "Distance From Railway Station (KM)",
                      hint: "Railway Station (KM)",
                      textController: _distanceFromRailwayC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                    ),
                    CustomTextField(
                      title: "Distance From Airport (KM)",
                      hint: "Airport (KM)",
                      textController: _distanceFromAirportC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                    ),
                    CustomTextField(
                      textController: _numberOfTreesOnSiteC,
                      title: 'Total Number Of Trees On Site',
                      hint: 'Enter Total Number Of Trees On Site',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isPoaInvolved,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Any Power Of Attorney (POA) involved?",
                          isSelected: value,
                          onChanged: (newValue) {
                            _isPoaInvolved.value = newValue;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isFencingPresent,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Fencing / Boundary wall present?",
                          isSelected: value,
                          onChanged: (newValue) {
                            _isFencingPresent.value = newValue;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLandConvertedToNA,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Land Converted to Non - Agriculture?",
                          isSelected: value,
                          onChanged: (value) {
                            _isLandConvertedToNA.value = value;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isAccessRoadAvailable,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Availability of access road?",
                          isSelected: value,
                          onChanged: (value) {
                            _isAccessRoadAvailable.value = value;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isElectricityConnectionNearby,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Electricity connection nearby?",
                          isSelected: value,
                          onChanged: (value) {
                            _isElectricityConnectionNearby.value = value;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isUnderLitigation,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Plot Under Litigation / Stay Orders?",
                          isSelected: value,
                          onChanged: (value) {
                            _isUnderLitigation.value = value;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _is712Available,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "7 / 12?",
                          isSelected: value,
                          onChanged: (value) {
                            _is712Available.value = value;
                          },
                        );
                      },
                    ),
                  ]),
                  verticalSpacing(),
                  _card("Additional Information", [
                    CustomTextField(
                      title: "Remarks",
                      hint: "Enter Remarks",
                      textController: _remarksC,
                      minLines: 3,
                      maxLines: 10,
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
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
