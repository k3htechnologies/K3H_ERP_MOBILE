import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/repository/asset_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';

class AddAssetMappingMasterScreen extends StatefulWidget {
  final AssetMappingModel? assetMapping;
  final int index;
  const AddAssetMappingMasterScreen({
    super.key,
    this.assetMapping,
    this.index = 0,
  });

  @override
  State<AddAssetMappingMasterScreen> createState() =>
      _AddAssetMappingMasterScreenState();
}

class _AddAssetMappingMasterScreenState
    extends State<AddAssetMappingMasterScreen> {
  // CUBIT
  late AssetMappingMasterCubit _assetMappingMasterCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final AssetMasterRepository _assetMasterRepository =
      serviceLocator<AssetMasterRepository>();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _conditionOnIssueC;
  late TextEditingController _conditionOnReturnC;
  late TextEditingController _remarksC;

  // DATE PICKERS
  DateTime? _assignedDate;
  DateTime? _returnDate;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedEmployee = [];
  List<Map<String, dynamic>> _selectedAsset = [];

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  bool get _isEditMode => widget.assetMapping != null;

  @override
  void initState() {
    super.initState();
    _assetMappingMasterCubit = context.read<AssetMappingMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _initializeTextEditingControllers();
    if (_isEditMode && widget.assetMapping != null) {
      _populateFormFields(widget.assetMapping!);
    }
  }

  @override
  void dispose() {
    _disposeTextEditingControllers();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _conditionOnIssueC = TextEditingController();
    _conditionOnReturnC = TextEditingController();
    _remarksC = TextEditingController();
  }

  void _disposeTextEditingControllers() {
    _conditionOnIssueC.dispose();
    _conditionOnReturnC.dispose();
    _remarksC.dispose();
  }

  void _populateFormFields(AssetMappingModel assetMapping) {
    _selectedEmployee = [
      {
        'zAttributesId': assetMapping.employeeId,
        'DisplayName': assetMapping.employeeName,
      },
    ];
    _selectedAsset = [
      {
        'zAttributesId': assetMapping.assetMasterId,
        'DisplayName': assetMapping.assetName,
      },
    ];
    _assignedDate = assetMapping.assignedDate;
    _returnDate = assetMapping.returnDate;
    _conditionOnIssueC.text = assetMapping.conditionOnIssue;
    _conditionOnReturnC.text = assetMapping.conditionOnReturn;
    _remarksC.text = assetMapping.remarks;
  }

  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"EmployeeName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<Map<String, dynamic>> _fetchAssets(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _assetMasterRepository.getAssetList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"AssetName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final assets = response['data'] as List<AssetMasterModel>;

        return {
          "itemList":
              assets.map((asset) {
                return {
                  "zAttributesId": asset.assetMasterId,
                  "DisplayName": "${asset.assetName} (${asset.assetCode})",
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployee.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an employee');
      return;
    }

    if (_selectedAsset.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an asset');
      return;
    }

    if (_assignedDate == null) {
      showErrorMessage(context, 'Error', 'Assigned Date is required');
      return;
    }

    if (_returnDate == null) {
      showErrorMessage(context, 'Error', 'Return Date is required');
      return;
    }

    if (_isEditMode && widget.assetMapping != null) {
      _assetMappingMasterCubit.updateAssetMapping(
        index: widget.index,
        context: context,
        assetMasterMappingId: widget.assetMapping!.assetMasterMappingId,
        uniqueKey: widget.assetMapping!.uniquekey,
        employeeId: _selectedEmployee.first['zAttributesId'] as int,
        assetMasterId: _selectedAsset.first['zAttributesId'] as int,
        assignedDate: _assignedDate!,
        returnDate: _returnDate!,
        conditionOnIssue: _conditionOnIssueC.text.trim(),
        conditionOnReturn: _conditionOnReturnC.text.trim(),
        remarks: _remarksC.text.trim(),
      );
    } else {
      _assetMappingMasterCubit.addAssetMapping(
        context: context,
        employeeId: _selectedEmployee.first['zAttributesId'] as int,
        assetMasterId: _selectedAsset.first['zAttributesId'] as int,
        assignedDate: _assignedDate!,
        returnDate: _returnDate!,
        conditionOnIssue: _conditionOnIssueC.text.trim(),
        conditionOnReturn: _conditionOnReturnC.text.trim(),
        remarks: _remarksC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Asset Mapping" : "Add Asset Mapping",
        authorization: _routeAuthorizationModel,
      ),
      body: StatefulBuilder(
        builder: (context, setStateBuilder) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomMultipleSelectPopup(
                    title: 'Employee',
                    isRequired: true,
                    isMultiSelect: false,
                    initialValue: _selectedEmployee,
                    dataList: [],
                    onSelected: (value) {
                      setStateBuilder(() {
                        _selectedEmployee = value;
                      });
                    },
                    dataFetchCallBack: _fetchEmployees,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Employee is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomMultipleSelectPopup(
                    title: 'Asset',
                    isRequired: true,
                    isMultiSelect: false,
                    initialValue: _selectedAsset,
                    dataList: [],
                    onSelected: (value) {
                      setStateBuilder(() {
                        _selectedAsset = value;
                      });
                    },
                    dataFetchCallBack: _fetchAssets,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Asset is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomDatePicker(
                    title: 'Assigned Date',
                    initialDate: _assignedDate,
                    isRequired: true,
                    setValue: (date) {
                      setStateBuilder(() {
                        _assignedDate = date;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Assigned Date is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomDatePicker(
                    title: 'Return Date',
                    initialDate: _returnDate,
                    startDate: _assignedDate,
                    isRequired: true,
                    setValue: (date) {
                      setStateBuilder(() {
                        _returnDate = date;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Return Date is required";
                      }
                      if (_assignedDate != null &&
                          value.isBefore(_assignedDate!)) {
                        return "Return Date must be after Assigned Date";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomTextField(
                    title: 'Condition on Issue',
                    textController: _conditionOnIssueC,
                    hint: "Enter Condition on Issue",
                    inputFormatterList: InputValidator.textOnly(200),
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Condition on Issue is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomTextField(
                    title: 'Condition on Return',
                    textController: _conditionOnReturnC,
                    hint: "Enter Condition on Return",
                    inputFormatterList: InputValidator.textOnly(200),
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Condition on Return is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                  CustomTextField(
                    title: 'Remarks',
                    textController: _remarksC,
                    isRequired: true,
                    hint: "Enter Remarks",
                    inputFormatterList: InputValidator.textOnly(500),
                    minLines: 3,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Remarks is required";
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Asset Mapping" : "Add Asset Mapping",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
