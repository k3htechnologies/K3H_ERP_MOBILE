// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EditParkingScreen extends StatefulWidget {
  final ParkingModel parking;
  final int index;
  const EditParkingScreen({
    super.key,
    required this.parking,
    required this.index,
  });

  @override
  State<EditParkingScreen> createState() => _EditParkingScreenState();
}

class _EditParkingScreenState extends State<EditParkingScreen> {
  // CUBIT
  late ParkingCubit _parkingCubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // PROJECT
  late ProjectModel project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _parkingNumberC, _parkingDimensionsC;

  // PARKING CATEGORY LISTS
  final List<Map<String, dynamic>> _parkingCategoryList = [
    {'zAttributesId': -1, 'DisplayName': 'Select'},
    {'zAttributesId': 1, 'DisplayName': 'Surface Parking'},
    {'zAttributesId': 2, 'DisplayName': 'Stack Parking'},
    {'zAttributesId': 3, 'DisplayName': 'Puzzle Parking'},
    {'zAttributesId': 4, 'DisplayName': 'Tower Parking'},
    {'zAttributesId': 5, 'DisplayName': 'Pit Puzzle Parking'},
    {'zAttributesId': 6, 'DisplayName': 'Cantilever Parking'},
    {'zAttributesId': 7, 'DisplayName': 'Tandem Parking'},
    {'zAttributesId': 8, 'DisplayName': 'Podium Parking'},
    {'zAttributesId': 9, 'DisplayName': 'Pit + Stack'},
  ];

  // PARKING TYPE LIST
  late ValueNotifier<List<Map<String, dynamic>>> _parkingTypeList;

  final List<Map<String, dynamic>> _parkingSubTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select'},
    {'zAttributesId': 1, 'DisplayName': 'Big'},
    {'zAttributesId': 2, 'DisplayName': 'Small'},
  ];

  final List<Map<String, dynamic>> _parkingStatusList = [
    {'zAttributesId': -1, 'DisplayName': 'Select'},
    {'zAttributesId': 1, 'DisplayName': 'Available'},
    {'zAttributesId': 2, 'DisplayName': 'Hold'},
    {'zAttributesId': 3, 'DisplayName': 'Block'},
    {'zAttributesId': 4, 'DisplayName': 'Member'},
  ];

  // DROPDOWN VARIABLES
  late ValueNotifier<Map<String, dynamic>?> selectedCategory;
  late ValueNotifier<Map<String, dynamic>?> selectedType;
  late ValueNotifier<Map<String, dynamic>?> selectedSubType;
  late ValueNotifier<Map<String, dynamic>?> selectedStatus;

  // SELECTED FLAT FILTER
  List<String> selectedFlatFilter = [];

  // SELECTION VARIABLES
  ValueNotifier<bool> isEvChargingAvailable = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _parkingCubit = context.read<ParkingCubit>();
    project = getProject();
    _parkingTypeList = ValueNotifier(_parkingSubTypeList);
    _initializeDropdownVariables();
    _prefillParking(widget.parking);
  }

  // INITIALIZE DROPDOWN VARIABLES
  void _initializeDropdownVariables() {
    selectedCategory = ValueNotifier<Map<String, dynamic>?>(null);
    selectedType = ValueNotifier<Map<String, dynamic>?>(null);
    selectedSubType = ValueNotifier<Map<String, dynamic>?>(null);
    selectedStatus = ValueNotifier<Map<String, dynamic>?>(null);
  }

  @override
  void dispose() {
    super.dispose();
    _disposeTextEditingControllers();
    selectedCategory.dispose();
    selectedType.dispose();
    selectedSubType.dispose();
    selectedStatus.dispose();
    _parkingTypeList.dispose();
    isEvChargingAvailable.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _parkingNumberC = TextEditingController();
    _parkingDimensionsC = TextEditingController();
  }

  // DISPOSE TEXT EDITING CONTROLLERS
  void _disposeTextEditingControllers() {
    _parkingNumberC.dispose();
    _parkingDimensionsC.dispose();
  }

  // PREFILL DIALOG TO UPDATE PARKING
  void _prefillParking(ParkingModel parking) {
    _parkingNumberC.text = parking.parkingNumber;
    _parkingDimensionsC.text = parking.parkingDimensions;
    isEvChargingAvailable.value = parking.isEVChargingAvailable;

    selectedCategory.value = _parkingCategoryList.firstWhere(
      (element) => element['DisplayName'] == parking.parkingCategory,
      orElse: () => _parkingCategoryList.first,
    );

    _updateParkingTypeListForCategory(selectedCategory.value!);

    selectedType.value = _parkingTypeList.value.firstWhere(
      (element) => element['DisplayName'] == parking.parkingType,
      orElse: () => _parkingTypeList.value.first,
    );

    selectedSubType.value = _parkingSubTypeList.firstWhere(
      (element) => element['DisplayName'] == parking.parkingSubType,
      orElse: () => _parkingSubTypeList.first,
    );

    selectedStatus.value = _parkingStatusList.firstWhere(
      (element) => element['DisplayName'] == parking.parkingStatus,
      orElse: () => _parkingStatusList.first,
    );
  }

  // UPDATE PARKING TYPE LIST BASED ON SELECTED CATEGORY
  void _updateParkingTypeListForCategory(Map<String, dynamic> category) {
    List<Map<String, dynamic>> newTypeList = [
      {'zAttributesId': -1, 'DisplayName': 'Select'},
    ];

    switch (category['zAttributesId']) {
      case 1: // Surface Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'SU 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 2: // Stack Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'PIT 1'},
          {'zAttributesId': 2, 'DisplayName': 'PIT 2'},
          {'zAttributesId': 3, 'DisplayName': 'PIT 3'},
          {'zAttributesId': 4, 'DisplayName': 'PIT 4'},
          {'zAttributesId': 5, 'DisplayName': 'PIT 5'},
          {'zAttributesId': 6, 'DisplayName': 'ST 1'},
          {'zAttributesId': 7, 'DisplayName': 'ST 2'},
          {'zAttributesId': 8, 'DisplayName': 'ST 3'},
          {'zAttributesId': 9, 'DisplayName': 'ST 4'},
          {'zAttributesId': 10, 'DisplayName': 'ST 5'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 3: // Puzzle Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'PU 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 4: // Tower Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'TO 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 5: // Pit Puzzle Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'PIT 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 6: // Cantilever Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'CAN 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 7: // Tandem Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'TAN 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 8: // Podium Parking
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'PO 1'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
      case 9: // Pit + Stack
        newTypeList.addAll([
          {'zAttributesId': 1, 'DisplayName': 'Pit + Stack 1'},
          {'zAttributesId': 2, 'DisplayName': 'Pit + Stack 2'},
          {'zAttributesId': 3, 'DisplayName': 'Pit + Stack 3'},
          {'zAttributesId': 4, 'DisplayName': 'Pit + Stack 4'},
          {'zAttributesId': 5, 'DisplayName': 'Pit + Stack 5'},
          {'zAttributesId': 11, 'DisplayName': 'Ground'},
        ]);
        break;
    }

    _parkingTypeList.value = newTypeList;

    selectedType.value = newTypeList.firstWhere(
      (e) => e['DisplayName'] == widget.parking.parkingType,
      orElse: () => newTypeList.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Update Parking",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: 'Parking Number',
                  hint: 'Enter Parking Number',
                  isRequired: true,
                  textController: _parkingNumberC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'Parking Number is required';
                    }
                    return null;
                  },
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedCategory,
                  builder: (context, categoryValue, child) {
                    return CustomDropDownWidget(
                      key: ValueKey('category_${categoryValue?['zAttributesId']}'),
                      title: 'Parking Category',
                      isRequired: true,
                      initialValue: categoryValue,
                      dataList: _parkingCategoryList,
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return 'Parking Category is required';
                        }
                        return null;
                      },
                      onSelected: (value) {
                        selectedCategory.value = value;
                        _updateParkingTypeListForCategory(selectedCategory.value!);
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _parkingTypeList,
                  builder: (context, list, child) {
                    return ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedType,
                      builder: (context, typeValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey('type_${typeValue?['zAttributesId']}_${list.length}'),
                          title: 'Parking Type',
                          isRequired: true,
                          initialValue: typeValue,
                          dataList: list,
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Parking Type is required';
                            }
                            return null;
                          },
                          onSelected: (value) {
                            selectedType.value = value;
                          },
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedSubType,
                  builder: (context, subTypeValue, child) {
                    return CustomDropDownWidget(
                      key: ValueKey('subtype_${subTypeValue?['zAttributesId']}'),
                      title: 'Parking Sub Type',
                      isRequired: true,
                      initialValue: subTypeValue,
                      dataList: _parkingSubTypeList,
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return 'Parking Sub Type is required';
                        }
                        return null;
                      },
                      onSelected: (value) {
                        selectedSubType.value = value;
                      },
                    );
                  },
                ),
                Text('Is Ev Charging Available?', style: AppTextStyle.ts16R()),
                verticalSpacing(height: 6),
                ValueListenableBuilder<bool>(
                  valueListenable: isEvChargingAvailable,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: isEvChargingAvailable.value,
                              activeColor: AppColor.primary,
                              onChanged: (value) {
                                isEvChargingAvailable.value = value!;
                              },
                            ),
                            Text('Yes', style: AppTextStyle.ts16R()),
                          ],
                        ),
                        SizedBox(width: 20),
                        Row(
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: isEvChargingAvailable.value,
                              activeColor: AppColor.info,
                              onChanged: (value) {
                                isEvChargingAvailable.value = value!;
                              },
                            ),
                            Text('No', style: AppTextStyle.ts16R()),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                CustomTextField(
                  title: 'Parking Dimensions',
                  hint: 'Enter Parking Dimensions',
                  isRequired: true,
                  textController: _parkingDimensionsC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'Parking Dimensions are required';
                    }
                    return null;
                  },
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedStatus,
                  builder: (context, statusValue, child) {
                    return CustomDropDownWidget(
                      key: ValueKey('status_${statusValue?['zAttributesId']}'),
                      title: 'Parking Status',
                      isRequired: true,
                      initialValue: statusValue,
                      dataList: _parkingStatusList,
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return 'Parking Status is required';
                        }
                        return null;
                      },
                      onSelected: (value) {
                        selectedStatus.value = value;
                      },
                    );
                  },
                ),
                verticalSpacing(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            text: "Update Parking",
            onPressed: _handleUpdateParking,
          ),
        ),
      ),
    );
  }

  // HANDLE UPDATE PARKING
  void _handleUpdateParking() {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate dropdowns with better error messages
    if (selectedCategory.value == null || selectedCategory.value!['zAttributesId'] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select Parking Category'),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    if (selectedType.value == null || selectedType.value!['zAttributesId'] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select Parking Type'),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    if (selectedSubType.value == null || selectedSubType.value!['zAttributesId'] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select Parking Sub Type'),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    if (selectedStatus.value == null || selectedStatus.value!['zAttributesId'] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select Parking Status'),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    _parkingCubit.updateParking(
      context: context,
      parkingId: widget.parking.parkingId,
      uniqueKey: widget.parking.uniquekey,
      projectId: project.projectId,
      parkingNumber: _parkingNumberC.text.trim(),
      parkingCategory: selectedCategory.value!['DisplayName'] as String,
      parkingType: selectedType.value!['DisplayName'] as String,
      parkingSubType: selectedSubType.value!['DisplayName'] as String,
      parkingDimensions: _parkingDimensionsC.text.trim(),
      isEVChargingAvailable: isEvChargingAvailable.value,
      parkingStatus: selectedStatus.value!['DisplayName'] as String,
      inventoryBuildingId: widget.parking.inventoryBuildingId,
      inventoryFlatFloorBasementPodiumWingId:
          widget.parking.inventoryFlatFloorBasementPodiumWingId,
      inventoryFloorId: widget.parking.inventoryFloorId,
    );
  }
}
