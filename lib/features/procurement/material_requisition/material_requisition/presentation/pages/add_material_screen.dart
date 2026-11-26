import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/repository/budget.repository.dart';
import 'package:k3h_erp_app/features/procurement/data/model/sub_material.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMaterialScreen extends StatefulWidget {
  final MaterialRequisitionDetailModel? materialDetails;
  final int projectId;
  final int? index;

  const AddMaterialScreen({
    super.key,
    required this.materialDetails,
    required this.index,
    required this.projectId,
  });

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen>
    with SingleTickerProviderStateMixin {
  final UtilsRepository utilsRepository = serviceLocator<UtilsRepository>();
  final BudgetRepository budgetRepository = serviceLocator<BudgetRepository>();
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late TabController _tabController;

  late UserModel user;
  final ValueNotifier<List<SubMaterialModel>> rawMaterialList = ValueNotifier(
    [],
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedMaterial = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedSubMaterial =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _requiredDate = ValueNotifier(null);

  // DIRECT (budget)
  final ValueNotifier<List<BudgetModel>> budgetList = ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> _category = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _subCategory = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _description = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _directSubMaterial = ValueNotifier(
    null,
  );

  //EDIT MODE
  bool get _isEditMode => widget.materialDetails != null;

  late TextEditingController _uomC, _quantityC, _remarkC;
  final GlobalKey<FormState> _inDirectFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _directFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    user = getCurrentUser();
    _prefill();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBudget();
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getMaterialSubMaterialUOMMaster();
        });
      }
    }
  }

  void initializeTextEditingController() {
    _uomC = TextEditingController();
    _quantityC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _prefill() {
    if (!_isEditMode) return;

    _selectedMaterial.value = {
      "DisplayName": widget.materialDetails!.materialName,
      "zAttributesId": widget.materialDetails!.materialMasterId,
    };
    _selectedSubMaterial.value = {
      "DisplayName": widget.materialDetails!.subMaterialName,
      "zAttributesId": widget.materialDetails!.subMaterialMasterId,
    };
    _uomC.text = widget.materialDetails!.uomCode;
    _requiredDate.value = widget.materialDetails!.requiredDate;
    _quantityC.text = widget.materialDetails!.materialQuantity.toString();
    _remarkC.text = widget.materialDetails!.remark;
  }

  // DIRECT => BUDGET
  Future<void> getBudget() async {
    DialogHelper.showProcessingOverlay(context);
    var result = await budgetRepository.pullBudget(
      pageNumber: 1,
      pageSize: 10000,
      queryParams: {
        "ProjectId": widget.projectId,
        "ClientRegistrationId": user.clientRegistrationId,
      },
    );

    try {
      return await result.fold(
        (failure) async {
          showErrorMessage(context, 'Error', failure.message);
          budgetList.value = [];
        },
        (response) async {
          final data = response["BudgetData"]; // TODO: confirm response key

          if (data == null) {
            budgetList.value = [];
            return;
          }

          final parsedList = await compute(
            (m) =>
                (m as List<dynamic>)
                    .map((e) => BudgetModel.fromJson(e))
                    .toList(),
            data,
          );

          budgetList.value = List<BudgetModel>.from(parsedList);
        },
      );
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  // DIRECT DROPDOWN LISTS (Category > Sub Category > Description > Sub Material)
  List<Map<String, dynamic>> get categoryList {
    final seen = <dynamic>{};

    return budgetList.value
        .where((e) => seen.add(e.categoryName))
        .map(
          (e) => {
            "zAttributesId": e.categoryName,
            "DisplayName": e.categoryName,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> get subCategoryList {
    final selected = _category.value?['zAttributesId'];
    if (selected == null) return [];
    final seen = <dynamic>{};

    return budgetList.value
        .where((e) => e.categoryName == selected && seen.add(e.levelId2))
        .map((e) => {"zAttributesId": e.levelId2, "DisplayName": e.level2Name})
        .toList();
  }

  List<Map<String, dynamic>> get descriptionList {
    final selected = _subCategory.value?['zAttributesId'];
    if (selected == null) return [];
    final seen = <dynamic>{};

    return budgetList.value
        .where((e) => e.levelId2 == selected && seen.add(e.levelId3))
        .map((e) => {"zAttributesId": e.levelId3, "DisplayName": e.level3Name})
        .toList();
  }

  List<Map<String, dynamic>> get directSubMaterialList {
    final selected = _description.value?['zAttributesId'];
    if (selected == null) return [];
    final seen = <dynamic>{};

    return budgetList.value
        .where((e) => e.levelId3 == selected && seen.add(e.levelId4))
        .map((e) => {"zAttributesId": e.levelId4, "DisplayName": e.level4Name})
        .toList();
  }

  // INDIRECT DROPDOWN FUNCTIONS
  Future<void> getMaterialSubMaterialUOMMaster() async {
    DialogHelper.showProcessingOverlay(context);
    var result = await utilsRepository
        .getMaterialMasterSubMaterialMasterUOMMaster(
          projectId: widget.projectId,
          queryParams: {"ClientRegistrationId": user.clientRegistrationId},
        );

    try {
      return await result.fold(
        (failure) async {
          showErrorMessage(context, 'Error', failure.message);
          rawMaterialList.value = [];
        },
        (response) async {
          final data = response["MaterialMasterSubMaterialMasterData"];

          if (data == null) {
            rawMaterialList.value = [];
          }

          final parsedList = await compute(
            (m) =>
                (m as List<dynamic>)
                    .map((e) => SubMaterialModel.fromJson(e))
                    .toList(),
            data,
          );

          rawMaterialList.value = List<SubMaterialModel>.from(parsedList);
        },
      );
    } finally {
      if (mounted) {
        goRouter.pop();
      }
    }
  }

  List<Map<String, dynamic>> get materialList {
    final seen = <dynamic>{};

    return rawMaterialList.value
        .where((e) {
          return seen.add(e.materialMasterId);
        })
        .map((e) {
          return {
            "zAttributesId": e.materialMasterId,
            "DisplayName": e.materialName,
          };
        })
        .toList();
  }

  List<Map<String, dynamic>> get subMaterialList {
    final selectedId = _selectedMaterial.value?['zAttributesId'];

    if (selectedId == null) return [];

    return rawMaterialList.value
        .where((e) => e.materialMasterId == selectedId)
        .map((e) {
          return {
            "zAttributesId": e.subMaterialMasterId,
            "DisplayName": e.subMaterialName,
          };
        })
        .toList();
  }

  void updateUOM() {
    final selectedId = _selectedSubMaterial.value?['zAttributesId'];
    if (selectedId == null) return;
    final selectedItem = rawMaterialList.value.firstWhere(
      (e) => e.subMaterialMasterId == selectedId,
    );

    _uomC.text = selectedItem.uomCode;
  }

  void _submit() {
    if (_tabController.index == 0) {
      _submitDirect();
      return;
    }
    if (!_inDirectFormKey.currentState!.validate()) return;
    final selectedId = _selectedSubMaterial.value?['zAttributesId'];
    final selectedItem = rawMaterialList.value.firstWhere(
      (e) => e.subMaterialMasterId == selectedId,
    );
    final material = MaterialRequisitionDetailModel(
      materialRequisitionDetailId:
          _isEditMode ? widget.materialDetails!.materialRequisitionDetailId : 0,
      uniquekey: _isEditMode ? widget.materialDetails!.uniquekey : '',
      materialMasterId: _selectedMaterial.value?['zAttributesId'] ?? -1,
      materialName: _selectedMaterial.value?['DisplayName'] ?? '',
      subMaterialName: _selectedSubMaterial.value?['DisplayName'] ?? '',
      subMaterialMasterId: _selectedSubMaterial.value?['zAttributesId'] ?? -1,
      materialQuantity: double.tryParse(_quantityC.text) ?? 0,
      uomMasterId: selectedItem.uomMasterId,
      uomCode: _uomC.text,
      uom: _uomC.text,
      requiredDate: _requiredDate.value ?? DateTime.now(),
      remark: _remarkC.text.trim(),
      materialReceivedQuantityTillDate:
          _isEditMode
              ? widget.materialDetails!.materialReceivedQuantityTillDate
              : 0,
      createdById: _isEditMode ? widget.materialDetails!.createdById : 0,
      createdBy: _isEditMode ? widget.materialDetails!.createdBy : '',
      createdDate:
          _isEditMode ? widget.materialDetails!.createdDate : DateTime.now(),
      modifiedById: _isEditMode ? widget.materialDetails!.modifiedById : 0,
      modifiedBy: _isEditMode ? widget.materialDetails!.modifiedBy : "",
    );
    if (_isEditMode) {
      _materialRequisitionCubit.updateMaterialList(material, widget.index);
    } else {
      _materialRequisitionCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  void _submitDirect() {
    if (!_directFormKey.currentState!.validate()) return;
    final selectedId = _directSubMaterial.value?['zAttributesId'];
    final selectedItem = budgetList.value.firstWhere(
      (e) => e.levelId4 == selectedId,
    );
    final material = MaterialRequisitionDetailModel(
      materialRequisitionDetailId:
          _isEditMode ? widget.materialDetails!.materialRequisitionDetailId : 0,
      uniquekey: _isEditMode ? widget.materialDetails!.uniquekey : '',
      materialMasterId: -1, // TODO: not available in BudgetModel
      materialName: selectedItem.level4MaterialName,
      subMaterialName: selectedItem.level4Name,
      subMaterialMasterId: selectedItem.levelId4,
      materialQuantity: double.tryParse(_quantityC.text) ?? 0,
      uomMasterId: 0, // TODO: not available in BudgetModel
      uomCode: selectedItem.level4SubMaterialUomCode,
      uom: selectedItem.level4SubMaterialUom,
      requiredDate: _requiredDate.value ?? DateTime.now(),
      remark: _remarkC.text.trim(),
      materialReceivedQuantityTillDate:
          _isEditMode
              ? widget.materialDetails!.materialReceivedQuantityTillDate
              : 0,
      createdById: _isEditMode ? widget.materialDetails!.createdById : 0,
      createdBy: _isEditMode ? widget.materialDetails!.createdBy : '',
      createdDate:
          _isEditMode ? widget.materialDetails!.createdDate : DateTime.now(),
      modifiedById: _isEditMode ? widget.materialDetails!.modifiedById : 0,
      modifiedBy: _isEditMode ? widget.materialDetails!.modifiedBy : "",
    );
    if (_isEditMode) {
      _materialRequisitionCubit.updateMaterialList(material, widget.index);
    } else {
      _materialRequisitionCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  @override
  void dispose() {
    _uomC.dispose();
    _quantityC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isEditMode ? "Update Material" : "Add Material",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
          ),
          verticalSpacing(),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ['Direct', 'In - Direct'],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_directView(), _inDirectView()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(Icons.add, size: 18, color: AppColor.white),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }

  Widget _directView() {
    return ValueListenableBuilder(
      valueListenable: budgetList,
      builder: (context, value, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Form(
            key: _directFormKey,
            child: Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _category,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: "Category",
                        isRequired: true,
                        hintText: "Select Category",
                        initialValue: value,
                        dataList: categoryList,
                        onValueClear: () {
                          _category.value = null;
                          _subCategory.value = null;
                          _description.value = null;
                          _directSubMaterial.value = null;
                        },
                        onSelected: (value) {
                          _category.value = value;
                          _subCategory.value = null;
                          _description.value = null;
                          _directSubMaterial.value = null;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Category is required.";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _category,
                    builder: (context, value, child) {
                      return ValueListenableBuilder(
                        valueListenable: _subCategory,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: "Sub Category",
                            isRequired: true,
                            hintText: "Select Sub Category",
                            initialValue: value,
                            dataList: subCategoryList,
                            onValueClear: () {
                              _subCategory.value = null;
                              _description.value = null;
                              _directSubMaterial.value = null;
                            },
                            onSelected: (value) {
                              _subCategory.value = value;
                              _description.value = null;
                              _directSubMaterial.value = null;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Sub category is required.";
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _subCategory,
                    builder: (context, value, child) {
                      return ValueListenableBuilder(
                        valueListenable: _description,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: "Description",
                            isRequired: true,
                            hintText: "Select Description",
                            initialValue: value,
                            dataList: descriptionList,
                            onValueClear: () {
                              _description.value = null;
                              _directSubMaterial.value = null;
                            },
                            onSelected: (value) {
                              _description.value = value;
                              _directSubMaterial.value = null;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Description is required.";
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _description,
                    builder: (context, value, child) {
                      return ValueListenableBuilder(
                        valueListenable: _directSubMaterial,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: "Sub Material",
                            isRequired: true,
                            hintText: "Select Sub Material",
                            initialValue: value,
                            dataList: directSubMaterialList,
                            onValueClear: () {
                              _directSubMaterial.value = null;
                            },
                            onSelected: (value) {
                              _directSubMaterial.value = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Sub material is required.";
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: "Quantity",
                    hint: "Enter Quantity",
                    isRequired: true,
                    inputFormatterList: InputValidator.decimal(2),
                    keyboardType: TextInputType.numberWithOptions(),
                    textController: _quantityC,
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Quantity is required.";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _requiredDate,
                    builder: (context, value, child) {
                      return CustomDatePicker(
                        title: "Required Date",
                        initialDate: value,
                        isRequired: true,
                        startDate: DateTime.now(),
                        setValue: (value) {
                          _requiredDate.value = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Date is required.';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: "Remark",
                    hint: "Enter Remark",
                    minLines: 3,
                    maxLines: 10,
                    textController: _remarkC,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _inDirectView() {
    return ValueListenableBuilder(
      valueListenable: rawMaterialList,
      builder: (context, value, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Form(
            key: _inDirectFormKey,
            child: Column(
              children: [
                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _selectedMaterial,
                        builder: (context, value, child) {
                          return CustomDropDownWidget(
                            title: "Material",
                            isRequired: true,
                            hintText: "Select Material",
                            initialValue: value,
                            dataList: materialList,
                            onValueClear: () {
                              _selectedMaterial.value = null;
                              _selectedSubMaterial.value = null;
                              _uomC.clear();
                            },
                            onSelected: (value) {
                              _selectedMaterial.value = value;
                              _selectedSubMaterial.value = null;
                              _uomC.clear();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Material is required.";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedMaterial,
                        builder: (context, value, child) {
                          return ValueListenableBuilder(
                            valueListenable: _selectedSubMaterial,
                            builder: (context, value, child) {
                              return CustomDropDownWidget(
                                title: "Sub Material",
                                isRequired: true,
                                hintText: "Select Sub Material",
                                initialValue: value,
                                dataList: subMaterialList,
                                onValueClear: () {
                                  _selectedSubMaterial.value = null;
                                  _uomC.clear();
                                },
                                onSelected: (value) {
                                  _selectedSubMaterial.value = value;
                                  updateUOM();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Sub material is required.";
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        },
                      ),

                      CustomTextField(
                        title: "UOM",
                        isRequired: true,
                        readOnly: true,
                        textController: _uomC,
                      ),
                      ValueListenableBuilder(
                        valueListenable: _requiredDate,
                        builder: (context, value, child) {
                          return CustomDatePicker(
                            title: "Required Date",
                            initialDate: value,
                            isRequired: true,
                            startDate: DateTime.now(),
                            setValue: (value) {
                              _requiredDate.value = value;
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Date is required.';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      CustomTextField(
                        title: "Quantity",
                        hint: "Enter Quantity",
                        isRequired: true,
                        inputFormatterList: InputValidator.decimal(2),
                        keyboardType: TextInputType.numberWithOptions(),
                        textController: _quantityC,
                        validator: (value) {
                          if (value == null || value == "") {
                            return "Quantity is required.";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: "Remark",
                        hint: "Enter Remark",
                        minLines: 3,
                        maxLines: 10,
                        textController: _remarkC,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
