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
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  late final ValueNotifier<DateTime?> _assignedDateNotifier;
  late final ValueNotifier<DateTime?> _returnDateNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedAssetNotifier;
  late final ValueNotifier<bool> _isInactiveNotifier;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  bool get _isEditMode => widget.assetMapping != null;

  @override
  void initState() {
    super.initState();
    _assetMappingMasterCubit = context.read<AssetMappingMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _initializeTextEditingControllers();

    _assignedDateNotifier = ValueNotifier<DateTime?>(null);
    _returnDateNotifier = ValueNotifier<DateTime?>(null);
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedAssetNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _isInactiveNotifier = ValueNotifier<bool>(false);

    if (_isEditMode && widget.assetMapping != null) {
      _populateFormFields(widget.assetMapping!);
    }
  }

  @override
  void dispose() {
    _assignedDateNotifier.dispose();
    _returnDateNotifier.dispose();
    _selectedEmployeeNotifier.dispose();
    _selectedAssetNotifier.dispose();
    _isInactiveNotifier.dispose();
    _disposeTextEditingControllers();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _conditionOnIssueC = TextEditingController();
    _conditionOnReturnC = TextEditingController();
    _remarksC = TextEditingController();
  }

  // DISPOSE TEXT EDITING CONTROLLERS
  void _disposeTextEditingControllers() {
    _conditionOnIssueC.dispose();
    _conditionOnReturnC.dispose();
    _remarksC.dispose();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(AssetMappingModel assetMapping) {
    _selectedEmployeeNotifier.value = [
      {
        'zAttributesId': assetMapping.employeeId,
        'DisplayName': assetMapping.employeeName,
      },
    ];
    _selectedAssetNotifier.value = [
      {
        'zAttributesId': assetMapping.assetMasterId,
        'DisplayName': assetMapping.assetName,
        'assetCode': assetMapping.assetCode,
        'assetModel': assetMapping.assetModel,
        'assetType': assetMapping.assetType,
        'assetBrand': assetMapping.assetBrand,
        'serialNumber': assetMapping.serialNumber,
        'purchaseDate': assetMapping.purchaseDate,
      },
    ];
    _assignedDateNotifier.value = assetMapping.assignedDate;
    _returnDateNotifier.value = assetMapping.returnDate;
    _conditionOnIssueC.text = assetMapping.conditionOnIssue;
    _conditionOnReturnC.text = assetMapping.conditionOnReturn;
    _remarksC.text = assetMapping.remarks;

    _fetchEmployeeDetailsForEdit(assetMapping.employeeId);
  }

  // FETCH EMPLOYEE
  Future<void> _fetchEmployeeDetailsForEdit(int employeeId) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {'EmployeeId': employeeId},
    );
    result.fold((_) {}, (response) {
      final employees = response['data'] as List<UserModel>? ?? [];
      if (employees.isEmpty) return;
      final employee = employees.first;
      if (!mounted) return;
      _selectedEmployeeNotifier.value = [
        {
          'zAttributesId': employee.employeeId,
          'DisplayName': employee.fullName,
          'employeeCode': employee.employeeCode,
          'department': employee.department,
          'designation': employee.designation,
          'branch': employee.branch,
          'reportingPerson': employee.reportPersonName,
          'email': employee.emailId,
          'personalNumber': employee.personalMobileNumber,
          "joiningDate": employee.joiningDate,
        },
      ];
    });
  }

  // FETCH EMPLOYEES
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "IsCheckPermission": false}
              : {"IsCheckPermission": false},
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
                  "department": employee.department,
                  "designation": employee.designation,
                  "branch": employee.branch,
                  "reportingPerson": employee.reportPersonName,
                  "email": employee.emailId,
                  "personalNumber": employee.personalMobileNumber,
                  "joiningDate": employee.joiningDate,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH ASSETS
  Future<Map<String, dynamic>> _fetchAssets(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _assetMasterRepository.getAssetList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"AssetName": value, "Status": "Available"}
              : {"Status": "Available"},
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
                  "DisplayName": asset.assetName,
                  "assetCode": asset.assetCode,
                  "assetModel": asset.assetModel,
                  "assetType": asset.assetType,
                  "assetBrand": asset.assetBrand,
                  "serialNumber": asset.serialNumber,
                  "purchaseDate": asset.purchaseDate,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedEmployee = _selectedEmployeeNotifier.value;
    final selectedAsset = _selectedAssetNotifier.value;
    final assignedDate = _assignedDateNotifier.value;
    final isInactive = _isInactiveNotifier.value;

    final returnDate = isInactive ? _returnDateNotifier.value : null;
    final conditionOnReturn = isInactive ? _conditionOnReturnC.text.trim() : '';

    if (selectedEmployee.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an employee');
      return;
    }

    if (selectedAsset.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an asset');
      return;
    }

    if (assignedDate == null) {
      showErrorMessage(context, 'Error', 'Assigned Date is required');
      return;
    }

    if (isInactive && returnDate == null) {
      showErrorMessage(context, 'Error', 'Return Date is required');
      return;
    }

    if (_isEditMode && widget.assetMapping != null) {
      _assetMappingMasterCubit.updateAssetMapping(
        index: widget.index,
        context: context,
        assetMasterMappingId: widget.assetMapping!.assetMasterMappingId,
        uniqueKey: widget.assetMapping!.uniquekey,
        employeeId: selectedEmployee.first['zAttributesId'] as int,
        assetMasterId: selectedAsset.first['zAttributesId'] as int,
        assignedDate: assignedDate,
        returnDate: returnDate,
        conditionOnIssue: _conditionOnIssueC.text.trim(),
        conditionOnReturn: conditionOnReturn,
        remarks: _remarksC.text.trim(),
      );
    } else {
      _assetMappingMasterCubit.addAssetMapping(
        context: context,
        employeeId: selectedEmployee.first['zAttributesId'] as int,
        assetMasterId: selectedAsset.first['zAttributesId'] as int,
        assignedDate: assignedDate,
        conditionOnIssue: _conditionOnIssueC.text.trim(),
        remarks: _remarksC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Asset Mapping Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Asset Mapping" : "Add Asset Mapping",
                style: AppTextStyle.ts16M(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ASSET SELECT
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedAssetNotifier,
                      builder: (context, selectedAsset, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Asset',
                              hintText: "Select Asset",
                              isReadOnly:
                                  _isEditMode
                                      ? !(widget
                                              .assetMapping
                                              ?.isEditAllowedForAssetAndEmployee ??
                                          false)
                                      : false,
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedAsset,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedAssetNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchAssets,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Asset is required";
                                }
                                return null;
                              },
                            ),
                            if (selectedAsset.isNotEmpty) ...[
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColor.lightBlue),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Asset Code",
                                          value:
                                              selectedAsset
                                                  .first["assetCode"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Asset Name",
                                          value:
                                              selectedAsset
                                                  .first["DisplayName"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Asset Type",
                                          value:
                                              selectedAsset
                                                  .first["assetType"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Asset Model",
                                          value:
                                              selectedAsset
                                                  .first["assetModel"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Asset Brand",
                                          value:
                                              selectedAsset
                                                  .first["assetBrand"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Serial Number",
                                          value:
                                              selectedAsset
                                                  .first["serialNumber"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Purchase Date",
                                          value:
                                              selectedAsset
                                                          .first["purchaseDate"] !=
                                                      null
                                                  ? formatDateTimeAsDDMMMYYYY(
                                                    selectedAsset
                                                        .first["purchaseDate"],
                                                  )
                                                  : "-",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    // EMPLOYEE SELECT + CARD
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedEmployeeNotifier,
                      builder: (context, selectedEmployee, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Employee',
                              hintText: "Select Employee",
                              isReadOnly:
                                  _isEditMode
                                      ? !(widget
                                              .assetMapping
                                              ?.isEditAllowedForAssetAndEmployee ??
                                          false)
                                      : false,
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedEmployee,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedEmployeeNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchEmployees,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Employee Name is required";
                                }
                                return null;
                              },
                            ),
                            if (selectedEmployee.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColor.lightBlue),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Department",
                                          value:
                                              selectedEmployee
                                                  .first["department"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Designation",
                                          value:
                                              selectedEmployee
                                                  .first["designation"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Branch",
                                          value:
                                              selectedEmployee
                                                  .first["branch"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Reporting Person",
                                          value:
                                              selectedEmployee
                                                  .first["reportingPerson"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Email Id",
                                          value:
                                              selectedEmployee.first["email"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Personal Mobile Number",
                                          value:
                                              selectedEmployee
                                                  .first["personalNumber"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Joining Date",
                                          value:
                                              selectedEmployee
                                                          .first["joiningDate"] !=
                                                      null
                                                  ? formatDateTimeAsDDMMMYYYY(
                                                    selectedEmployee
                                                        .first["joiningDate"],
                                                  )
                                                  : "-",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    // ASSIGNED DATE
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: _assignedDateNotifier,
                      builder: (context, assignedDate, _) {
                        return CustomDatePicker(
                          title: 'Assigned Date',
                          initialDate: assignedDate,
                          isRequired: true,
                          setValue: (date) {
                            _assignedDateNotifier.value = date;
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Assigned Date is required";
                            }
                            // CHECK JOINING DATE
                            if (_selectedEmployeeNotifier.value.isNotEmpty) {
                              final joiningDate =
                                  _selectedEmployeeNotifier
                                      .value
                                      .first["joiningDate"];

                              if (value.isBefore(joiningDate)) {
                                return "Assigned Date must be greater than or equal to Joining Date";
                              }
                            }

                            // CHECK PURCHASE DATE
                            if (_selectedAssetNotifier.value.isNotEmpty) {
                              final purchaseDate =
                                  _selectedAssetNotifier
                                      .value
                                      .first["purchaseDate"];

                              if (value.isBefore(purchaseDate)) {
                                return "Assigned Date must be greater than or equal to Purchase Date";
                              }
                            }

                            return null;
                          },
                        );
                      },
                    ),

                    // CONDITION ON ISSUE
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

                    // REMARKS
                    CustomTextField(
                      title: 'Remarks',
                      textController: _remarksC,
                      hint: "Enter Remarks",
                      inputFormatterList: InputValidator.textOnly(500),
                      minLines: 3,
                      maxLines: 3,
                    ),

                    verticalSpacing(),

                    // RETURN SECTION (EDIT MODE ONLY)
                    if (_isEditMode)
                      ValueListenableBuilder<bool>(
                        valueListenable: _isInactiveNotifier,
                        builder: (context, isInactive, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  CustomCheckBox(
                                    isSelected: isInactive,
                                    onChanged: (value) {
                                      _isInactiveNotifier.value = value;

                                      if (!(value)) {
                                        _returnDateNotifier.value = null;
                                        _conditionOnReturnC.clear();
                                      }
                                    },
                                  ),
                                  Text(
                                    "Do you want to return the asset?",
                                    style: AppTextStyle.ts14M(),
                                  ),
                                ],
                              ),

                              if (isInactive) ...[
                                verticalSpacing(),
                                CustomTextField(
                                  title: 'Condition on Return',
                                  isRequired: true,
                                  textController: _conditionOnReturnC,
                                  hint: "Enter Condition on Return",
                                  inputFormatterList: InputValidator.textOnly(
                                    200,
                                  ),
                                  validator: (value) {
                                    if ((value == null ||
                                            value.trim().isEmpty) &&
                                        isInactive) {
                                      return "Condition on Return is required";
                                    }
                                    return null;
                                  },
                                ),
                                ValueListenableBuilder<DateTime?>(
                                  valueListenable: _returnDateNotifier,
                                  builder: (context, returnDate, __) {
                                    return ValueListenableBuilder<DateTime?>(
                                      valueListenable: _assignedDateNotifier,
                                      builder: (context, assignedDate, ___) {
                                        return CustomDatePicker(
                                          title: 'Return Date',
                                          isRequired: true,
                                          initialDate: returnDate,
                                          startDate: assignedDate,
                                          setValue: (date) {
                                            _returnDateNotifier.value = date;
                                          },
                                          validator: (value) {
                                            if (value == null && isInactive) {
                                              return "Return Date is required";
                                            }
                                            if (assignedDate != null &&
                                                isInactive &&
                                                value != null &&
                                                value.isBefore(assignedDate)) {
                                              return "Return Date must be after Assigned Date";
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Expanded(
                child: CustomButton(
                  leading: Icon(
                    _isEditMode ? Icons.edit : Icons.add,
                    size: 18,
                    color: AppColor.white,
                  ),
                  text: _isEditMode ? "Update" : "Add",
                  onPressed: _saveForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
