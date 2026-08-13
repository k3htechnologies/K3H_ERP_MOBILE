import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBuildingScreen extends StatefulWidget {
  final BusinessDevelopmentBuildingModel? building;
  final int index;
  final int? projectId;

  const AddBuildingScreen({
    super.key,
    this.building,
    this.index = 0,
    this.projectId,
  });

  @override
  State<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends State<AddBuildingScreen> {
  late BuildingCubit _buildingCubit;
  late AuthorizationModel _routhAuthorizationModel;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _buildingNameC,
      _ctsNumberC,
      _totalPlotAreaSqMtC,
      _totalPlotAreaSqFtC,
      _totalNumberOfUnitsC,
      _totalUnitsAreaUtilizedC,
      _totalGardenAreaC,
      _totalReligiousStructureAreaC,
      _propertyAgeYearsC,
      _numberOfFloorsC,
      _numberOfWingsC,
      _fsiTdrUtilizationC,
      _litigationRemarksC,
      _googleLocationC,
      _searchC;

  int? _countryMasterId;
  int? _stateMasterId;
  int? _districtMasterId;
  int? _cityMasterId;
  int? _villageMasterId;
  int? _wardMasterId;

  final ValueNotifier<bool> _isGarden = ValueNotifier(false);
  final ValueNotifier<bool> _isReligiousStructure = ValueNotifier(false);
  final ValueNotifier<bool> _isLitigation = ValueNotifier(false);

  final ValueNotifier<Map<String, dynamic>?> _selectedLandOwnershipType =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _ownershipTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Landlord'},
    {'zAttributesId': 2, 'DisplayName': 'Society'},
    {'zAttributesId': 3, 'DisplayName': 'Government'},
  ];

  final ValueNotifier<Map<String, dynamic>?> _selectedRoadWidth =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _roadWidthList = [
    {'zAttributesId': 1, 'DisplayName': '6.10 M'},
    {'zAttributesId': 2, 'DisplayName': '9.15 M'},
    {'zAttributesId': 3, 'DisplayName': '12.20 M'},
    {'zAttributesId': 4, 'DisplayName': '13.40 M'},
    {'zAttributesId': 5, 'DisplayName': '18.3 M'},
    {'zAttributesId': 6, 'DisplayName': '27.45 M'},
    {'zAttributesId': 7, 'DisplayName': '36.6 M'},
  ];

  late int _projectId;

  bool get _isEditMode => widget.building != null;

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _buildingCubit = context.read<BuildingCubit>();
    _projectId = widget.projectId ?? getProject().projectId;
    _routhAuthorizationModel = AuthorizationModel();
    if (_isEditMode) {
      _populateFormFields(widget.building!);
    }
  }

  @override
  void dispose() {
    _selectedLandOwnershipType.dispose();
    _selectedRoadWidth.dispose();
    _buildingNameC.dispose();
    _ctsNumberC.dispose();
    _googleLocationC.dispose();
    _totalPlotAreaSqFtC.dispose();
    _totalNumberOfUnitsC.dispose();
    _numberOfWingsC.dispose();
    _totalUnitsAreaUtilizedC.dispose();
    _totalGardenAreaC.dispose();
    _totalReligiousStructureAreaC.dispose();
    _propertyAgeYearsC.dispose();
    _numberOfFloorsC.dispose();
    _fsiTdrUtilizationC.dispose();
    _litigationRemarksC.dispose();
    _searchC.dispose();
    _totalPlotAreaSqMtC.dispose();
    super.dispose();
  }

  void initializeTextEditingController() {
    _buildingNameC = TextEditingController();
    _ctsNumberC = TextEditingController();
    _googleLocationC = TextEditingController();
    _totalPlotAreaSqFtC = TextEditingController();
    _totalNumberOfUnitsC = TextEditingController();
    _numberOfWingsC = TextEditingController();
    _totalUnitsAreaUtilizedC = TextEditingController();
    _totalGardenAreaC = TextEditingController();
    _totalReligiousStructureAreaC = TextEditingController();
    _propertyAgeYearsC = TextEditingController();
    _numberOfFloorsC = TextEditingController();
    _fsiTdrUtilizationC = TextEditingController();
    _litigationRemarksC = TextEditingController();
    _searchC = TextEditingController();
    _totalPlotAreaSqMtC = TextEditingController();
  }

  void _populateFormFields(BusinessDevelopmentBuildingModel buildingModel) {
    _buildingNameC.text = buildingModel.buildingName;
    _ctsNumberC.text = buildingModel.cTSNumber;
    _googleLocationC.text = buildingModel.googleLocation;
    _totalPlotAreaSqFtC.text = buildingModel.totalPlotAreaSqFt.toString();
    _totalPlotAreaSqMtC.text = buildingModel.totalPlotAreaSqMt.toString();
    _totalNumberOfUnitsC.text = buildingModel.totalNumberOfUnits.toString();
    _totalUnitsAreaUtilizedC.text =
        buildingModel.totalUnitsAreaUtilizedSqFt.toString();
    _totalGardenAreaC.text = buildingModel.totalGardenAreaSqFt.toString();
    _totalReligiousStructureAreaC.text =
        buildingModel.totalReligiousStructureAreaSqFt.toString();
    _propertyAgeYearsC.text = buildingModel.propertyAgeYears.toString();
    _numberOfFloorsC.text = buildingModel.numberOfFloors.toString();
    _fsiTdrUtilizationC.text = buildingModel.fSITDRUtilizationSqFt.toString();
    _litigationRemarksC.text = buildingModel.litigationRemarks;
    _numberOfWingsC.text = buildingModel.numberOfWings.toString();
    _countryMasterId = buildingModel.countryMasterId;
    _stateMasterId = buildingModel.stateMasterId;
    _districtMasterId = buildingModel.districtMasterId;
    _cityMasterId = buildingModel.cityMasterId;
    _villageMasterId = buildingModel.villageMasterId;
    _wardMasterId = buildingModel.wardMasterId;
    _isGarden.value = buildingModel.isGarden;
    _isReligiousStructure.value = buildingModel.isReligiousStructure;
    _isLitigation.value = buildingModel.isLitigation;
    _selectedLandOwnershipType.value =
        buildingModel.landOwnershipType == ""
            ? null
            : _ownershipTypeList.firstWhere(
              (element) =>
                  element['DisplayName'] == buildingModel.landOwnershipType,
              orElse: () => _ownershipTypeList.first,
            );

    _selectedRoadWidth.value =
        (buildingModel.roadWidth.isNotEmpty)
            ? _roadWidthList.firstWhere(
              (element) => element['DisplayName'] == buildingModel.roadWidth,
              orElse: () => _roadWidthList.first,
            )
            : _roadWidthList.first;
  }

  Future<void> _addUpdateBuilding(
    BuildContext context,
    BusinessDevelopmentBuildingModel? buildingModel,
    BuildingState state,
  ) async {
    if (_formKey.currentState!.validate()) {
      _isEditMode
          ? _buildingCubit.updateBuilding(
            context: context,
            projectId: _projectId,
            index: widget.index,
            buildingId: buildingModel!.buildingId,
            uniqueKey: buildingModel.uniquekey,
            buildingName: _buildingNameC.text.trim(),
            ctsNumber: _ctsNumberC.text.trim(),
            googleLocation: _googleLocationC.text.trim(),
            totalPlotAreaSqFt: double.tryParse(_totalPlotAreaSqFtC.text) ?? 0.0,
            totalPlotAreaSqMt: double.tryParse(_totalPlotAreaSqMtC.text) ?? 0.0,
            roadWidth: _selectedRoadWidth.value?['DisplayName'] ?? '',
            countryMasterId: _countryMasterId ?? 1,
            districtMasterId: _districtMasterId,
            stateMasterId: _stateMasterId,
            cityMasterId: _cityMasterId,
            villageMasterId: _villageMasterId,
            wardMasterId: _wardMasterId,
            totalNumberOfUnits: int.tryParse(_totalNumberOfUnitsC.text) ?? 0,
            totalUnitsAreaUtilizedSqFt:
                double.tryParse(_totalUnitsAreaUtilizedC.text) ?? 0.0,
            isGarden: _isGarden.value,
            totalGardenAreaSqFt: double.tryParse(_totalGardenAreaC.text) ?? 0.0,
            isReligiousStructure: _isReligiousStructure.value,
            totalReligiousStructureAreaSqFt:
                double.tryParse(_totalReligiousStructureAreaC.text) ?? 0.0,
            propertyAgeYears: int.tryParse(_propertyAgeYearsC.text) ?? 0,
            numberOfFloors: int.tryParse(_numberOfFloorsC.text) ?? 0,
            numberOfWings: int.tryParse(_numberOfWingsC.text) ?? 0,
            fsiTdrUtilizationSqFt:
                double.tryParse(_fsiTdrUtilizationC.text) ?? 0.0,
            landOwnershipType:
                _selectedLandOwnershipType.value?['DisplayName'] ?? '',
            isLitigation: _isLitigation.value,
            litigationRemarks: _litigationRemarksC.text.trim(),
          )
          : _buildingCubit.addBuilding(
            context: context,
            projectId: _projectId,
            buildingName: _buildingNameC.text.trim(),
            ctsNumber: _ctsNumberC.text.trim(),
            googleLocation: _googleLocationC.text.trim(),
            totalPlotAreaSqFt: double.tryParse(_totalPlotAreaSqFtC.text) ?? 0.0,
            totalPlotAreaSqMt: double.tryParse(_totalPlotAreaSqMtC.text) ?? 0.0,
            roadWidth: _selectedRoadWidth.value?['DisplayName'] ?? '',
            countryMasterId: _countryMasterId ?? 1,
            districtMasterId: _districtMasterId,
            stateMasterId: _stateMasterId,
            cityMasterId: _cityMasterId,
            villageMasterId: _villageMasterId,
            wardMasterId: _wardMasterId,
            totalNumberOfUnits: int.tryParse(_totalNumberOfUnitsC.text) ?? 0,
            totalUnitsAreaUtilizedSqFt:
                double.tryParse(_totalUnitsAreaUtilizedC.text) ?? 0.0,
            isGarden: _isGarden.value,
            totalGardenAreaSqFt: double.tryParse(_totalGardenAreaC.text) ?? 0.0,
            isReligiousStructure: _isReligiousStructure.value,
            totalReligiousStructureAreaSqFt:
                double.tryParse(_totalReligiousStructureAreaC.text) ?? 0.0,
            propertyAgeYears: int.tryParse(_propertyAgeYearsC.text) ?? 0,
            numberOfFloors: int.tryParse(_numberOfFloorsC.text) ?? 0,
            numberOfWings: int.tryParse(_numberOfWingsC.text) ?? 0,
            fsiTdrUtilizationSqFt:
                double.tryParse(_fsiTdrUtilizationC.text) ?? 0.0,
            landOwnershipType:
                _selectedLandOwnershipType.value?['DisplayName'] ?? '',
            isLitigation: _isLitigation.value,
            litigationRemarks: _litigationRemarksC.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building",
        authorization: _routhAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Building" : "Add Building",
                style: AppTextStyle.ts14M(),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Building Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _buildingNameC,
                      title: 'Building Name',
                      hint: 'Enter Building Name',
                      isRequired: true,
                      inputFormatterList: InputValidator.textOnly(100),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Building name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Building name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _ctsNumberC,
                      title: 'CTS Number',
                      hint: 'Enter CTS Number',
                      isRequired: true,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CTS number is required';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedRoadWidth,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          title: 'Road Width',
                          hintText: 'Select Road Width',
                          isRequired: true,
                          dataList: _roadWidthList,
                          initialValue: selectedValue,
                          onSelected: (selected) {
                            _selectedRoadWidth.value = selected;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Road width is required';
                            }
                            return null;
                          },
                          onValueClear: () => _selectedRoadWidth.value = null,
                        );
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedLandOwnershipType,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          title: 'Land Ownership Type',
                          hintText: 'Select Land Ownership Type',
                          dataList: _ownershipTypeList,
                          initialValue: selectedValue,
                          onSelected: (selected) {
                            _selectedLandOwnershipType.value = selected;
                          },
                          onValueClear:
                              () => _selectedLandOwnershipType.value = null,
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _googleLocationC,
                      title: "Google Location",
                      isRequired: true,
                      hint: "Enter Google Location",
                      suffixWidget: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Google Location is required";
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
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Property Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _totalPlotAreaSqMtC,
                      title: 'Total Plot Area (SqMt)',
                      hint: 'Enter Total Plot Area',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total plot area is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _totalPlotAreaSqFtC,
                      title: 'Total Plot Area (SqFt)',
                      hint: 'Enter Total Plot Area',
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                    ),
                    CustomTextField(
                      textController: _totalUnitsAreaUtilizedC,
                      title: "Utilized Units Area (SqFt)",
                      hint: 'Enter Utilized Units Area',
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                    ),
                    CustomTextField(
                      textController: _totalNumberOfUnitsC,
                      title: 'Total Units',
                      hint: 'Enter Total Units',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                    ),
                    CustomTextField(
                      textController: _numberOfFloorsC,
                      title: 'Number of Floors',
                      hint: 'Enter Number of Floors',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                    CustomTextField(
                      textController: _numberOfWingsC,
                      title: 'Number of Wings',
                      hint: 'Enter Number of Wings',
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FSI / TDR Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _propertyAgeYearsC,
                      title: 'Property Age (Years)',
                      hint: 'Enter Property Age',
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(5),
                    ),
                    CustomTextField(
                      textController: _fsiTdrUtilizationC,
                      title: 'FSI / TDR Utilization (SqFt)',
                      hint: 'Enter FSI / TDR Utilization',
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(10),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Additional Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _isGarden,
                      builder: (context, isGarden, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isGarden,
                                  onChanged: (value) {
                                    _isGarden.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Garden', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),

                            CustomTextField(
                              textController: _totalGardenAreaC,
                              isRequired: isGarden,
                              readOnly: !isGarden,
                              title: 'Garden Area (SqFt)',
                              hint: 'Enter Garden Area (SqFt)',
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    7,
                                  ),
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    isGarden) {
                                  return 'Garden Area is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isReligiousStructure,
                      builder: (context, isReligiousStructure, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isReligiousStructure,
                                  onChanged: (value) {
                                    _isReligiousStructure.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text(
                                  'Religious Structure',
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              isRequired: isReligiousStructure,
                              readOnly: !isReligiousStructure,
                              textController: _totalReligiousStructureAreaC,
                              title: 'Religious Structure Area (SqFt)',
                              hint: 'Enter Religious Structure Area (SqFt)',
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    7,
                                  ),
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    isReligiousStructure) {
                                  return 'Religious Structure Area is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isLitigation,
                      builder: (context, isLitigation, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: isLitigation,
                                  onChanged: (value) {
                                    _isLitigation.value = value;
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Litigation', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              isRequired: isLitigation,
                              textController: _litigationRemarksC,
                              title: 'Litigation Remarks',
                              readOnly: !isLitigation,
                              hint: 'Enter Litigation Remarks',
                              inputFormatterList: InputValidator.textDigit(500),
                              validator: (value) {
                                if (isLitigation) {
                                  if ((value == null || value.trim().isEmpty)) {
                                    return 'Litigation remark is required';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    AddressWidget(
                      formKey: _formKey,
                      incomingCountryId: _countryMasterId ?? 1,
                      incomingStateId: _stateMasterId,
                      incomingDistrictId: _districtMasterId,
                      incomingCityId: _cityMasterId,
                      incomingVillageId: _villageMasterId,
                      incomingWardId: _wardMasterId,
                      countryChange: (selectedCountry) {
                        _countryMasterId = selectedCountry['zAttributesId'];
                      },
                      stateChange: (selectedState) {
                        _stateMasterId = selectedState['zAttributesId'];
                      },
                      districtChange: (selectedDistrict) {
                        _districtMasterId = selectedDistrict['zAttributesId'];
                      },
                      cityChange: (selectedCity) {
                        _cityMasterId = selectedCity['zAttributesId'];
                      },
                      villageChange: (selectedVillage) {
                        _villageMasterId = selectedVillage['zAttributesId'];
                      },
                      wardChange: (selectedWard) {
                        _wardMasterId = selectedWard['zAttributesId'];
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            onPressed: () {
              _addUpdateBuilding(
                context,
                widget.building,
                _buildingCubit.state,
              );
            },
          ),
        ),
      ),
    );
  }
}
