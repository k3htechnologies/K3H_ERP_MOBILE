import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/redevelopment.model.dart';
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

class AddRedevelopmentScreen extends StatefulWidget {
  final RedevelopmentModel? redevelopment;
  final int? index;
  const AddRedevelopmentScreen({super.key, this.redevelopment, this.index});

  @override
  State<AddRedevelopmentScreen> createState() => _AddRedevelopmentScreenState();
}

class _AddRedevelopmentScreenState extends State<AddRedevelopmentScreen> {
  late ProjectLeadCubit _projectLeadCubit;
  late TextEditingController _buildingNameC,
      _pinCodeC,
      _plotCTSSurveySubdivisionNumberC,
      _buildingAddressC,
      _wardNumberC,
      _totalPlotAreaSqMtC,
      _yearOfOriginalConstructionC,
      _numberOfExistingFloorsC,
      _totalNumberOfExistingFlatsUnitsC,
      _latitudeLongitudeMappingC,
      _identificationAndLocationC,
      _contactPersonC,
      _mobileNumberC,
      _emailIdC,
      _percentageMemberInFavor,
      _deptPlotC,
      _numberOfExistingBuildingWingsC,
      _numberOfFloorPerWingsC,
      _totalBuildUpAreaC,
      _totalCarpetAreaC,
      _totalCommonAreaC,
      _remarksC;
  // EDIT MODE
  bool get _isEditMode => widget.redevelopment != null;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<Map<String, dynamic>?> selectedCountry = ValueNotifier({
    "zAttributesId": 1,
    "DisplayName": "India",
  });
  ValueNotifier<Map<String, dynamic>?> selectedStateVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedDistrictVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedCityVN = ValueNotifier(null);
  MultiFilePickerModel projectPhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedExistingBuildingType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedTypeOfLandTenure =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedPlotShape = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedRoadWidth = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedConstructionType =
      ValueNotifier(null);
  final ValueNotifier<bool> _isListAvailable = ValueNotifier(false);
  final ValueNotifier<bool> _isFireSafetyProvisions = ValueNotifier(false);
  final ValueNotifier<bool> _isPlotUnderLitigationStayOrders = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> _isConveyanceDeed = ValueNotifier(false);

  @override
  void initState() {
    _projectLeadCubit = context.read<ProjectLeadCubit>();
    initialiseControllers();
    if (_isEditMode) {
      prefillRedevelopment(widget.redevelopment!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _buildingNameC.dispose();
    selectedCountry.dispose();
    selectedStateVN.dispose();
    selectedDistrictVN.dispose();
    selectedCityVN.dispose();
    _pinCodeC.dispose();
    _plotCTSSurveySubdivisionNumberC.dispose();
    _buildingAddressC.dispose();
    _wardNumberC.dispose();
    _totalPlotAreaSqMtC.dispose();
    _yearOfOriginalConstructionC.dispose();
    _selectedExistingBuildingType.dispose();
    _numberOfExistingFloorsC.dispose();
    _totalNumberOfExistingFlatsUnitsC.dispose();
    _latitudeLongitudeMappingC.dispose();
    _identificationAndLocationC.dispose();
    _contactPersonC.dispose();
    _mobileNumberC.dispose();
    _emailIdC.dispose();
    _percentageMemberInFavor.dispose();
    _deptPlotC.dispose();
    _selectedTypeOfLandTenure.dispose();
    _selectedPlotShape.dispose();
    _selectedRoadWidth.dispose();
    _numberOfExistingBuildingWingsC.dispose();
    _numberOfFloorPerWingsC.dispose();
    _totalBuildUpAreaC.dispose();
    _totalCarpetAreaC.dispose();
    _totalCommonAreaC.dispose();
    _selectedConstructionType.dispose();

    _isListAvailable.dispose();
    _isFireSafetyProvisions.dispose();
    _isPlotUnderLitigationStayOrders.dispose();
    _isConveyanceDeed.dispose();
    _remarksC.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _buildingNameC = TextEditingController();
    _pinCodeC = TextEditingController();
    _plotCTSSurveySubdivisionNumberC = TextEditingController();
    _buildingAddressC = TextEditingController();
    _wardNumberC = TextEditingController();
    _totalPlotAreaSqMtC = TextEditingController();
    _yearOfOriginalConstructionC = TextEditingController();
    _numberOfExistingFloorsC = TextEditingController();
    _totalNumberOfExistingFlatsUnitsC = TextEditingController();
    _latitudeLongitudeMappingC = TextEditingController();
    _identificationAndLocationC = TextEditingController();
    _contactPersonC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _emailIdC = TextEditingController();
    _percentageMemberInFavor = TextEditingController();
    _deptPlotC = TextEditingController();
    _numberOfExistingBuildingWingsC = TextEditingController();
    _numberOfFloorPerWingsC = TextEditingController();
    _totalBuildUpAreaC = TextEditingController();
    _totalCarpetAreaC = TextEditingController();
    _totalCommonAreaC = TextEditingController();
    _remarksC = TextEditingController();
  }

  void prefillRedevelopment(RedevelopmentModel redevelopment) {
    _buildingNameC.text = redevelopment.buildingName;
    selectedCountry.value = {
      "DisplayName": redevelopment.countryName,
      "zAttributesId": redevelopment.countryMasterId,
    };
    selectedStateVN.value = {
      "DisplayName": redevelopment.stateName,
      "zAttributesId": redevelopment.stateMasterId,
    };

    selectedDistrictVN.value = {
      "DisplayName": redevelopment.districtName,
      "zAttributesId": redevelopment.districtMasterId,
    };

    selectedCityVN.value = {
      "DisplayName": redevelopment.cityName,
      "zAttributesId": redevelopment.cityMasterId,
    };
    _pinCodeC.text = redevelopment.pinCode;
    _plotCTSSurveySubdivisionNumberC.text =
        redevelopment.plotNumberCtsNumberSurveyNumberSubdivisionNumber;
    projectPhotoImage.fileNameList =
        redevelopment.photoUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    _buildingAddressC.text = redevelopment.buildingAddress;
    _wardNumberC.text = redevelopment.wardNumberZone;
    _totalPlotAreaSqMtC.text = redevelopment.totalPlotAreaSqM.toString();
    _yearOfOriginalConstructionC.text =
        redevelopment.yearOfOriginalConstruction.toString();

    _selectedExistingBuildingType.value = existingBuildingType.firstWhere(
      (e) => e['DisplayName'] == redevelopment.existingBuildingType,
      orElse: () => existingBuildingType.first,
    );
    _numberOfExistingFloorsC.text =
        redevelopment.numberOfExistingFloors.toString();
    _totalNumberOfExistingFlatsUnitsC.text =
        redevelopment.totalNumberExistingFlatsUnits.toString();
    _latitudeLongitudeMappingC.text = redevelopment.latitudeLongitude;
    _identificationAndLocationC.text = redevelopment.identificationLocation;
    _contactPersonC.text = redevelopment.contactPersonName;
    _mobileNumberC.text = redevelopment.contactPersonMobile;
    _emailIdC.text = redevelopment.contactPersonEmail;
    _percentageMemberInFavor.text =
        redevelopment.percentageMemberInFavor.toString();

    _selectedTypeOfLandTenure.value = selectedTypeOfLandTenureList.firstWhere(
      (e) => e['DisplayName'] == redevelopment.typeOfLandTenure,
      orElse: () => selectedTypeOfLandTenureList.first,
    );
    _selectedPlotShape.value = plotShapeList.firstWhere(
      (e) => e['DisplayName'] == redevelopment.plotShape,
      orElse: () => plotShapeList.first,
    );
    _deptPlotC.text = redevelopment.plotDepth.toString();
    _selectedRoadWidth.value = roadWidthList.firstWhere(
      (e) => e["DisplayName"] == redevelopment.roadWidth,
      orElse: () => roadWidthList.first,
    );
    _numberOfExistingBuildingWingsC.text =
        redevelopment.numberOfExistingBuildingsWings.toString();
    _numberOfFloorPerWingsC.text =
        redevelopment.numberOfFloorsPerWing.toString();
    _totalBuildUpAreaC.text = redevelopment.totalBuildUpArea.toString();
    _totalCarpetAreaC.text = redevelopment.totalCarpetArea.toString();
    _totalCommonAreaC.text = redevelopment.totalCommonArea.toString();
    _selectedConstructionType.value = constructionTypeList.firstWhere(
      (e) => e["DisplayName"] == redevelopment.constructionType,
      orElse: () => constructionTypeList.first,
    );
    _isListAvailable.value = redevelopment.isLiftAvailable;
    _isFireSafetyProvisions.value = redevelopment.isFireSafetyProvisionPresent;
    _isPlotUnderLitigationStayOrders.value =
        redevelopment.isPlotUnderLitigationStay;
    _isConveyanceDeed.value = redevelopment.isConveyanceDeed;
    _remarksC.text = redevelopment.remarks;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      _projectLeadCubit.updateRedevelopment(
        context: context,
        index: widget.index!,
        projectRedevelopmentId: widget.redevelopment!.projectRedevelopmentId,
        uniquekey: widget.redevelopment!.uniquekey,
        buildingName: _buildingNameC.text.trim(),
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        pinCode: _pinCodeC.text.trim(),
        plotCTSSurveySubdivisionNumberC:
            _plotCTSSurveySubdivisionNumberC.text.trim(),
        projectPhotoMap: projectPhotoImage,
        buildingAddress: _buildingAddressC.text.trim(),
        wardNumberZone: _wardNumberC.text.trim(),
        totalPlotAreaSqM: _totalPlotAreaSqMtC.text.trim(),
        yearOfOriginalConstruction: _yearOfOriginalConstructionC.text.trim(),
        existingBuildingType:
            _selectedExistingBuildingType.value!['DisplayName'],
        numberOfExistingFloors: _numberOfExistingFloorsC.text.trim(),
        totalNumberExistingFlatsUnits:
            _totalNumberOfExistingFlatsUnitsC.text.trim(),
        identificationLocation: _identificationAndLocationC.text.trim(),
        latitudeLongitude: _latitudeLongitudeMappingC.text.trim(),
        contactPersonName: _contactPersonC.text.trim(),
        contactPersonMobile: _mobileNumberC.text.trim(),
        contactPersonEmail: _emailIdC.text.trim(),
        percentageMemberInFavor: double.parse(_percentageMemberInFavor.text),
        typeOfLandTenureType: _selectedTypeOfLandTenure.value!["DisplayName"],
        plotShape: _selectedPlotShape.value!["DisplayName"],
        plotDepth: _deptPlotC.text.trim(),
        roadWidth: _selectedRoadWidth.value!["DisplayName"],
        numberOfExistingBuildingWings:
            _numberOfExistingBuildingWingsC.text.trim(),
        numberOfFloorPerWings: _numberOfFloorPerWingsC.text.trim(),
        totalBuildUpArea: _totalBuildUpAreaC.text.trim(),
        totalCarpetArea: _totalCarpetAreaC.text.trim(),
        totalCommonArea: _totalCommonAreaC.text.trim(),
        constructionType: _selectedConstructionType.value!["DisplayName"],
        isIsLiftAvailable: _isListAvailable.value,
        isFireSafetyProvisionPresent: _isFireSafetyProvisions.value,
        isPlotUnderLitigationStay: _isPlotUnderLitigationStayOrders.value,
        isConveyanceDeed: _isConveyanceDeed.value,
        remark: _remarksC.text.trim(),
      );
    } else {
      _projectLeadCubit.addRedevelopment(
        context: context,
        buildingName: _buildingNameC.text.trim(),
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        pnCode: _pinCodeC.text.trim(),
        plotCTSSurveySubdivisionNumberC:
            _plotCTSSurveySubdivisionNumberC.text.trim(),
        projectPhotoMap: projectPhotoImage,
        buildingAddress: _buildingAddressC.text.trim(),
        wardNumberZone: _wardNumberC.text.trim(),
        totalPlotAreaSqM: _totalPlotAreaSqMtC.text.trim(),
        yearOfOriginalConstruction: _yearOfOriginalConstructionC.text.trim(),
        existingBuildingType:
            _selectedExistingBuildingType.value!['DisplayName'],
        numberOfExistingFloors: _numberOfExistingFloorsC.text.trim(),
        totalNumberExistingFlatsUnits:
            _totalNumberOfExistingFlatsUnitsC.text.trim(),
        identificationLocation: _identificationAndLocationC.text.trim(),
        latitudeLongitude: _latitudeLongitudeMappingC.text.trim(),
        contactPersonName: _contactPersonC.text.trim(),
        contactPersonMobile: _mobileNumberC.text.trim(),
        contactPersonEmail: _emailIdC.text.trim(),
        percentageMemberInFavor: double.parse(_percentageMemberInFavor.text),
        typeOfLandTenureType: _selectedTypeOfLandTenure.value!["DisplayName"],
        plotShape: _selectedPlotShape.value!["DisplayName"],
        plotDepth: _deptPlotC.text.trim(),
        roadWidth: _selectedRoadWidth.value!["DisplayName"],
        numberOfExistingBuildingWings:
            _numberOfExistingBuildingWingsC.text.trim(),
        numberOfFloorPerWings: _numberOfFloorPerWingsC.text.trim(),
        totalBuildUpArea: _totalBuildUpAreaC.text.trim(),
        totalCarpetArea: _totalCarpetAreaC.text.trim(),
        totalCommonArea: _totalCommonAreaC.text.trim(),
        constructionType: _selectedConstructionType.value!["DisplayName"],
        isIsLiftAvailable: _isListAvailable.value,
        isFireSafetyProvisionPresent: _isFireSafetyProvisions.value,
        isPlotUnderLitigationStay: _isPlotUnderLitigationStayOrders.value,
        isConveyanceDeed: _isConveyanceDeed.value,
        remark: _remarksC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Redevlopment",
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
                _isEditMode ? "Update Redevelopment" : "Add Redevelopment",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card("Redevelopment : Property Details", [
                    CustomTextField(
                      title: "Building Name",
                      hint: "Enter Building Name",
                      textController: _buildingNameC,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Building Name is required.";
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
                      hint: "Enter Plot Number",
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
                      title: "Building Photo",
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
                          return "Building Photo is required.";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Building Address",
                      hint: "Enter Building Address",
                      textController: _buildingAddressC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Building Address is required";
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
                      title: "Year of Original Construction",
                      hint: "Enter Year of Original Construction",
                      textController: _yearOfOriginalConstructionC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Year of Original Construction is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedExistingBuildingType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: "Existing Building Type",
                          hintText: "Select Existing Building Type",
                          isRequired: true,
                          dataList: existingBuildingType,
                          initialValue: value,
                          onSelected: (value) {
                            _selectedExistingBuildingType.value = value;
                          },
                          onValueClear: () {
                            _selectedExistingBuildingType.value = null;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Existing Building Type is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Number of Existing Floors",
                      hint: "Enter Number of Existing Floors",
                      textController: _numberOfExistingFloorsC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Number of Existing Floors is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Total Number of Existing Flats / Units",
                      hint: "Enter Total Number of Existing Flats / Units",
                      textController: _totalNumberOfExistingFlatsUnitsC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total Number of Existing Flats / Units is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Latitude & Longitude (For GIS Mapping)",
                      hint: "Enter Latitude & Longitude (For GIS Mapping)",
                      textController: _latitudeLongitudeMappingC,
                      inputFormatterList: InputValidator.digitAndCharacterOnly(
                        50,
                      ),
                    ),
                    CustomTextField(
                      title: "Identification And Location",
                      hint: "Enter Identification And Location",
                      textController: _identificationAndLocationC,
                      prefixType: CustomTextFieldPrefix.location,
                      isRequired: true,
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
                      title: 'Contact Person Name',
                      textController: _contactPersonC,
                      hint: "Enter Contact Person Name",
                      inputFormatterList: InputValidator.textOnly(50),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Contact Person Name is required.";
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
                    CustomTextField(
                      textController: _percentageMemberInFavor,
                      isRequired: true,
                      prefixType: CustomTextFieldPrefix.percentage,
                      title: "Percentage of Member in Favor",
                      hint: "Enter Percentage of Member in Favor",
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.percentage(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Percentage of Member in Favor is required.";
                        }
                        return null;
                      },
                    ),
                  ]),
                  verticalSpacing(),
                  _card("Land & Plot Characteristics", [
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
                      keyboardType: TextInputType.number,
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
                  ]),
                  verticalSpacing(),
                  _card("Building Structure", [
                    CustomTextField(
                      title: "Number of Existing Building / Wings",
                      hint: "Enter Number of Existing Building / Wings",
                      textController: _numberOfExistingBuildingWingsC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Number of Existing Building / Wings is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Number Of Floor Per Wings",
                      hint: "Enter Number Of Floor Per Wings",
                      textController: _numberOfFloorPerWingsC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Number Of Floor Per Wings is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Total Build-Up Area (SqFt)",
                      hint: "Enter Total Build-Up Area",
                      textController: _totalBuildUpAreaC,
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total Build-Up Area is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Total Carpet Area (SqFt)",
                      hint: "Enter Total Carpet Area",
                      textController: _totalCarpetAreaC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total Carpet Area is required.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Total Common Area (SqFt)",
                      hint: "Enter Total Common Area",
                      textController: _totalCommonAreaC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total Common Area is required.';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedConstructionType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Construction Type',
                          hintText: 'Select Construction Type',
                          isRequired: true,
                          dataList: constructionTypeList,
                          initialValue: value,
                          onSelected:
                              (v) => _selectedConstructionType.value = v,
                          validator:
                              (v) =>
                                  v == null
                                      ? "Construction Type is required"
                                      : null,
                          onValueClear:
                              () => _selectedConstructionType.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isListAvailable,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Lift Available?",
                          isSelected: value,
                          onChanged: (newValue) {
                            _isListAvailable.value = newValue;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isFireSafetyProvisions,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Fire Safety Provisions Present?",
                          isSelected: value,
                          onChanged: (newValue) {
                            _isFireSafetyProvisions.value = newValue;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isPlotUnderLitigationStayOrders,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Plot Under Litigation / Stay Orders?",
                          isSelected: value,
                          onChanged: (value) {
                            _isPlotUnderLitigationStayOrders.value = value;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isConveyanceDeed,
                      builder: (context, value, child) {
                        return CustomCheckBox(
                          title: "Conveyance Deed?",
                          isSelected: value,
                          onChanged: (value) {
                            _isConveyanceDeed.value = value;
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
