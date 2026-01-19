import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBuildingScreen extends StatefulWidget {
  final RedevelopmentBuildingModel? building;
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
  // CUBIT
  late BuildingCubit _buildingCubit;

  // Authorization
  late AuthorizationModel _routhAuthorizationModel;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _buildingNameC,
      _ctsNumberC,
      _totalPlotAreaC,
      _totalNumberOfUnitsC,
      _totalUnitsAreaUtilizedC,
      _totalGardenAreaC,
      _totalReligiousStructureAreaC,
      _propertyAgeYearsC,
      _numberOfFloorsC,
      _fsiTdrUtilizationC,
      _litigationRemarksC,
      _searchC;

  // ADDRESS VARIABLES
  int? _stateMasterId;
  int? _districtMasterId;
  int? _cityMasterId;
  int? _villageMasterId;

  // CHECKBOX VARIABLES
  bool _isGarden = false;
  bool _isReligiousStructure = false;
  bool _isLitigation = false;

  // DROPDOWN VARIABLES
  final ValueNotifier<Map<String, dynamic>?> _selectedLandOwnershipType =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _ownershipTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Land Ownership Type'},
    {'zAttributesId': 1, 'DisplayName': 'Landlord'},
    {'zAttributesId': 2, 'DisplayName': 'Society'},
    {'zAttributesId': 3, 'DisplayName': 'Government'},
  ];

  final ValueNotifier<Map<String, dynamic>?> _selectedRoadWidth =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List<Map<String, dynamic>> _roadWidthList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Road Width'},
    {'zAttributesId': 1, 'DisplayName': '6.10 M'},
    {'zAttributesId': 2, 'DisplayName': '9.15 M'},
    {'zAttributesId': 3, 'DisplayName': '12.20 M'},
    {'zAttributesId': 4, 'DisplayName': '13.40 M'},
    {'zAttributesId': 5, 'DisplayName': '18.3 M'},
    {'zAttributesId': 6, 'DisplayName': '27.45 M'},
    {'zAttributesId': 7, 'DisplayName': '36.6 M'},
  ];

  // PROJECT ID VAR
  late int _projectId;

  bool get _isEditMode => widget.building != null;

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _buildingCubit = context.read<BuildingCubit>();
    _projectId = widget.projectId ?? getProject().projectId;
    _routhAuthorizationModel = AuthorizationModel();
    if (_isEditMode && widget.building != null) {
      _populateFormFields(widget.building!);
    }
  }

  @override
  void dispose() {
    _selectedLandOwnershipType.dispose();
    _selectedRoadWidth.dispose();
    _buildingNameC.dispose();
    _ctsNumberC.dispose();
    _totalPlotAreaC.dispose();
    _totalNumberOfUnitsC.dispose();
    _totalUnitsAreaUtilizedC.dispose();
    _totalGardenAreaC.dispose();
    _totalReligiousStructureAreaC.dispose();
    _propertyAgeYearsC.dispose();
    _numberOfFloorsC.dispose();
    _fsiTdrUtilizationC.dispose();
    _litigationRemarksC.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // INITIALIZING TEXT CONTROLLERS
  void initializeTextEditingController() {
    _buildingNameC = TextEditingController();
    _ctsNumberC = TextEditingController();
    _totalPlotAreaC = TextEditingController();
    _totalNumberOfUnitsC = TextEditingController();
    _totalUnitsAreaUtilizedC = TextEditingController();
    _totalGardenAreaC = TextEditingController();
    _totalReligiousStructureAreaC = TextEditingController();
    _propertyAgeYearsC = TextEditingController();
    _numberOfFloorsC = TextEditingController();
    _fsiTdrUtilizationC = TextEditingController();
    _litigationRemarksC = TextEditingController();
    _searchC = TextEditingController();
  }

  // PREFILL BUILDING
  void _populateFormFields(RedevelopmentBuildingModel buildingModel) {
    _buildingNameC.text = buildingModel.buildingName;
    _ctsNumberC.text = buildingModel.ctsNumber;
    _totalPlotAreaC.text = buildingModel.totalPlotAreaSqFt.toString();
    _totalNumberOfUnitsC.text = buildingModel.totalNumberOfUnits.toString();
    _totalUnitsAreaUtilizedC.text =
        buildingModel.totalUnitsAreaUtilizedSqFt.toString();
    _totalGardenAreaC.text = buildingModel.totalGardenAreaSqFt.toString();
    _totalReligiousStructureAreaC.text =
        buildingModel.totalReligiousStructureAreaSqFt.toString();
    _propertyAgeYearsC.text = buildingModel.propertyAgeYears.toString();
    _numberOfFloorsC.text = buildingModel.numberOfFloors.toString();
    _fsiTdrUtilizationC.text = buildingModel.fsiTdrUtilizationSqFt.toString();
    _litigationRemarksC.text = buildingModel.litigationRemarks;

    // Set address values
    _stateMasterId = buildingModel.stateMasterId;
    _districtMasterId = buildingModel.districtMasterId;
    _cityMasterId = buildingModel.cityMasterId;

    // SET CHECKBOX VALUES
    _isGarden = buildingModel.isGarden;
    _isReligiousStructure = buildingModel.isReligiousStructure;
    _isLitigation = buildingModel.isLitigation;

    // SET DROPDOWN VALUES
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

  // API CALLS TO ADD/UPDATE BUILDING
  Future<void> _addUpdateBuilding(
    BuildContext context,
    RedevelopmentBuildingModel? buildingModel,
    BuildingState state,
  ) async {
    if (_formKey.currentState!.validate()) {
      final buildingData = {
        'BuildingId': buildingModel?.buildingId ?? 0,
        if (buildingModel != null) 'UniqueKey': buildingModel.uniquekey,
        'ProjectId': _projectId,
        'BuildingName': _buildingNameC.text.trim(),
        'CTSNumber': _ctsNumberC.text.trim(),
        'TotalPlotAreaSqFt': double.tryParse(_totalPlotAreaC.text) ?? 0.0,
        'RoadWidth': _selectedRoadWidth.value?['DisplayName'] ?? '',
        'CountryMasterId': buildingModel?.countryMasterId ?? 1,
        'DistrictMasterId': _districtMasterId ?? 1,
        'StateMasterId': _stateMasterId ?? 1,
        'CityMasterId': _cityMasterId ?? 1,
        'VillageMasterId': _villageMasterId ?? 1,
        'TotalNumberOfUnits': int.tryParse(_totalNumberOfUnitsC.text) ?? 0,
        'TotalUnitsAreaUtilizedSqFt':
            double.tryParse(_totalUnitsAreaUtilizedC.text) ?? 0.0,
        'IsGarden': _isGarden,
        'TotalGardenAreaSqFt': double.tryParse(_totalGardenAreaC.text) ?? 0.0,
        'IsReligiousStructure': _isReligiousStructure,
        'TotalReligiousStructureAreaSqFt':
            double.tryParse(_totalReligiousStructureAreaC.text) ?? 0.0,
        'PropertyAgeYears': int.tryParse(_propertyAgeYearsC.text) ?? 0,
        'NumberOfFloors': int.tryParse(_numberOfFloorsC.text) ?? 0,
        'FSI_TDR_UtilizationSqFt':
            double.tryParse(_fsiTdrUtilizationC.text) ?? 0.0,
        'LandOwnershipType':
            _selectedLandOwnershipType.value?['DisplayName'] ?? '',
        'IsLitigation': _isLitigation,
        'LitigationRemarks': _litigationRemarksC.text.trim(),
      };

      buildingModel != null
          ? _buildingCubit.updateBuilding(
            context,
            _projectId,
            widget.index,
            buildingData,
          )
          : _buildingCubit.addBuilding(context, _projectId, buildingData);
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
                style: AppTextStyle.ts16SB(),
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
                          key: ValueKey(
                            'roadWidth_${selectedValue?['zAttributesId'] ?? 'null'}',
                          ),
                          title: 'Road Width',
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
                        );
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedLandOwnershipType,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'landOwnership_${selectedValue?['zAttributesId'] ?? 'null'}',
                          ),
                          title: 'Land Ownership Type',
                          isRequired: true,
                          dataList: _ownershipTypeList,
                          initialValue: selectedValue,
                          onSelected: (selected) {
                            _selectedLandOwnershipType.value = selected;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Land ownership type is required';
                            }
                            return null;
                          },
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
                      "Property Information",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _totalPlotAreaC,
                      title: 'Total Plot Area (Sq Ft)',
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
                      textController: _totalUnitsAreaUtilizedC,
                      title: "Units Area Utilized (Sq Ft)",
                      hint: 'Enter Units Area Utilized',
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                    ),
                    CustomTextField(
                      textController: _totalNumberOfUnitsC,
                      title: 'Total Units',
                      hint: 'Enter Total Number of Units',
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
                    // GARDEN SECTION
                    StatefulBuilder(
                      builder: (context, innerState) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: _isGarden,
                                  onChanged: (value) {
                                    innerState(() {
                                      _isGarden = value;
                                    });
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Garden', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),
                            if (_isGarden)
                              CustomTextField(
                                textController: _totalGardenAreaC,
                                title: 'Garden Area (Sq Ft)',
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      7,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Garden Area is required';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    // RELIGIOUS STRUCTURE SECTION
                    StatefulBuilder(
                      builder: (context, innerState) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: _isReligiousStructure,
                                  onChanged: (value) {
                                    innerState(() {
                                      _isReligiousStructure = value;
                                    });
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
                            if (_isReligiousStructure)
                              CustomTextField(
                                textController: _totalReligiousStructureAreaC,
                                title: 'Religious Structure Area (Sq Ft)',
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      7,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Religious Structure Area is required';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    // LITIGATION SECTION
                    StatefulBuilder(
                      builder: (context, innerState) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CustomCheckBox(
                                  isSelected: _isLitigation,
                                  onChanged: (value) {
                                    innerState(() {
                                      _isLitigation = value;
                                    });
                                  },
                                ),
                                horizontalSpacing(width: 10.0),
                                Text('Litigation', style: AppTextStyle.ts14R()),
                              ],
                            ),
                            verticalSpacing(),
                            if (_isLitigation)
                              CustomTextField(
                                textController: _litigationRemarksC,
                                title: 'Litigation Remarks',
                                inputFormatterList: InputValidator.textDigit(
                                  500,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Litigation remark is required';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Litigation remarks must be at least 10 characters';
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
                      incomingStateId: _stateMasterId,
                      incomingDistrictId: _districtMasterId,
                      incomingCityId: _cityMasterId,
                      incomingVillageId: _villageMasterId,
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
            text: _isEditMode ? "Update Building" : "Add Building",
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
