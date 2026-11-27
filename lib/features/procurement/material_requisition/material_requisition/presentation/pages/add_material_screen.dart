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
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
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
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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

  // INDIRECT
  final ValueNotifier<List<SubMaterialMasterModel>> rawMaterialList =
      ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> _selectedMaterial = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedSubMaterial =
      ValueNotifier(null);
  final ValueNotifier<DateTime?> _inDirectRequiredDate = ValueNotifier(null);

  // DIRECT (budget)
  final ValueNotifier<List<BudgetModel>> budgetList = ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> _category = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _subCategory = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _description = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _directSubMaterial = ValueNotifier(
    null,
  );
  final ValueNotifier<DateTime?> _directRequiredDate = ValueNotifier(null);

  //EDIT MODE
  bool get _isEditMode => widget.materialDetails != null;
  bool get _isInDirectEdit =>
      _isEditMode &&
      widget.materialDetails!.materialRequisitionType == 'In - Direct';

  late TextEditingController _uomC, _quantityC, _remarkC;
  final GlobalKey<FormState> _inDirectFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _directFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _isInDirectEdit ? 1 : 0,
    );
    _tabController.addListener(_handleTabChange);
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    user = getCurrentUser();
    _prefill();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getBudget();
      // Editing an In-Direct row opens directly on the In-Direct tab,
      // so the master list has to be loaded here (no tab change fires).
      if (_isInDirectEdit && mounted) await getMaterialSubMaterialUOMMaster();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && rawMaterialList.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getMaterialSubMaterialUOMMaster();
      });
    }
  }

  void initializeTextEditingController() {
    _uomC = TextEditingController();
    _quantityC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _prefill() {
    if (!_isInDirectEdit) return;

    final details = widget.materialDetails!;
    _selectedMaterial.value = {
      "DisplayName": details.materialName,
      "zAttributesId": details.materialMasterId,
      "Code": details.materialCode,
    };
    _selectedSubMaterial.value = {
      "DisplayName": details.subMaterialName,
      "zAttributesId": details.subMaterialMasterId,
    };
    _uomC.text = details.uomCode;
    _inDirectRequiredDate.value = details.requiredDate;
    _quantityC.text = details.materialQuantity.toString();
    _remarkC.text = details.remark;
  }

  // ---------------------------------------------------------------------------
  // DIRECT => BUDGET
  // ---------------------------------------------------------------------------
  Future<void> getBudget() async {
    DialogHelper.showProcessingOverlay(context);
    try {
      final result = await budgetRepository.pullBudget(
        pageNumber: 1,
        pageSize: 10000,
        queryParams: {
          "ProjectId": widget.projectId,
          "IsCheckPermission": false,
          "ApprovalStatus": "APPROVED",
        },
      );

      result.fold(
        (failure) {
          showErrorMessage(context, 'Error', failure.message);
          budgetList.value = [];
        },
        (response) {
          final data = response['data'] as List<BudgetModel>? ?? [];
          budgetList.value = data;
          debugPrint('BUDGET COUNT: ${data.length}');
        },
      );
    } catch (e, st) {
      debugPrint('getBudget error: $e\n$st');
      budgetList.value = [];
    } finally {
      if (mounted) goRouter.pop();
    }
  }

  // DIRECT DROPDOWN LISTS (Category > Sub Category > Description > Sub Material)
  // L1 -> Category
  List<Map<String, dynamic>> get categoryList {
    final seen = <int>{};
    return budgetList.value
        .where((e) => e.levelType == 'L1' && seen.add(e.levelId1))
        .map((e) => {"zAttributesId": e.levelId1, "DisplayName": e.level1Name})
        .toList();
  }

  // L2 -> Sub Category (depends on L1)
  List<Map<String, dynamic>> get subCategoryList {
    final l1 = _category.value?['zAttributesId'];
    if (l1 == null) return [];
    final seen = <int>{};
    return budgetList.value
        .where(
          (e) =>
              e.levelType == 'L2' && e.levelId1 == l1 && seen.add(e.levelId2),
        )
        .map((e) => {"zAttributesId": e.levelId2, "DisplayName": e.level2Name})
        .toList();
  }

  // L3 -> Description (depends on L1 + L2)
  List<Map<String, dynamic>> get descriptionList {
    final l1 = _category.value?['zAttributesId'];
    final l2 = _subCategory.value?['zAttributesId'];
    if (l1 == null || l2 == null) return [];
    final seen = <int>{};
    return budgetList.value
        .where(
          (e) =>
              e.levelType == 'L3' &&
              e.levelId1 == l1 &&
              e.levelId2 == l2 &&
              seen.add(e.levelId3),
        )
        .map((e) => {"zAttributesId": e.levelId3, "DisplayName": e.level3Name})
        .toList();
  }

  // L4 -> Sub Material (depends on L1 + L2 + L3)
  List<Map<String, dynamic>> get directSubMaterialList {
    final l1 = _category.value?['zAttributesId'];
    final l2 = _subCategory.value?['zAttributesId'];
    final l3 = _description.value?['zAttributesId'];
    if (l1 == null || l2 == null || l3 == null) return [];
    final seen = <int>{};
    return budgetList.value
        .where(
          (e) =>
              e.levelType == 'L4' &&
              e.levelId1 == l1 &&
              e.levelId2 == l2 &&
              e.levelId3 == l3 &&
              seen.add(e.levelId4),
        )
        .map((e) => {"zAttributesId": e.levelId4, "DisplayName": e.level4Name})
        .toList();
  }

  // The selected L4 budget row (null until Sub Material is selected)
  BudgetModel? get selectedBudgetItem {
    final l1 = _category.value?['zAttributesId'];
    final l2 = _subCategory.value?['zAttributesId'];
    final l3 = _description.value?['zAttributesId'];
    final l4 = _directSubMaterial.value?['zAttributesId'];
    if (l1 == null || l2 == null || l3 == null || l4 == null) return null;

    for (final e in budgetList.value) {
      if (e.levelType == 'L4' &&
          e.levelId1 == l1 &&
          e.levelId2 == l2 &&
          e.levelId3 == l3 &&
          e.levelId4 == l4) {
        return e;
      }
    }
    return null;
  }

  // Lead time (days) of the selected L4 item
  int get leadTimeDays {
    final v = selectedBudgetItem?.level4LeadTimeInDays;
    if (v == null) return 0;
    return num.tryParse(v.toString())?.toInt() ?? 0;
  }

  // Today + lead time (null until L4 is selected)
  DateTime? get leadTimeRequiredDate {
    if (selectedBudgetItem == null) return null;
    return _todayPlus(leadTimeDays);
  }

  String get selectedDirectMaterialName =>
      selectedBudgetItem?.level4MaterialName ?? '';
  String get selectedSubMaterialName => selectedBudgetItem?.level4Name ?? '';

  String get selectedDirectUom {
    final e = selectedBudgetItem;
    if (e == null) return '-';
    return '${e.level4SubMaterialUom} (${e.level4SubMaterialUomCode})';
  }

  String get selectedDirectMaterialRate =>
      (selectedBudgetItem?.materialCost ?? 0).toIndianCurrency();
  String get selectedDirectRequiredQuantity =>
      (selectedBudgetItem?.quantity ?? 0).addCommas();
  String get selectedDirectOrderQuantity =>
      (selectedBudgetItem?.orderQuantity ?? 0).addCommas();
  String get selectedDirectReceivedQuantity =>
      (selectedBudgetItem?.receivedQuantity ?? 0).addCommas();
  String get selectedDirectLeadTime =>
      (selectedBudgetItem?.level4LeadTimeInDays ?? 0).addCommas();
  String get selectedDirectIsTolerant {
    final value =
        selectedBudgetItem?.level4IsTolerant.toString().toLowerCase() ?? '';
    return (value == 'true' || value == '1') ? 'Yes' : 'No';
  }

  // ---------------------------------------------------------------------------
  // INDIRECT => MASTER
  // ---------------------------------------------------------------------------
  Future<void> getMaterialSubMaterialUOMMaster() async {
    DialogHelper.showProcessingOverlay(context);
    try {
      final result = await utilsRepository
          .getMaterialMasterSubMaterialMasterUOMMaster(
            projectId: widget.projectId,
            queryParams: {"ClientRegistrationId": user.clientRegistrationId},
          );

      await result.fold(
        (failure) async {
          if (mounted) showErrorMessage(context, 'Error', failure.message);
          rawMaterialList.value = [];
        },
        (response) async {
          final data = response["MaterialMasterSubMaterialMasterData"];

          if (data == null) {
            rawMaterialList.value = [];
            return;
          }

          final parsedList = await compute(
            (m) =>
                (m as List<dynamic>)
                    .map((e) => SubMaterialMasterModel.fromJson(e))
                    .toList(),
            data,
          );

          rawMaterialList.value = List<SubMaterialMasterModel>.from(parsedList);
        },
      );
    } catch (e, st) {
      debugPrint('getMaterialSubMaterialUOMMaster error: $e\n$st');
      rawMaterialList.value = [];
    } finally {
      if (mounted) goRouter.pop();
    }
  }

  List<Map<String, dynamic>> get materialList {
    final seen = <dynamic>{};

    return rawMaterialList.value
        .where((e) => seen.add(e.materialMasterId))
        .map(
          (e) => {
            "zAttributesId": e.materialMasterId,
            "DisplayName": e.materialName,
            "Code": e.materialCode,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> get subMaterialList {
    final selectedId = _selectedMaterial.value?['zAttributesId'];
    if (selectedId == null) return [];

    return rawMaterialList.value
        .where((e) => e.materialMasterId == selectedId)
        .map(
          (e) => {
            "zAttributesId": e.subMaterialMasterId,
            "DisplayName": e.subMaterialName,
          },
        )
        .toList();
  }

  // The selected In-Direct master row (null until Sub Material is selected)
  SubMaterialMasterModel? get selectedIndirectItem {
    final id = _selectedSubMaterial.value?['zAttributesId'];
    if (id == null) return null;
    for (final e in rawMaterialList.value) {
      if (e.subMaterialMasterId == id) return e;
    }
    return null;
  }

  String get selectedInDirectUom {
    final e = selectedIndirectItem;
    if (e == null) return '-';
    return e.uomCode;
  }

  // Lead time (days) of the selected In-Direct sub material
  int get indirectLeadTimeDays {
    final v =
        selectedIndirectItem?.leadTimeInDays; // <-- adjust field name if needed
    if (v == null) return 0;
    return num.tryParse(v.toString())?.toInt() ?? 0;
  }

  String get selectedInDirectIsTolerant {
    final value =
        selectedIndirectItem?.isTolerant.toString().toLowerCase() ?? '';
    return (value == 'true' || value == '1') ? 'Yes' : 'No';
  }

  // Today + lead time (null until Sub Material is selected)
  DateTime? get indirectLeadTimeRequiredDate {
    if (selectedIndirectItem == null) return null;
    return _todayPlus(indirectLeadTimeDays);
  }

  void updateUOM() {
    final item = selectedIndirectItem;
    if (item == null) return;
    _uomC.text = item.uomCode;
  }

  DateTime _todayPlus(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------
  void _submit() {
    if (_tabController.index == 0) {
      _submitDirect();
    } else {
      _submitInDirect();
    }
  }

  void _submitInDirect() {
    if (!_inDirectFormKey.currentState!.validate()) return;
    final selectedItem = selectedIndirectItem;
    if (selectedItem == null) return;

    _saveMaterial(
      _buildMaterial(
        materialMasterId: selectedItem.materialMasterId,
        materialCode: _selectedMaterial.value?['Code'] ?? '',
        materialName: _selectedMaterial.value?['DisplayName'] ?? '',
        subMaterialName: _selectedSubMaterial.value?['DisplayName'] ?? '',
        subMaterialMasterId: selectedItem.subMaterialMasterId,
        uomMasterId: selectedItem.uomMasterId,
        uomCode: selectedItem.uomCode,
        uom: selectedItem.uom,
        type: 'In - Direct',
        requiredDate: _inDirectRequiredDate.value,
        approvalStatus:
            _isEditMode ? widget.materialDetails!.approvalStatus : '',
        keepModified: true,
      ),
    );
  }

  void _submitDirect() {
    if (!_directFormKey.currentState!.validate()) return;
    final selectedItem = selectedBudgetItem;
    if (selectedItem == null) return;

    _saveMaterial(
      _buildMaterial(
        materialMasterId: 0, // Map actual ID if available in BudgetModel
        materialCode: '',
        materialName: selectedItem.level4MaterialName,
        subMaterialName: selectedItem.level4Name,
        subMaterialMasterId: selectedItem.levelId4,
        uomMasterId: 0, // Map actual ID if available in BudgetModel
        uomCode: selectedItem.level4SubMaterialUomCode,
        uom: selectedItem.level4SubMaterialUom,
        type: 'Direct',
        budget: selectedItem,
        requiredDate: _directRequiredDate.value,
        approvalStatus: '',
        keepModified: false,
      ),
    );
  }

  // Single place that builds the model for both tabs
  MaterialRequisitionDetailModel _buildMaterial({
    required int materialMasterId,
    required String materialCode,
    required String materialName,
    required String subMaterialName,
    required int subMaterialMasterId,
    required int uomMasterId,
    required String uomCode,
    required String uom,
    required String type,
    required DateTime? requiredDate,
    required String approvalStatus,
    required bool keepModified,
    BudgetModel? budget, // only for Direct (budget hierarchy)
  }) {
    final old = widget.materialDetails;

    return MaterialRequisitionDetailModel(
      materialRequisitionDetailId:
          _isEditMode ? old!.materialRequisitionDetailId : 0,
      uniquekey: _isEditMode ? old!.uniquekey : '',

      // Material details
      materialMasterId: materialMasterId,
      materialCode: materialCode,
      materialName: materialName,
      subMaterialName: subMaterialName,
      subMaterialMasterId: subMaterialMasterId,

      // UOM
      uomMasterId: uomMasterId,
      uomCode: uomCode,
      uom: uom,

      // Material type
      materialRequisitionType: type,

      // Budget hierarchy (0 / '' for In-Direct)
      levelId1: budget?.levelId1 ?? 0,
      level1Name: budget?.level1Name ?? '',
      levelId2: budget?.levelId2 ?? 0,
      level2Name: budget?.level2Name ?? '',
      levelId3: budget?.levelId3 ?? 0,
      level3Name: budget?.level3Name ?? '',
      levelId4: budget?.levelId4 ?? 0,
      level4Name: budget?.level4Name ?? '',
      level4SubMaterialUomCode: budget?.level4SubMaterialUomCode ?? '',
      level4SubMaterialUom: budget?.level4SubMaterialUom ?? '',

      materialQuantity: double.tryParse(_quantityC.text) ?? 0,
      requiredDate: requiredDate ?? DateTime.now(),
      remark: _remarkC.text.trim(),

      materialReceivedQuantityTillDate:
          _isEditMode ? old!.materialReceivedQuantityTillDate : 0,
      approvalStatus: approvalStatus,
      vendorSystemGeneratedCode: '',
      vendorCompanyName: '',
      vendorName: '',
      vendorId: 0,
      amount: 0,
      poSystemGeneratedCode: '',
      purchaseOrderURL: '',
      materialRequisitionPurchaseOrderId: 0,
      purchaseOrderCreatedBy: '',
      purchaseOrderCreatedDate: null,

      createdById: _isEditMode ? old!.createdById : 0,
      createdBy: _isEditMode ? old!.createdBy : '',
      createdDate: _isEditMode ? old!.createdDate : DateTime.now(),
      modifiedById: (keepModified && _isEditMode) ? old!.modifiedById : 0,
      modifiedBy: (keepModified && _isEditMode) ? old!.modifiedBy : '',
      modifiedDate: null,
    );
  }

  void _saveMaterial(MaterialRequisitionDetailModel material) {
    if (_isEditMode) {
      _materialRequisitionCubit.updateMaterialList(material, widget.index);
    } else {
      _materialRequisitionCubit.addMaterial(material);
    }
    goRouter.pop();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    _uomC.dispose();
    _quantityC.dispose();
    _remarkC.dispose();

    rawMaterialList.dispose();
    _selectedMaterial.dispose();
    _selectedSubMaterial.dispose();
    _inDirectRequiredDate.dispose();

    budgetList.dispose();
    _category.dispose();
    _subCategory.dispose();
    _description.dispose();
    _directSubMaterial.dispose();
    _directRequiredDate.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
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
                          _directRequiredDate.value = null;
                        },
                        onSelected: (value) {
                          _category.value = value;
                          _subCategory.value = null;
                          _description.value = null;
                          _directSubMaterial.value = null;
                          _directRequiredDate.value = null;
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
                              _directRequiredDate.value = null;
                            },
                            onSelected: (value) {
                              _subCategory.value = value;
                              _description.value = null;
                              _directSubMaterial.value = null;
                              _directRequiredDate.value = null;
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
                              _directRequiredDate.value = null;
                            },
                            onSelected: (value) {
                              _description.value = value;
                              _directSubMaterial.value = null;
                              _directRequiredDate.value = null;
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
                              _directRequiredDate.value = null;
                            },
                            onSelected: (value) {
                              _directSubMaterial.value = value;
                              _directRequiredDate.value = leadTimeRequiredDate;
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
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _category,
                      _subCategory,
                      _description,
                      _directSubMaterial,
                    ]),
                    builder: (context, _) {
                      final item = selectedBudgetItem;
                      return Column(
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 100),
                            alignment: Alignment.topCenter,
                            child:
                                item == null
                                    ? const SizedBox(width: double.infinity)
                                    : infoCard([
                                      {
                                        'title': 'Material Name',
                                        'value': selectedDirectMaterialName,
                                      },
                                      {
                                        'title': 'Sub Material Name',
                                        'value': selectedSubMaterialName,
                                      },
                                      {
                                        'title': 'UOM',
                                        'value': selectedDirectUom,
                                      },
                                      {
                                        'title': 'Material Rate',
                                        'value': selectedDirectMaterialRate,
                                      },
                                      {
                                        'title': 'Required Quantity',
                                        'value': selectedDirectRequiredQuantity,
                                      },
                                      {
                                        'title': 'Order Quantity',
                                        'value': selectedDirectOrderQuantity,
                                      },
                                      {
                                        'title': 'Received Quantity',
                                        'value': selectedDirectReceivedQuantity,
                                      },
                                      {
                                        'title': 'Lead Time (Days)',
                                        'value': selectedDirectLeadTime,
                                      },
                                      {
                                        'title': 'Is Tolerant',
                                        'value': selectedDirectIsTolerant,
                                      },
                                    ]),
                          ),
                          verticalSpacing(),
                        ],
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
                    valueListenable: _directRequiredDate,
                    builder: (context, value, child) {
                      return CustomDatePicker(
                        title: "Required Date",
                        initialDate: value,
                        isRequired: true,
                        readOnly: true,
                        startDate: leadTimeRequiredDate ?? DateTime.now(),
                        setValue: (value) {
                          _directRequiredDate.value = value;
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
                              _inDirectRequiredDate.value = null;
                              _uomC.clear();
                            },
                            onSelected: (value) {
                              _selectedMaterial.value = value;
                              _selectedSubMaterial.value = null;
                              _inDirectRequiredDate.value = null;
                              _uomC.clear();
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) {
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
                                  _inDirectRequiredDate.value = null;
                                  _uomC.clear();
                                },
                                onSelected: (value) {
                                  _selectedSubMaterial.value = value;
                                  updateUOM();
                                  _inDirectRequiredDate.value =
                                      indirectLeadTimeRequiredDate;
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

                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _selectedMaterial,
                          _selectedSubMaterial,
                        ]),
                        builder: (context, _) {
                          final item = selectedIndirectItem;
                          return Column(
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 100),
                                alignment: Alignment.topCenter,
                                child:
                                    item == null
                                        ? const SizedBox(width: double.infinity)
                                        : infoCard([
                                          {
                                            'title': 'UOM',
                                            'value': selectedInDirectUom,
                                          },
                                          {
                                            'title': 'Lead Time (Days)',
                                            'value':
                                                indirectLeadTimeDays
                                                    .addCommas(),
                                          },
                                          {
                                            'title': 'Is Tolerant',
                                            'value': selectedInDirectIsTolerant,
                                          },
                                        ]),
                              ),
                              verticalSpacing(),
                            ],
                          );
                        },
                      ),

                      ValueListenableBuilder(
                        valueListenable: _inDirectRequiredDate,
                        builder: (context, value, child) {
                          return CustomDatePicker(
                            title: "Required Date",
                            initialDate: value,
                            isRequired: true,
                            readOnly: true,
                            startDate:
                                indirectLeadTimeRequiredDate ?? DateTime.now(),
                            setValue: (value) {
                              _inDirectRequiredDate.value = value;
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
