import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

typedef _Option = Map<String, dynamic>;

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
  static const String _direct = 'Direct';
  static const String _inDirect = 'In - Direct';

  final _utilsRepository = serviceLocator<UtilsRepository>();
  final _budgetRepository = serviceLocator<BudgetRepository>();

  late final MaterialRequisitionCubit _cubit;
  late final TabController _tabController;

  late final List<String> _types;

  final _masterList = ValueNotifier<List<SubMaterialMasterModel>>([]);
  final _material = ValueNotifier<_Option?>(null);
  final _subMaterial = ValueNotifier<_Option?>(null);
  final _inDirectDate = ValueNotifier<DateTime?>(null);

  final _budgetList = ValueNotifier<List<BudgetModel>>([]);
  final _category = ValueNotifier<_Option?>(null);
  final _subCategory = ValueNotifier<_Option?>(null);
  final _description = ValueNotifier<_Option?>(null);
  final _directSubMaterial = ValueNotifier<_Option?>(null);
  final _directDate = ValueNotifier<DateTime?>(null);

  late TextEditingController _quantityC, _remarkC;
  final _inDirectFormKey = GlobalKey<FormState>();
  final _directFormKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.materialDetails != null;
  bool get _isInDirectEdit =>
      _isEditMode &&
      widget.materialDetails!.materialRequisitionType == _inDirect;

  bool get _isInDirectTab => _types[_tabController.index] == _inDirect;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MaterialRequisitionCubit>();
    _initializeTextEditingControllers();
    _types = _resolveTypes();
    final startIndex = _types.indexOf(_isInDirectEdit ? _inDirect : _direct);
    _tabController = TabController(
      length: _types.length,
      vsync: this,
      initialIndex: startIndex < 0 ? 0 : startIndex,
    )..addListener(_handleTabChange);

    _prefill();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_types.contains(_direct)) await _loadBudget();

      // NO TAB CHANGE FIRES WHEN STARTING ON IN-DIRECT, SO LOAD IT HERE
      if (_isInDirectTab && mounted) await _loadMasterList();
    });
  }

  void _initializeTextEditingControllers() {
    _quantityC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // EMPTY LIST -> BOTH TABS, OTHERWISE ONLY THE TYPE ALREADY IN THE LIST
  List<String> _resolveTypes() {
    final list = _cubit.state.materialList;
    return list.isEmpty
        ? [_direct, _inDirect]
        : [list.first.materialRequisitionType];
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_isInDirectTab && _masterList.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMasterList());
    }
  }

  void _prefill() {
    if (!_isEditMode) return;
    final d = widget.materialDetails!;

    _quantityC.text = d.materialQuantity.toString();
    _remarkC.text = d.remark;

    if (_isInDirectEdit) {
      _material.value = {
        "DisplayName": d.materialName,
        "zAttributesId": d.materialMasterId,
        "Code": d.materialCode,
      };
      _subMaterial.value = {
        "DisplayName": d.subMaterialName,
        "zAttributesId": d.subMaterialMasterId,
      };
      _inDirectDate.value = d.requiredDate;
    } else {
      // SET NOTIFIERS DIRECTLY: SETTERS WOULD RESET LOWER LEVELS AND THE DATE
      _category.value = {
        "zAttributesId": d.levelId1,
        "DisplayName": d.level1Name,
      };
      _subCategory.value = {
        "zAttributesId": d.levelId2,
        "DisplayName": d.level2Name,
      };
      _description.value = {
        "zAttributesId": d.levelId3,
        "DisplayName": d.level3Name,
      };
      _directSubMaterial.value = {
        "zAttributesId": d.levelId4,
        "DisplayName": d.level4Name,
      };
      _directDate.value = d.requiredDate;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityC.dispose();
    _remarkC.dispose();

    _masterList.dispose();
    _material.dispose();
    _subMaterial.dispose();
    _inDirectDate.dispose();

    _budgetList.dispose();
    _category.dispose();
    _subCategory.dispose();
    _description.dispose();
    _directSubMaterial.dispose();
    _directDate.dispose();
    super.dispose();
  }

  int _toInt(dynamic v) =>
      v == null ? 0 : num.tryParse(v.toString())?.toInt() ?? 0;

  String _yesNo(dynamic v) {
    final value = v.toString().toLowerCase();
    return (value == 'true' || value == '1') ? 'Yes' : 'No';
  }

  DateTime _todayPlus(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }

  Future<void> _loadBudget() async {
    DialogHelper.showProcessingOverlay(context);
    try {
      final result = await _budgetRepository.pullBudget(
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
          _budgetList.value = [];
        },
        (response) {
          _budgetList.value = response['data'] as List<BudgetModel>? ?? [];
        },
      );
    } catch (e, st) {
      debugPrint('loadBudget error: $e\n$st');
      _budgetList.value = [];
    } finally {
      if (mounted) goRouter.pop();
    }
  }

  int? get _l1 => _category.value?['zAttributesId'];
  int? get _l2 => _subCategory.value?['zAttributesId'];
  int? get _l3 => _description.value?['zAttributesId'];
  int? get _l4 => _directSubMaterial.value?['zAttributesId'];

  List<_Option> _levelItems({
    required String level,
    required bool Function(BudgetModel e) test,
    required int Function(BudgetModel e) id,
    required String Function(BudgetModel e) name,
  }) {
    final seen = <int>{};
    return _budgetList.value
        .where((e) => e.levelType == level && test(e) && seen.add(id(e)))
        .map((e) => {"zAttributesId": id(e), "DisplayName": name(e)})
        .toList();
  }

  List<_Option> get _categoryList => _levelItems(
    level: 'L1',
    test: (_) => true,
    id: (e) => e.levelId1,
    name: (e) => e.level1Name,
  );

  List<_Option> get _subCategoryList =>
      _l1 == null
          ? []
          : _levelItems(
            level: 'L2',
            test: (e) => e.levelId1 == _l1,
            id: (e) => e.levelId2,
            name: (e) => e.level2Name,
          );

  List<_Option> get _descriptionList =>
      (_l1 == null || _l2 == null)
          ? []
          : _levelItems(
            level: 'L3',
            test: (e) => e.levelId1 == _l1 && e.levelId2 == _l2,
            id: (e) => e.levelId3,
            name: (e) => e.level3Name,
          );

  List<_Option> get _directSubMaterialList =>
      (_l1 == null || _l2 == null || _l3 == null)
          ? []
          : _levelItems(
            level: 'L4',
            test:
                (e) =>
                    e.levelId1 == _l1 && e.levelId2 == _l2 && e.levelId3 == _l3,
            id: (e) => e.levelId4,
            name: (e) => e.level4Name,
          );

  BudgetModel? get _selectedBudget {
    if (_l1 == null || _l2 == null || _l3 == null || _l4 == null) return null;
    for (final e in _budgetList.value) {
      if (e.levelType == 'L4' &&
          e.levelId1 == _l1 &&
          e.levelId2 == _l2 &&
          e.levelId3 == _l3 &&
          e.levelId4 == _l4) {
        return e;
      }
    }
    return null;
  }

  DateTime? get _directLeadDate {
    final item = _selectedBudget;
    return item == null ? null : _todayPlus(_toInt(item.level4LeadTimeInDays));
  }

  // SELECTING A LEVEL RESETS ALL LEVELS BELOW IT
  void _setCategory(_Option? value) {
    _category.value = value;
    _setSubCategory(null);
  }

  void _setSubCategory(_Option? value) {
    _subCategory.value = value;
    _setDescription(null);
  }

  void _setDescription(_Option? value) {
    _description.value = value;
    _setDirectSubMaterial(null);
  }

  void _setDirectSubMaterial(_Option? value) {
    _directSubMaterial.value = value;
    _directDate.value = _directLeadDate;
  }

  Future<void> _loadMasterList() async {
    DialogHelper.showProcessingOverlay(context);
    try {
      final result = await _utilsRepository
          .getMaterialMasterSubMaterialMasterUOMMaster(
            projectId: widget.projectId,
            queryParams: {
              "ClientRegistrationId": getCurrentUser().clientRegistrationId,
            },
          );

      await result.fold(
        (failure) async {
          if (mounted) showErrorMessage(context, 'Error', failure.message);
          _masterList.value = [];
        },
        (response) async {
          final data = response["MaterialMasterSubMaterialMasterData"];
          if (data == null) {
            _masterList.value = [];
            return;
          }

          final parsed = await compute(
            (m) =>
                (m as List<dynamic>)
                    .map((e) => SubMaterialMasterModel.fromJson(e))
                    .toList(),
            data,
          );
          _masterList.value = List<SubMaterialMasterModel>.from(parsed);
        },
      );
    } catch (e, st) {
      debugPrint('loadMasterList error: $e\n$st');
      _masterList.value = [];
    } finally {
      if (mounted) goRouter.pop();
    }
  }

  List<_Option> get _materialList {
    final seen = <dynamic>{};
    return _masterList.value
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

  List<_Option> get _subMaterialList {
    final materialId = _material.value?['zAttributesId'];
    if (materialId == null) return [];
    return _masterList.value
        .where((e) => e.materialMasterId == materialId)
        .map(
          (e) => {
            "zAttributesId": e.subMaterialMasterId,
            "DisplayName": e.subMaterialName,
          },
        )
        .toList();
  }

  SubMaterialMasterModel? get _selectedMaster {
    final id = _subMaterial.value?['zAttributesId'];
    if (id == null) return null;
    for (final e in _masterList.value) {
      if (e.subMaterialMasterId == id) return e;
    }
    return null;
  }

  DateTime? get _inDirectLeadDate {
    final item = _selectedMaster;
    return item == null ? null : _todayPlus(_toInt(item.leadTimeInDays));
  }

  void _setMaterial(_Option? value) {
    _material.value = value;
    _setSubMaterial(null);
  }

  void _setSubMaterial(_Option? value) {
    _subMaterial.value = value;
    _inDirectDate.value = _inDirectLeadDate;
  }

  void _submit() => _isInDirectTab ? _submitInDirect() : _submitDirect();

  void _submitInDirect() {
    if (!_inDirectFormKey.currentState!.validate()) return;
    final item = _selectedMaster;
    if (item == null) return;

    _saveMaterial(
      _buildMaterial(
        type: _inDirect,
        materialMasterId: item.materialMasterId,
        materialCode: _material.value?['Code'] ?? '',
        materialName: _material.value?['DisplayName'] ?? '',
        subMaterialName: _subMaterial.value?['DisplayName'] ?? '',
        subMaterialMasterId: item.subMaterialMasterId,
        uomMasterId: item.uomMasterId,
        uomCode: item.uomCode,
        uom: item.uom,
        requiredDate: _inDirectDate.value,
      ),
    );
  }

  void _submitDirect() {
    if (!_directFormKey.currentState!.validate()) return;
    final item = _selectedBudget;
    if (item == null) return;

    _saveMaterial(
      _buildMaterial(
        type: _direct,
        materialMasterId: 0, // MAP ACTUAL ID WHEN AVAILABLE
        materialCode: '',
        materialName: item.level4MaterialName,
        subMaterialName: item.level4Name,
        subMaterialMasterId: item.levelId4,
        uomMasterId: 0, // MAP ACTUAL ID WHEN AVAILABLE
        uomCode: item.level4SubMaterialUomCode,
        uom: item.level4SubMaterialUom,
        requiredDate: _directDate.value,
        budget: item,
      ),
    );
  }

  MaterialRequisitionDetailModel _buildMaterial({
    required String type,
    required int materialMasterId,
    required String materialCode,
    required String materialName,
    required String subMaterialName,
    required int subMaterialMasterId,
    required int uomMasterId,
    required String uomCode,
    required String uom,
    required DateTime? requiredDate,
    BudgetModel? budget,
  }) {
    final old = widget.materialDetails;
    // ONLY AN EDITED IN-DIRECT ROW KEEPS OLD APPROVAL STATUS AND MODIFIED INFO
    final keepOld = _isEditMode && type == _inDirect;

    return MaterialRequisitionDetailModel(
      materialRequisitionDetailId:
          _isEditMode ? old!.materialRequisitionDetailId : 0,
      uniquekey: _isEditMode ? old!.uniquekey : '',

      materialMasterId: materialMasterId,
      materialCode: materialCode,
      materialName: materialName,
      subMaterialName: subMaterialName,
      subMaterialMasterId: subMaterialMasterId,

      uomMasterId: uomMasterId,
      uomCode: uomCode,
      uom: uom,

      materialRequisitionType: type,

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
      approvalStatus: keepOld ? old!.approvalStatus : '',
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
      modifiedById: keepOld ? old!.modifiedById : 0,
      modifiedBy: keepOld ? old!.modifiedBy : '',
      modifiedDate: null,
    );
  }

  void _saveMaterial(MaterialRequisitionDetailModel material) {
    if (_isEditMode) {
      _cubit.updateMaterialList(material, widget.index);
    } else {
      _cubit.addMaterial(material);
    }
    goRouter.pop();
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
            tabs: _types,
            style: ChipTabBarStyle.segmented,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  _types
                      .map(
                        (t) => t == _inDirect ? _inDirectView() : _directView(),
                      )
                      .toList(),
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

  Widget _dropdown({
    required String title,
    required ValueNotifier<_Option?> selected,
    required List<_Option> Function() items,
    required void Function(_Option?) onChanged,
    ValueNotifier<_Option?>? parent,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge([if (parent != null) parent, selected]),
      builder: (context, _) {
        return CustomDropDownWidget(
          title: title,
          isRequired: true,
          hintText: "Select $title",
          initialValue: selected.value,
          dataList: items(),
          onValueClear: () => onChanged(null),
          onSelected: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) return "$title is required.";
            return null;
          },
        );
      },
    );
  }

  Widget _infoCard(
    Listenable listenable,
    bool Function() hasItem,
    List<_Option> Function() rows,
  ) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 100),
              alignment: Alignment.topCenter,
              child:
                  hasItem()
                      ? infoCard(rows())
                      : const SizedBox(width: double.infinity),
            ),
            verticalSpacing(),
          ],
        );
      },
    );
  }

  Widget _quantityField() {
    return CustomTextField(
      title: "Quantity",
      hint: "Enter Quantity",
      isRequired: true,
      inputFormatterList: InputValidator.decimal(2),
      keyboardType: TextInputType.numberWithOptions(),
      textController: _quantityC,
      validator: (value) {
        if (value == null || value == "") return "Quantity is required.";
        return null;
      },
    );
  }

  Widget _remarkField() {
    return CustomTextField(
      title: "Remark",
      hint: "Enter Remark",
      minLines: 3,
      maxLines: 10,
      textController: _remarkC,
    );
  }

  Widget _formCard({required Key formKey, required List<Widget> children}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Form(
        key: formKey,
        child: Container(
          decoration: commonCardDecoration(),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  // REBUILDS WHEN BUDGET LOADS SO DROPDOWNS FILL
  Widget _directView() {
    return ListenableBuilder(
      listenable: _budgetList,
      builder: (context, _) {
        return _formCard(
          formKey: _directFormKey,
          children: [
            _dropdown(
              title: "Category",
              selected: _category,
              items: () => _categoryList,
              onChanged: _setCategory,
            ),
            _dropdown(
              title: "Sub Category",
              parent: _category,
              selected: _subCategory,
              items: () => _subCategoryList,
              onChanged: _setSubCategory,
            ),
            _dropdown(
              title: "Description",
              parent: _subCategory,
              selected: _description,
              items: () => _descriptionList,
              onChanged: _setDescription,
            ),
            _dropdown(
              title: "Sub Material",
              parent: _description,
              selected: _directSubMaterial,
              items: () => _directSubMaterialList,
              onChanged: _setDirectSubMaterial,
            ),
            _infoCard(
              Listenable.merge([
                _category,
                _subCategory,
                _description,
                _directSubMaterial,
              ]),
              () => _selectedBudget != null,
              () {
                final item = _selectedBudget!;
                return [
                  {'title': 'Material Name', 'value': item.level4MaterialName},
                  {'title': 'Sub Material Name', 'value': item.level4Name},
                  {
                    'title': 'UOM',
                    'value':
                        '${item.level4SubMaterialUom} (${item.level4SubMaterialUomCode})',
                  },
                  {
                    'title': 'Material Rate',
                    'value': item.materialCost.toIndianCurrency(),
                  },
                  {
                    'title': 'Required Quantity',
                    'value': item.quantity.addCommas(),
                  },
                  {
                    'title': 'Order Quantity',
                    'value': item.orderQuantity.addCommas(),
                  },
                  {
                    'title': 'Received Quantity',
                    'value': item.receivedQuantity.addCommas(),
                  },
                  {
                    'title': 'Lead Time (Days)',
                    'value': item.level4LeadTimeInDays.addCommas(),
                  },
                  {
                    'title': 'Is Tolerant',
                    'value': _yesNo(item.level4IsTolerant),
                  },
                ];
              },
            ),
            _quantityField(),
            ValueListenableBuilder(
              valueListenable: _directDate,
              builder: (context, value, _) {
                return CustomDatePicker(
                  title: "Required Date",
                  initialDate: value,
                  isRequired: true,
                  readOnly: true,
                  startDate: _directLeadDate ?? DateTime.now(),
                  setValue: (value) => _directDate.value = value,
                );
              },
            ),
            _remarkField(),
          ],
        );
      },
    );
  }

  // REBUILDS WHEN MASTER LIST LOADS SO DROPDOWNS FILL
  Widget _inDirectView() {
    return ListenableBuilder(
      listenable: _masterList,
      builder: (context, _) {
        return _formCard(
          formKey: _inDirectFormKey,
          children: [
            _dropdown(
              title: "Material",
              selected: _material,
              items: () => _materialList,
              onChanged: _setMaterial,
            ),
            _dropdown(
              title: "Sub Material",
              parent: _material,
              selected: _subMaterial,
              items: () => _subMaterialList,
              onChanged: _setSubMaterial,
            ),
            _infoCard(
              Listenable.merge([_material, _subMaterial]),
              () => _selectedMaster != null,
              () {
                final item = _selectedMaster!;
                return [
                  {'title': 'UOM', 'value': item.uomCode},
                  {
                    'title': 'Lead Time (Days)',
                    'value': _toInt(item.leadTimeInDays).addCommas(),
                  },
                  {'title': 'Is Tolerant', 'value': _yesNo(item.isTolerant)},
                ];
              },
            ),
            ValueListenableBuilder(
              valueListenable: _inDirectDate,
              builder: (context, value, _) {
                return CustomDatePicker(
                  title: "Required Date",
                  initialDate: value,
                  isRequired: true,
                  readOnly: true,
                  startDate: _inDirectLeadDate ?? DateTime.now(),
                  setValue: (value) => _inDirectDate.value = value,
                  validator: (value) {
                    if (value == null) return 'Date is required.';
                    return null;
                  },
                );
              },
            ),
            _quantityField(),
            _remarkField(),
          ],
        );
      },
    );
  }
}
