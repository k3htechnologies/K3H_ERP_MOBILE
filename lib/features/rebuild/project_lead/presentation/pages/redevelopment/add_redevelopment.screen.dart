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
      _totalNumberOfExistingFlatsUnitsC;
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Redevelopment" : "Add Redevelopment",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              margin: EdgeInsets.only(bottom: 10),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: "Building Name",
                      hint: "Enter Building Name",
                      textController: _buildingNameC,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Building is required";
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
                      hint: "Pin Code",
                      textController: _pinCodeC,
                      isRequired: true,
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
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
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
                  ],
                ),
              ),
            ),
          ],
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
}
