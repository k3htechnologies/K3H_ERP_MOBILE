import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/add_unit_specification_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddInventorySpecificationScreen extends StatefulWidget {
  final FloorModel? floorModel;
  final FlatModel? flatModel;
  const AddInventorySpecificationScreen({
    super.key,
    this.floorModel,
    this.flatModel,
  });

  @override
  State<AddInventorySpecificationScreen> createState() =>
      _AddInventorySpecificationScreenState();
}

class _AddInventorySpecificationScreenState
    extends State<AddInventorySpecificationScreen> {
  // CUBIT
  late InventoryCubit _inventoryCubit;

  // AUTHORIZATION
  late AuthorizationModel _routAuthorizationModel;

  // CURRENT PROJECT
  late ProjectModel _project;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ADD UPDATE FLAT VARIABLES
  late TextEditingController _flatC, _flatSqftC;

  // LIST VARIABLES
  late ValueNotifier<Map<String, dynamic>> selectedFlatType;
  late ValueNotifier<Map<String, dynamic>> selectedFlatStatus;
  Map<String, dynamic>? selectedFlatConfiguration, selectedFlatFacing;

  // STATIC LISTS
  List<Map<String, dynamic>> flatTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Type'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
    {'zAttributesId': 3, 'DisplayName': 'Void'},
    {'zAttributesId': 4, 'DisplayName': 'Gym'},
  ];

  List<Map<String, dynamic>> residentialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': '1 BHK'},
    {'zAttributesId': 2, 'DisplayName': '2 BHK'},
    {'zAttributesId': 3, 'DisplayName': '3 BHK'},
    {'zAttributesId': 4, 'DisplayName': '4 BHK'},
    {'zAttributesId': 5, 'DisplayName': '5 BHK'},
    {'zAttributesId': 6, 'DisplayName': '1 Rk'},
    {'zAttributesId': 7, 'DisplayName': 'Duplex'},
  ];

  List<Map<String, dynamic>> commercialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': 'Shop'},
    {'zAttributesId': 2, 'DisplayName': 'Office'},
  ];

  List<Map<String, dynamic>> flatStatusList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Status'},
    {'zAttributesId': 1, 'DisplayName': 'Available'},
    {'zAttributesId': 2, 'DisplayName': 'Blocked'},
    {'zAttributesId': 3, 'DisplayName': 'Hold'},
  ];

  List<Map<String, dynamic>> flatFacingList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Facing'},
    {'zAttributesId': 1, 'DisplayName': 'North'},
    {'zAttributesId': 2, 'DisplayName': 'South'},
    {'zAttributesId': 3, 'DisplayName': 'East'},
    {'zAttributesId': 4, 'DisplayName': 'West'},
    {'zAttributesId': 5, 'DisplayName': 'Road'},
    {'zAttributesId': 6, 'DisplayName': 'Garden'},
    {'zAttributesId': 7, 'DisplayName': 'Front'},
    {'zAttributesId': 8, 'DisplayName': 'Park'},
  ];

  // FLAT SPECIFICATION VARIABLE
  ValueNotifier<List<FlatSpecificationModel>> flatSpecificationList =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _routAuthorizationModel = AuthorizationModel();
    _inventoryCubit = context.read<InventoryCubit>();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.flatModel != null) {
        _prefillFlat(widget.flatModel!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flatC.dispose();
    _flatSqftC.dispose();
    selectedFlatType.dispose();
    selectedFlatStatus.dispose();
    flatSpecificationList.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _flatC = TextEditingController();
    _flatSqftC = TextEditingController();
    selectedFlatType = ValueNotifier(flatTypeList.first);
    selectedFlatStatus = ValueNotifier(flatStatusList.first);
    selectedFlatFacing = flatFacingList.first;
  }

  // PREFILL FLAT DATA
  void _prefillFlat(FlatModel flat) {
    setState(() {
      // Prefill unit number
      _flatC.text = flat.flat.split('-').last.trimLeft();

      // Prefill area
      if (flat.reraCarpetAreaSqFt > 0) {
        _flatSqftC.text = flat.reraCarpetAreaSqFt.toStringAsFixed(2);
      }

      // Prefill flat type
      selectedFlatType.value = flatTypeList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatType.toLowerCase(),
        orElse: () => flatTypeList.first,
      );

      // Prefill flat status
      selectedFlatStatus.value = flatStatusList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatStatus.toLowerCase(),
        orElse: () => flatStatusList.first,
      );

      // Prefill flat facing
      selectedFlatFacing = flatFacingList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatFacing.toLowerCase(),
        orElse: () => flatFacingList.first,
      );

      // Prefill flat configuration based on type
      switch (flat.flatType) {
        case 'Residential':
          selectedFlatConfiguration = residentialFlatList.firstWhere(
            (e) => e['DisplayName'] == flat.flatConfiguration,
            orElse: () => residentialFlatList.first,
          );
          break;
        case 'Commercial':
          selectedFlatConfiguration = commercialFlatList.firstWhere(
            (e) => e['DisplayName'] == flat.flatConfiguration,
            orElse: () => commercialFlatList.first,
          );
          break;
        default:
          selectedFlatConfiguration = null;
      }

      // Prefill specifications list
      flatSpecificationList.value = List<FlatSpecificationModel>.from(
        flat.specificationList,
      );
    });

    // Calculate total area
    _calculateTotalArea();
  }

  // CALCULATE TOTAL AREA FROM SPECIFICATIONS
  void _calculateTotalArea() {
    double totalArea = 0;
    for (var spec in flatSpecificationList.value) {
      totalArea += spec.flatLayoutAreaSqFt;
    }
    _flatSqftC.text = totalArea.toStringAsFixed(2);
  }

  // NAVIGATE TO ADD/EDIT UNIT SPECIFICATION
  Future<void> _navigateToAddUnitSpecification({
    FlatSpecificationModel? unitSpec,
    int? index,
  }) async {
    // Determine flat IDs based on whether we're adding or editing
    int? flatId;
    int? buildingId;
    int? wingId;
    int? floorId;

    if (widget.flatModel != null) {
      // Editing existing flat
      flatId = widget.flatModel!.inventoryFlatId;
      buildingId = widget.flatModel!.inventoryBuildingId;
      wingId = widget.flatModel!.inventoryFlatFloorBasementPodiumWingId;
      floorId = widget.flatModel!.inventoryFloorId;
    } else if (widget.floorModel != null) {
      // Adding new flat
      buildingId = widget.floorModel!.inventoryBuildingId;
      wingId = widget.floorModel!.inventoryFlatFloorBasementPodiumWingId;
      floorId = widget.floorModel!.inventoryFloorId;
      // flatId will be 0 for new flats
    }

    final result = await Navigator.push<FlatSpecificationModel>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddUnitSpecificationScreen(
              unitSpecificationModel: unitSpec,
              inventoryFlatId: flatId,
              inventoryBuildingId: buildingId,
              inventoryFlatFloorBasementPodiumWingId: wingId,
              inventoryFloorId: floorId,
              onSave: (savedSpec) {
                Navigator.pop(context, savedSpec);
              },
            ),
      ),
    );

    if (result != null) {
      Future.microtask(() {
        if (unitSpec == null) {
          // Add new specification
          flatSpecificationList.value = [
            ...flatSpecificationList.value,
            result,
          ];
        } else {
          // Update existing specification
          final newList = List<FlatSpecificationModel>.from(
            flatSpecificationList.value,
          );
          newList[index!] = result;
          flatSpecificationList.value = newList;
        }
        _calculateTotalArea();
      });
    }
  }

  // DELETE UNIT SPECIFICATION
  void _deleteUnitSpecification(int index) {
    Future.microtask(() {
      final newList = List<FlatSpecificationModel>.from(
        flatSpecificationList.value,
      );
      newList.removeAt(index);
      flatSpecificationList.value = newList;
      _calculateTotalArea();
    });
  }

  // HANDLE SUBMIT
  void _handleSubmit() {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please fill all required fields correctly",
      );
      return;
    }

    // Validate flat facing
    if (selectedFlatFacing == null || selectedFlatFacing!['zAttributesId'] == -1) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please select Flat Facing",
      );
      return;
    }

    // Validate flat configuration if type is Residential or Commercial
    if ((selectedFlatType.value['zAttributesId'] == 1 ||
            selectedFlatType.value['zAttributesId'] == 2) &&
        (selectedFlatConfiguration == null ||
            selectedFlatConfiguration!['zAttributesId'] == -1)) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please select Unit Configuration",
      );
      return;
    }

    // Validate specifications list is not empty
    if (flatSpecificationList.value.isEmpty) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please add at least one Unit Specification",
      );
      return;
    }

    if (widget.floorModel != null) {
      // Add new flat
      _inventoryCubit.addInventoryFlat(
        context,
        projectId: _project.projectId,
        inventoryBuildingId: widget.floorModel!.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            widget.floorModel!.inventoryFlatFloorBasementPodiumWingId,
        inventoryFloorId: widget.floorModel!.inventoryFloorId,
        flat: _flatC.text.trim(),
        flatType: selectedFlatType.value['DisplayName'],
        flatArea: double.parse(_flatSqftC.text),
        flatConfiguration: selectedFlatConfiguration?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value['DisplayName'],
        flatFacing: selectedFlatFacing!['DisplayName'],
        flatSpecificationList: flatSpecificationList.value,
      );
    } else if (widget.flatModel != null) {
      // Update existing flat
      _inventoryCubit.updateInventoryFlat(
        context,
        inventoryFlatId: widget.flatModel!.inventoryFlatId,
        projectId: _project.projectId,
        inventoryBuildingId: widget.flatModel!.inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            widget.flatModel!.inventoryFlatFloorBasementPodiumWingId,
        inventoryFloorId: widget.flatModel!.inventoryFloorId,
        flat: _flatC.text.trim(),
        flatType: selectedFlatType.value['DisplayName'],
        flatArea: double.parse(_flatSqftC.text),
        flatConfiguration: selectedFlatConfiguration?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value['DisplayName'],
        flatFacing: selectedFlatFacing!['DisplayName'],
        flatSpecificationList: flatSpecificationList.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory",
        authorization: _routAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                children: [
                  CustomTextField(
                    title: 'Unit',
                    hint: 'Enter Unit',
                    isRequired: true,
                    textController: _flatC,
                    maxLines: 1,
                    inputFormatterList: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (string) {
                      if (string == null || string.trim().isEmpty) {
                        return 'Unit is required';
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedFlatType,
                    builder: (context, typeValue, child) {
                      return CustomDropDownWidget(
                        key: ValueKey('type_${typeValue['zAttributesId']}'),
                        title: 'Unit Type',
                        isRequired: true,
                        dataList: flatTypeList,
                        initialValue: typeValue,
                        onSelected: (value) {
                          setState(() {
                            selectedFlatConfiguration = null;
                          });
                          selectedFlatType.value = value;
                        },
                        validator: (value) {
                          if (value == null || value["zAttributesId"] == -1) {
                            return 'Unit Type is required';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedFlatType,
                    builder: (context, value, child) {
                      if (value['zAttributesId'] == 1) {
                        return CustomDropDownWidget(
                          key: ValueKey('config_residential_${selectedFlatConfiguration?['zAttributesId']}'),
                          title: 'Unit Configuration',
                          isRequired: true,
                          dataList: residentialFlatList,
                          initialValue: selectedFlatConfiguration,
                          onSelected: (value) {
                            setState(() {
                              selectedFlatConfiguration = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Unit Configuration is required';
                            }
                            return null;
                          },
                        );
                      }
                      if (value['zAttributesId'] == 2) {
                        return CustomDropDownWidget(
                          key: ValueKey('config_commercial_${selectedFlatConfiguration?['zAttributesId']}'),
                          title: 'Unit Configuration',
                          isRequired: true,
                          dataList: commercialFlatList,
                          initialValue: selectedFlatConfiguration,
                          onSelected: (value) {
                            setState(() {
                              selectedFlatConfiguration = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Unit Configuration is required';
                            }
                            return null;
                          },
                        );
                      }
                      return SizedBox();
                    },
                  ),
                  CustomTextField(
                    textController: _flatSqftC,
                    hint: "Enter Unit Area",
                    title: 'Unit Area (sq ft)',
                    readOnly: true,
                    inputFormatterList:
                        inputFormatterListForDecimalValuesFixedToTwo(5),
                    validator: (string) {
                      if (string == null || string.trim().isEmpty) {
                        return 'Area is required';
                      }
                      // Check if the value is 0 or invalid

                      if (double.parse(string.trim()) <= 0) {
                        return 'Area must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  CustomDropDownWidget(
                    key: ValueKey('facing_${selectedFlatFacing?['zAttributesId']}'),
                    title: 'Facing',
                    isRequired: true,
                    dataList: flatFacingList,
                    initialValue: selectedFlatFacing,
                    onSelected: (value) {
                      setState(() {
                        selectedFlatFacing = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value["zAttributesId"] == -1) {
                        return 'Facing is required';
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedFlatStatus,
                    builder: (context, statusValue, child) {
                      return CustomDropDownWidget(
                        key: ValueKey('status_${statusValue['zAttributesId']}'),
                        title: 'Status',
                        isRequired: true,
                        dataList: flatStatusList,
                        initialValue: statusValue,
                        onSelected: (value) {
                          selectedFlatStatus.value = value;
                        },
                        validator: (value) {
                          if (value == null || value["zAttributesId"] == -1) {
                            return 'Status is required';
                          }
                          if (selectedFlatType.value["DisplayName"].toLowerCase() ==
                                  "void" &&
                              value["DisplayName"].toLowerCase() ==
                                  "available") {
                            return "Invalid Status for Void Flat";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // UNIT LAYOUT FORM SECTION
            Container(
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Unit Layout Form', style: AppTextStyle.ts16SB()),
                      CustomButton(
                        text: 'Add Unit Specification',
                        backgroundColor: AppColor.primary,
                        onPressed: () {
                          _navigateToAddUnitSpecification();
                        },
                      ),
                    ],
                  ),
                  verticalSpacing(height: 15),
                  ValueListenableBuilder<List<FlatSpecificationModel>>(
                    valueListenable: flatSpecificationList,
                    builder: (context, value, child) {
                      if (value.isEmpty) {
                        return SizedBox(height: 200, child: noDataWidget());
                      }

                      return Column(
                        children:
                            value.asMap().entries.map((entry) {
                              final index = entry.key;
                              final spec = entry.value;
                              return Container(
                                key: ValueKey(
                                  'spec_${spec.inventoryFlatSpecificationId}_$index',
                                ),
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.grey30,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                spec.flatLayout,
                                                style: AppTextStyle.ts14M(),
                                              ),
                                              verticalSpacing(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  _buildColumnTitleValue(
                                                    title: "Area (Sq. ft)",
                                                    value:
                                                        spec.flatLayoutAreaSqFt
                                                            .toString(),
                                                  ),
                                                  _buildColumnTitleValue(
                                                    title: "Length (Sq. ft)",
                                                    value:
                                                        spec.flatLayoutLengthSqFt
                                                            .toString(),
                                                  ),
                                                  _buildColumnTitleValue(
                                                    title: "Width (Sq. ft)",
                                                    value:
                                                        spec.flatLayoutWidthSqFt
                                                            .toString(),
                                                  ),
                                                ],
                                              ),
                                              if (spec.note.isNotEmpty)
                                                verticalSpacing(height: 8),
                                              if (spec.note.isNotEmpty)
                                                Text(
                                                  "Note: ${spec.note}",
                                                  style: AppTextStyle.ts12R(
                                                    color: AppColor.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomIconButton(
                                              onPressed: () {
                                                _navigateToAddUnitSpecification(
                                                  unitSpec: spec,
                                                  index: index,
                                                );
                                              },
                                              icon: SvgPicture.asset(
                                                AppAssets.editIcon,
                                                height: 18,
                                                width: 18,
                                              ),
                                            ),
                                            horizontalSpacing(),
                                            CustomIconButton(
                                              onPressed: () {
                                                _deleteUnitSpecification(index);
                                              },
                                              icon: SvgPicture.asset(
                                                AppAssets.deleteIcon,
                                                height: 18,
                                                width: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
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
            text: widget.flatModel != null ? "Update Specification" : "Save Specification",
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }

  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts12M()),
        ],
      ),
    );
  }
}
