import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'dart:convert';
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
  late ValueNotifier<Map<String, dynamic>?> selectedFlatConfiguration;
  late ValueNotifier<Map<String, dynamic>?> selectedFlatFacing;

  // STATIC LISTS
  List<Map<String, dynamic>> flatTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Type'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
    {'zAttributesId': 3, 'DisplayName': 'Void'},
    {'zAttributesId': 4, 'DisplayName': 'Gym'},
  ];

  // STATIC LISTS FOR FLAT CONFIGURATION
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

  // STATIC LISTS FOR FLAT CONFIGURATION
  List<Map<String, dynamic>> commercialFlatList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Configuration'},
    {'zAttributesId': 1, 'DisplayName': 'Shop'},
    {'zAttributesId': 2, 'DisplayName': 'Office'},
  ];

  // STATIC LISTS FOR FLAT STATUS
  List<Map<String, dynamic>> flatStatusList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Flat Status'},
    {'zAttributesId': 1, 'DisplayName': 'Available'},
    {'zAttributesId': 2, 'DisplayName': 'Blocked'},
    {'zAttributesId': 3, 'DisplayName': 'Hold'},
    {'zAttributesId': 4, 'DisplayName': 'Member'},
  ];

  // STATIC LISTS FOR FLAT FACING
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
    selectedFlatConfiguration.dispose();
    selectedFlatFacing.dispose();
    flatSpecificationList.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _flatC = TextEditingController();
    _flatSqftC = TextEditingController();
    selectedFlatType = ValueNotifier(flatTypeList.first);
    selectedFlatStatus = ValueNotifier(flatStatusList.first);
    selectedFlatConfiguration = ValueNotifier<Map<String, dynamic>?>(null);
    selectedFlatFacing = ValueNotifier<Map<String, dynamic>?>(
      flatFacingList.first,
    );
  }

  // PREFILL FLAT DATA
  void _prefillFlat(FlatModel flat) {
    _flatC.text = flat.flat.split('-').last.trimLeft();
    if (flat.reraCarpetAreaSqFt > 0) {
      _flatSqftC.text = flat.reraCarpetAreaSqFt.toStringAsFixed(2);
    }
    selectedFlatType.value = flatTypeList.firstWhere(
      (e) => e['DisplayName'].toLowerCase() == flat.flatType.toLowerCase(),
      orElse: () => flatTypeList.first,
    );
    selectedFlatStatus.value = flatStatusList.firstWhere(
      (e) => e['DisplayName'].toLowerCase() == flat.flatStatus.toLowerCase(),
      orElse: () => flatStatusList.first,
    );
    selectedFlatFacing.value = flatFacingList.firstWhere(
      (e) => e['DisplayName'].toLowerCase() == flat.flatFacing.toLowerCase(),
      orElse: () => flatFacingList.first,
    );
    switch (flat.flatType) {
      case 'Residential':
        selectedFlatConfiguration.value = residentialFlatList.firstWhere(
          (e) => e['DisplayName'] == flat.flatConfiguration,
          orElse: () => residentialFlatList.first,
        );
        break;
      case 'Commercial':
        selectedFlatConfiguration.value = commercialFlatList.firstWhere(
          (e) => e['DisplayName'] == flat.flatConfiguration,
          orElse: () => commercialFlatList.first,
        );
        break;
      default:
        selectedFlatConfiguration.value = null;
    }
    flatSpecificationList.value = List<FlatSpecificationModel>.from(
      flat.specificationList,
    );
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
    int? flatId;
    int? buildingId;
    int? wingId;
    int? floorId;

    if (widget.flatModel != null) {
      flatId = widget.flatModel!.inventoryFlatId;
      buildingId = widget.flatModel!.inventoryBuildingId;
      wingId = widget.flatModel!.inventoryFlatFloorBasementPodiumWingId;
      floorId = widget.flatModel!.inventoryFloorId;
    } else if (widget.floorModel != null) {
      buildingId = widget.floorModel!.inventoryBuildingId;
      wingId = widget.floorModel!.inventoryFlatFloorBasementPodiumWingId;
      floorId = widget.floorModel!.inventoryFloorId;
    }

    final Map<String, String> queryParams = {};

    if (unitSpec != null) {
      queryParams['unitSpecificationModel'] = Uri.encodeQueryComponent(
        EncryptionManager.encryptData(jsonEncode(unitSpec.toJson())),
      );
    }

    if (flatId != null) {
      queryParams['inventoryFlatId'] = flatId.toString();
    }
    if (buildingId != null) {
      queryParams['inventoryBuildingId'] = buildingId.toString();
    }
    if (wingId != null) {
      queryParams['inventoryFlatFloorBasementPodiumWingId'] = wingId.toString();
    }
    if (floorId != null) {
      queryParams['inventoryFloorId'] = floorId.toString();
    }

    final result = await goRouter.pushNamed<FlatSpecificationModel>(
      AppRoutes.addUnitSpecification,
      queryParameters: queryParams,
    );

    if (result != null) {
      Future.microtask(() {
        if (unitSpec == null) {
          flatSpecificationList.value = [
            ...flatSpecificationList.value,
            result,
          ];
        } else {
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
    if (!_formKey.currentState!.validate()) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please fill all required fields correctly",
      );
      return;
    }
    if (selectedFlatFacing.value == null ||
        selectedFlatFacing.value!['zAttributesId'] == -1) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please select Flat Facing",
      );
      return;
    }
    if ((selectedFlatType.value['zAttributesId'] == 1 ||
            selectedFlatType.value['zAttributesId'] == 2) &&
        (selectedFlatConfiguration.value == null ||
            selectedFlatConfiguration.value!['zAttributesId'] == -1)) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please select Unit Configuration",
      );
      return;
    }
    if (flatSpecificationList.value.isEmpty) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please add at least one Unit Specification",
      );
      return;
    }
    if (widget.flatModel != null && widget.flatModel!.inventoryFlatId > 0) {
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
        flatConfiguration:
            selectedFlatConfiguration.value?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value['DisplayName'],
        flatFacing: selectedFlatFacing.value!['DisplayName'],
        flatSpecificationList: flatSpecificationList.value,
      );
    } else if (widget.floorModel != null) {
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
        flatConfiguration:
            selectedFlatConfiguration.value?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value['DisplayName'],
        flatFacing: selectedFlatFacing.value!['DisplayName'],
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
                            selectedFlatConfiguration.value = null;
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
                        return ValueListenableBuilder<Map<String, dynamic>?>(
                          valueListenable: selectedFlatConfiguration,
                          builder: (context, configValue, child) {
                            if (value['zAttributesId'] == 1) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'config_residential_${configValue?['zAttributesId']}',
                                ),
                                title: 'Unit Configuration',
                                isRequired: true,
                                dataList: residentialFlatList,
                                initialValue: configValue,
                                onSelected: (value) {
                                  selectedFlatConfiguration.value = value;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value["zAttributesId"] == -1) {
                                    return 'Unit Configuration is required';
                                  }
                                  return null;
                                },
                              );
                            }
                            if (value['zAttributesId'] == 2) {
                              return CustomDropDownWidget(
                                key: ValueKey(
                                  'config_commercial_${configValue?['zAttributesId']}',
                                ),
                                title: 'Unit Configuration',
                                isRequired: true,
                                dataList: commercialFlatList,
                                initialValue: configValue,
                                onSelected: (value) {
                                  selectedFlatConfiguration.value = value;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value["zAttributesId"] == -1) {
                                    return 'Unit Configuration is required';
                                  }
                                  return null;
                                },
                              );
                            }
                            return SizedBox();
                          },
                        );
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
                        // If empty, attempt to recalculate from specs before failing
                        final current = string?.trim() ?? '';
                        if (current.isEmpty) {
                          _calculateTotalArea();
                        }

                        final recalculated = _flatSqftC.text.trim();
                        if (recalculated.isEmpty) {
                          return 'Area is required';
                        }

                        final parsed = double.tryParse(recalculated);

                        // If parse fails, try to recompute from specs; otherwise accept
                        if (parsed == null) {
                          _calculateTotalArea();
                          return null;
                        }

                        // If parsed <= 0, try to recompute from specs; if still <=0, fail
                        if (parsed <= 0) {
                          _calculateTotalArea();
                          final reParsed =
                              double.tryParse(_flatSqftC.text.trim()) ?? 0;
                          if (reParsed <= 0) {
                            return 'Area must be greater than 0';
                          }
                        }

                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedFlatFacing,
                      builder: (context, facingValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'facing_${facingValue?['zAttributesId']}',
                          ),
                          title: 'Facing',
                          isRequired: true,
                          dataList: flatFacingList,
                          initialValue: facingValue,
                          onSelected: (value) {
                            selectedFlatFacing.value = value;
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Facing is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedFlatStatus,
                      builder: (context, statusValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'status_${statusValue['zAttributesId']}',
                          ),
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
                            if (selectedFlatType.value["DisplayName"]
                                        .toLowerCase() ==
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  _deleteUnitSpecification(
                                                    index,
                                                  );
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
            text:
                (widget.flatModel != null &&
                        widget.flatModel!.inventoryFlatId > 0)
                    ? "Update Specification"
                    : "Save Specification",
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }

  // BUILD COLUMN TITLE VALUE
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
