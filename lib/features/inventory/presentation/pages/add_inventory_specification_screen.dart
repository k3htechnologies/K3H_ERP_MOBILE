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
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

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
  late AuthorizationModel _routeAuthorizationModel;

  // CURRENT PROJECT
  late ProjectModel _project;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ADD UPDATE FLAT VARIABLES
  late TextEditingController _flatC, _flatSqftC;

  // LIST VARIABLES
  late ValueNotifier<Map<String, dynamic>?> selectedFlatType;
  late ValueNotifier<Map<String, dynamic>?> selectedFlatStatus;
  late ValueNotifier<Map<String, dynamic>?> selectedFlatConfiguration;
  late ValueNotifier<Map<String, dynamic>?> selectedFlatFacing;

  // STATIC LISTS
  List<Map<String, dynamic>> flatTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'BMC'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
    {'zAttributesId': 3, 'DisplayName': 'eDeck'},
    {'zAttributesId': 4, 'DisplayName': 'Fitness Center'},
    {'zAttributesId': 5, 'DisplayName': 'Gym'},
    {'zAttributesId': 6, 'DisplayName': 'MHADA'},
    {'zAttributesId': 7, 'DisplayName': 'Multi Purpose Room'},
    {'zAttributesId': 8, 'DisplayName': 'Land Lord'},
    {'zAttributesId': 9, 'DisplayName': 'Lien'},
    {'zAttributesId': 10, 'DisplayName': 'Part Terrace'},
    {'zAttributesId': 11, 'DisplayName': 'Refuge'},
    {'zAttributesId': 12, 'DisplayName': 'Religious Structure'},
    {'zAttributesId': 13, 'DisplayName': 'Residential'},
    {'zAttributesId': 14, 'DisplayName': 'Society Office'},
    {'zAttributesId': 15, 'DisplayName': 'SRA'},
    {'zAttributesId': 16, 'DisplayName': 'Upashray'},
    {'zAttributesId': 17, 'DisplayName': 'Void'},
  ];

  // STATIC LISTS FOR FLAT CONFIGURATION
  List<Map<String, dynamic>> residentialFlatList = [
    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '5 BHK'},
    {'zAttributesId': 7, 'DisplayName': '6 BHK'},
    {'zAttributesId': 8, 'DisplayName': '7 BHK'},
    {'zAttributesId': 9, 'DisplayName': '8 BHK'},
    {'zAttributesId': 10, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 11, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 12, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 13, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 14, 'DisplayName': 'PENTHOUSE'},
  ];

  // STATIC LISTS FOR FLAT CONFIGURATION
  List<Map<String, dynamic>> commercialFlatList = [
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];

  // STATIC LISTS FOR FLAT STATUS
  List<Map<String, dynamic>> flatStatusList = [
    {'zAttributesId': 1, 'DisplayName': 'Available'},
    {'zAttributesId': 2, 'DisplayName': 'Blocked'},
    {'zAttributesId': 3, 'DisplayName': 'Hold'},
  ];

  // STATIC LISTS FOR FLAT FACING
  List<Map<String, dynamic>> flatFacingList = [
    {'zAttributesId': 1, 'DisplayName': 'EAST'},
    {'zAttributesId': 2, 'DisplayName': 'FRONT'},
    {'zAttributesId': 3, 'DisplayName': 'GARDEN'},
    {'zAttributesId': 4, 'DisplayName': 'NORTH'},
    {'zAttributesId': 5, 'DisplayName': 'PARK'},
    {'zAttributesId': 6, 'DisplayName': 'ROAD'},
    {'zAttributesId': 7, 'DisplayName': 'SOUTH'},
    {'zAttributesId': 8, 'DisplayName': 'WEST'},
  ];

  // FLAT SPECIFICATION VARIABLE
  ValueNotifier<List<FlatSpecificationModel>> flatSpecificationList =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _routeAuthorizationModel = AuthorizationModel();
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
    selectedFlatType = ValueNotifier(null);
    selectedFlatStatus = ValueNotifier(null);
    selectedFlatConfiguration = ValueNotifier<Map<String, dynamic>?>(null);
    selectedFlatFacing = ValueNotifier<Map<String, dynamic>?>(null);
  }

  // PREFILL FLAT DATA
  void _prefillFlat(FlatModel flat) {
    // Handle flat number - might be empty when adding
    if (flat.flat.isNotEmpty) {
      _flatC.text = flat.flat.split('-').last.trimLeft();
    }

    // Handle area - might be 0 when adding
    if (flat.reraCarpetAreaSqFt > 0) {
      _flatSqftC.text = flat.reraCarpetAreaSqFt.toStringAsFixed(2);
    }

    // Handle flat type - only set if not empty (for editing)
    if (flat.flatType.isNotEmpty) {
      selectedFlatType.value = flatTypeList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatType.toLowerCase(),
        orElse: () => flatTypeList.first,
      );
    }

    // Handle flat status - only set if not empty (for editing)
    if (flat.flatStatus.isNotEmpty) {
      selectedFlatStatus.value = flatStatusList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatStatus.toLowerCase(),
        orElse: () => flatStatusList.first,
      );
    }

    // Handle flat facing - only set if not empty (for editing)
    if (flat.flatFacing.isNotEmpty) {
      selectedFlatFacing.value = flatFacingList.firstWhere(
        (e) => e['DisplayName'].toLowerCase() == flat.flatFacing.toLowerCase(),
        orElse: () => flatFacingList.first,
      );
    }

    // Handle flat configuration - only set if not empty (for editing)
    if (flat.flatType.isNotEmpty && flat.flatConfiguration.isNotEmpty) {
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
    }

    if (flat.specificationList.isNotEmpty) {
      final Map<String, FlatSpecificationModel> specMap = {};
      int defaultSpecIndex = 0;

      for (final spec in flat.specificationList) {
        String key;
        if (spec.uniquekey.isNotEmpty) {
          key = spec.uniquekey;
        } else if (spec.inventoryFlatSpecificationId > 0) {
          key = 'id_${spec.inventoryFlatSpecificationId}_${spec.flatLayout}';
        } else {
          key = '${spec.flatLayout}_default_$defaultSpecIndex';
          defaultSpecIndex++;
        }

        if (!specMap.containsKey(key)) {
          specMap[key] = spec;
        }
      }
      flatSpecificationList.value = specMap.values.toList();
      _calculateTotalArea();
    }
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
          // ADD NEW SPECIFICATION

          final isDuplicateLayout = flatSpecificationList.value.any(
            (s) =>
                s.flatLayout.trim().toLowerCase() ==
                result.flatLayout.trim().toLowerCase(),
          );

          if (isDuplicateLayout) {
            if (mounted) {
              showErrorMessage(context, "Error", "Layout already exists");
            }
            return;
          }

          flatSpecificationList.value = [
            ...flatSpecificationList.value,
            result,
          ];
        } else {
          final Map<String, FlatSpecificationModel> specMap = {};
          bool replaced = false;

          for (final spec in flatSpecificationList.value) {
            bool isOldSpec = false;

            if (unitSpec.inventoryFlatSpecificationId > 0 &&
                spec.inventoryFlatSpecificationId > 0) {
              isOldSpec =
                  spec.inventoryFlatSpecificationId ==
                  unitSpec.inventoryFlatSpecificationId;
            }

            if (!isOldSpec &&
                unitSpec.uniquekey.isNotEmpty &&
                spec.uniquekey.isNotEmpty) {
              isOldSpec = spec.uniquekey == unitSpec.uniquekey;
            }

            if (!isOldSpec &&
                unitSpec.uniquekey.isEmpty &&
                spec.uniquekey.isEmpty) {
              isOldSpec = spec.flatLayout == unitSpec.flatLayout;
            }

            if (isOldSpec && !replaced) {
              if (result.uniquekey.isNotEmpty) {
                specMap[result.uniquekey] = result;
              } else {
                specMap['default_${result.flatLayout}'] = result;
              }
              replaced = true;
            } else if (!isOldSpec) {
              String key;
              if (spec.uniquekey.isNotEmpty) {
                key = spec.uniquekey;
              } else {
                key = 'default_${spec.flatLayout}';
              }

              if (!specMap.containsKey(key)) {
                specMap[key] = spec;
              }
            }
          }

          if (!replaced) {
            if (result.uniquekey.isNotEmpty) {
              specMap[result.uniquekey] = result;
            } else {
              specMap['default_${result.flatLayout}'] = result;
            }
          }

          flatSpecificationList.value = specMap.values.toList();
        }
        _calculateTotalArea();
      });
    }
  }

  // <---- DELETE DIALOG ---->
  Future<void> _showPopupToDeleteUnitSpecification(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Unit Specification?',
      'Are you sure you want to delete "Entire Flat"? This action cannot be undone.',
    );
    if (result && context.mounted) {
      _deleteUnitSpecification(index);
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
    if (selectedFlatFacing.value == null) {
      DialogHelper.showErrorMessage(
        context: context,
        title: "Validation Error",
        message: "Please select Flat Facing",
      );
      return;
    }
    final type = selectedFlatType.value?['DisplayName'] ?? "";

    if ((type == 'Residential' || type == 'Commercial') &&
        selectedFlatConfiguration.value == null) {
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
        flatType: selectedFlatType.value?['DisplayName'] ?? "",
        flatArea: double.parse(_flatSqftC.text),
        flatConfiguration:
            selectedFlatConfiguration.value?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value?['DisplayName'] ?? "",
        flatFacing: selectedFlatFacing.value?['DisplayName'] ?? "",
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
        flatType: selectedFlatType.value?['DisplayName'] ?? "",
        flatArea: double.parse(_flatSqftC.text),
        flatConfiguration:
            selectedFlatConfiguration.value?['DisplayName'] ?? '',
        flatStatus: selectedFlatStatus.value?['DisplayName'] ?? "",
        flatFacing: selectedFlatFacing.value?['DisplayName'] ?? "",
        flatSpecificationList: flatSpecificationList.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory Specification Form",
        authorization: _routeAuthorizationModel,
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
                    if (widget.flatModel != null || widget.floorModel != null)
                      _buildBuildingInfoCard(),
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
                        if (string == null) {
                          return 'Unit is required';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedFlatType,
                      builder: (context, typeValue, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(
                            'type_${typeValue?['zAttributesId'] ?? ""}',
                          ),
                          title: 'Unit Type',
                          isRequired: true,
                          dataList: flatTypeList,
                          initialValue: typeValue,
                          onSelected: (value) {
                            selectedFlatConfiguration.value = null;
                            selectedFlatType.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Unit Type is required';
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedFlatType.value = null;
                            selectedFlatConfiguration.value = null;
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
                            final type = value?['DisplayName'] ?? "";

                            if (type == 'Residential') {
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
                                  if (value == null) {
                                    return 'Unit Configuration is required';
                                  }
                                  return null;
                                },
                                onValueClear: () {
                                  selectedFlatConfiguration.value = null;
                                },
                              );
                            }

                            if (type == 'Commercial') {
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
                                  if (value == null) {
                                    return 'Unit Configuration is required';
                                  }
                                  return null;
                                },
                                onValueClear: () {
                                  selectedFlatConfiguration.value = null;
                                },
                              );
                            }

                            return const SizedBox();
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
                            if (value == null) {
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
                            'status_${statusValue?['zAttributesId'] ?? ""}',
                          ),
                          title: 'Status',
                          isRequired: true,
                          dataList: flatStatusList,
                          initialValue: statusValue,
                          onSelected: (value) {
                            selectedFlatStatus.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Status is required';
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
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: noDataWidget(
                                iconSize: 120,
                                message: "No Unit Specifications Found",
                              ),
                            ),
                          );
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      spec.flatLayout,
                                                      style:
                                                          AppTextStyle.ts14M(),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CustomIconButton(
                                                          onPressed: () {
                                                            _navigateToAddUnitSpecification(
                                                              unitSpec: spec,
                                                              index: index,
                                                            );
                                                          },
                                                          icon:
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .editIcon,
                                                                height: 18,
                                                                width: 18,
                                                              ),
                                                        ),
                                                        horizontalSpacing(),
                                                        CustomIconButton(
                                                          onPressed: () {
                                                            _showPopupToDeleteUnitSpecification(
                                                              index,
                                                            );
                                                          },
                                                          icon:
                                                              SvgPicture.asset(
                                                                AppAssets
                                                                    .deleteIcon,
                                                                height: 18,
                                                                width: 18,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                verticalSpacing(height: 8),
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        buildColumnTitleValue(
                                                          title:
                                                              "Area (Sq. ft)",
                                                          value:
                                                              spec.flatLayoutAreaSqFt
                                                                  .toString(),
                                                        ),
                                                        buildColumnTitleValue(
                                                          title:
                                                              "Length (Sq. ft)",
                                                          value:
                                                              spec.flatLayoutLengthSqFt
                                                                  .toString(),
                                                        ),
                                                      ],
                                                    ),
                                                    verticalSpacing(),
                                                    Row(
                                                      children: [
                                                        buildColumnTitleValue(
                                                          title:
                                                              "Width (Sq. ft)",
                                                          value:
                                                              spec.flatLayoutWidthSqFt
                                                                  .toString(),
                                                        ),
                                                        buildColumnTitleValue(
                                                          title: "Note",
                                                          value:
                                                              spec.note.isEmpty
                                                                  ? '-'
                                                                  : spec.note,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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

  Widget _buildBuildingInfoCard() {
    final building =
        widget.flatModel?.buildingNumber ??
        widget.flatModel?.buildingNumber ??
        '-';

    final wing = widget.flatModel?.wing ?? widget.flatModel?.wing ?? '-';

    final floor = widget.flatModel?.floor ?? widget.flatModel?.floor ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary, width: 0.5),
      ),
      child: Row(
        children: [
          buildColumnTitleValue(title: "Building Number", value: building),
          buildColumnTitleValue(title: "Wing", value: wing),
          buildColumnTitleValue(title: "Floor", value: floor),
        ],
      ),
    );
  }
}
