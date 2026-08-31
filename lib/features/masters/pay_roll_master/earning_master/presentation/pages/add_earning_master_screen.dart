import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddEarningMasterScreen extends StatefulWidget {
  final EarningMasterModel? earningMasterModel;
  final int index;
  const AddEarningMasterScreen({
    super.key,
    this.earningMasterModel,
    this.index = 0,
  });

  @override
  State<AddEarningMasterScreen> createState() => _AddEarningMasterScreenState();
}

class _AddEarningMasterScreenState extends State<AddEarningMasterScreen> {
  // CUBIT
  late EarningMasterCubit _earningMasterCubit;

  // REPOSITORY
  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _valueC, _minSalaryC, _maxSalaryC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> selectedBranch = [];

  bool get _isEditMode => widget.earningMasterModel != null;
  // TYPES LIST
  List<Map<String, dynamic>> typesList = [
    {"DisplayName": "Basic Salary", "zAttributesId": 1},
    {"DisplayName": "HRA", "zAttributesId": 2},
    {"DisplayName": "DA", "zAttributesId": 3},

    {"DisplayName": "Conveyance Allowance", "zAttributesId": 4},
    {"DisplayName": "Medical Allowance", "zAttributesId": 5},
    {"DisplayName": "Special Allowance", "zAttributesId": 6},
    {"DisplayName": "Other Allowance", "zAttributesId": 7},
    {"DisplayName": "LTA", "zAttributesId": 8},

    {"DisplayName": "Performance Bonus", "zAttributesId": 9},
    {"DisplayName": "Incentive", "zAttributesId": 10},
    {"DisplayName": "Variable Pay", "zAttributesId": 11},
    {"DisplayName": "Annual Bonus", "zAttributesId": 12},
    {"DisplayName": "Joining Bonus", "zAttributesId": 13},
    {"DisplayName": "Retention Bonus", "zAttributesId": 14},
    {"DisplayName": "Mobile Reimbursement", "zAttributesId": 15},
    {"DisplayName": "Internet Reimbursement", "zAttributesId": 16},
    {"DisplayName": "Fuel Reimbursement", "zAttributesId": 17},
    {"DisplayName": "Food Allowance", "zAttributesId": 18},
    {"DisplayName": "Shift Allowance", "zAttributesId": 19},
    {"DisplayName": "Night Shift Allowance", "zAttributesId": 20},
    {"DisplayName": "City Compensatory Allowance", "zAttributesId": 21},
    {"DisplayName": "Employer PF", "zAttributesId": 22},
    {"DisplayName": "Employer ESI", "zAttributesId": 23},
    {"DisplayName": "Gratuity", "zAttributesId": 24},
    {"DisplayName": "Superannuation", "zAttributesId": 25},
    {"DisplayName": "NPS Employer", "zAttributesId": 26},
    {"DisplayName": "Health Insurance", "zAttributesId": 27},
    {"DisplayName": "Overtime Pay", "zAttributesId": 28},
    {"DisplayName": "Leave Encashment", "zAttributesId": 29},
    {"DisplayName": "Arrears", "zAttributesId": 30},
    {"DisplayName": "Ex-Gratia", "zAttributesId": 31},
    {"DisplayName": "Relocation Allowance", "zAttributesId": 32},
  ];
  // NAME LIST
  List<Map<String, dynamic>> nameList = [
    {"DisplayName": "Basic Salary", "zAttributesId": 1},
    {"DisplayName": "HRA", "zAttributesId": 2},
    {"DisplayName": "DA", "zAttributesId": 3},

    {"DisplayName": "Conveyance Allowance", "zAttributesId": 4},
    {"DisplayName": "Medical Allowance", "zAttributesId": 5},
    {"DisplayName": "Special Allowance", "zAttributesId": 6},
    {"DisplayName": "Other Allowance", "zAttributesId": 7},
    {"DisplayName": "LTA", "zAttributesId": 8},

    {"DisplayName": "Performance Bonus", "zAttributesId": 9},
    {"DisplayName": "Incentive", "zAttributesId": 10},
    {"DisplayName": "Variable Pay", "zAttributesId": 11},
    {"DisplayName": "Annual Bonus", "zAttributesId": 12},
    {"DisplayName": "Joining Bonus", "zAttributesId": 13},
    {"DisplayName": "Retention Bonus", "zAttributesId": 14},
    {"DisplayName": "Mobile Reimbursement", "zAttributesId": 15},
    {"DisplayName": "Internet Reimbursement", "zAttributesId": 16},
    {"DisplayName": "Fuel Reimbursement", "zAttributesId": 17},
    {"DisplayName": "Food Allowance", "zAttributesId": 18},
    {"DisplayName": "Shift Allowance", "zAttributesId": 19},
    {"DisplayName": "Night Shift Allowance", "zAttributesId": 20},
    {"DisplayName": "City Compensatory Allowance", "zAttributesId": 21},
    {"DisplayName": "Employer PF", "zAttributesId": 22},
    {"DisplayName": "Employer ESI", "zAttributesId": 23},
    {"DisplayName": "Gratuity", "zAttributesId": 24},
    {"DisplayName": "Superannuation", "zAttributesId": 25},
    {"DisplayName": "NPS Employer", "zAttributesId": 26},
    {"DisplayName": "Health Insurance", "zAttributesId": 27},
    {"DisplayName": "Overtime Pay", "zAttributesId": 28},
    {"DisplayName": "Leave Encashment", "zAttributesId": 29},
    {"DisplayName": "Arrears", "zAttributesId": 30},
    {"DisplayName": "Ex-Gratia", "zAttributesId": 31},
    {"DisplayName": "Relocation Allowance", "zAttributesId": 32},
  ];

  // SELECTED VALUES
  List<Map<String, dynamic>> selectedNameList = [];
  List<Map<String, dynamic>> selectedTypeList = [];

  late ValueNotifier<String> applicableType;

  @override
  void initState() {
    super.initState();
    _earningMasterCubit = context.read<EarningMasterCubit>();
    _initializeTextEditingController();
    if (_isEditMode && widget.earningMasterModel != null) {
      final model = widget.earningMasterModel!;
      final isPercentage = model.applicable == "Percentage";
      applicableType = ValueNotifier(isPercentage ? "Percentage" : "Lumpsum");
      _populateFormFields(model);
    } else {
      applicableType = ValueNotifier("Percentage");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _valueC.dispose();
    _minSalaryC.dispose();
    _maxSalaryC.dispose();
    applicableType.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _valueC = TextEditingController();
    _minSalaryC = TextEditingController();
    _maxSalaryC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(EarningMasterModel earningMasterModel) {
    selectedNameList = [
      nameList.firstWhere(
        (item) => item['DisplayName'] == earningMasterModel.name,
        orElse: () => nameList.first,
      ),
    ];
    selectedTypeList = [
      typesList.firstWhere(
        (item) => item['DisplayName'] == earningMasterModel.type,
        orElse: () => typesList.first,
      ),
    ];
    _valueC.text = earningMasterModel.value.toString();
    if (earningMasterModel.branchName.isNotEmpty) {
      selectedBranch = [
        {
          'zAttributesId': earningMasterModel.branchMasterId,
          'DisplayName': earningMasterModel.branchName,
        },
      ];
    }
    _minSalaryC.text = earningMasterModel.minSalary.toString();
    _maxSalaryC.text = earningMasterModel.maxSalary.toString();
    applicableType.value = earningMasterModel.applicable;
  }

  Future<Map<String, dynamic>> _fetchBranch(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _branchMasterRepository.getBranchList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"BranchName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final branches = response['data'] as List<BranchMasterModel>;

        return {
          "itemList":
              branches.map((employee) {
                return {
                  "zAttributesId": employee.branchMasterId,
                  "DisplayName": employee.branchName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH STATIC EARNING NAMES
  Future<Map<String, dynamic>> _fetchStaticDeductionNames(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? nameList
            : nameList
                .where(
                  (e) => e["DisplayName"].toString().toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {
      "itemList": filteredList,
      "totalNumberOfRecord": filteredList.length,
    };
  }

  // FETCH STATIC EARNING TYPES
  Future<Map<String, dynamic>> _fetchStaticDeductionTypes(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? typesList
            : typesList
                .where(
                  (e) => e["DisplayName"].toString().toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {
      "itemList": filteredList,
      "totalNumberOfRecord": filteredList.length,
    };
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? typeValue =
        selectedTypeList.isNotEmpty
            ? selectedTypeList.first['DisplayName'].toString()
            : null;

    final int? branchId =
        (selectedBranch.isNotEmpty)
            ? selectedBranch.first['zAttributesId'] as int
            : null;

    if (_isEditMode && widget.earningMasterModel != null) {
      _earningMasterCubit.updateEarning(
        index: widget.index,
        context: context,
        earningMasterId: widget.earningMasterModel!.earningMasterId,
        branchMasterId: branchId,
        uniqueKey: widget.earningMasterModel!.uniquekey,
        earningName: selectedNameList.first['DisplayName'].toString(),
        earningType: typeValue ?? "",
        earningApplicable: applicableType.value,
        value: double.parse(_valueC.text.trim()),
        minSalary: double.parse(_minSalaryC.text.trim()),
        maxSalary: double.parse(_maxSalaryC.text.trim()),
      );
    } else {
      _earningMasterCubit.addEarning(
        context: context,
        branchMasterId: branchId,
        earningName: selectedNameList.first['DisplayName'].toString(),
        earningType: typeValue ?? "",
        earningApplicable: applicableType.value,
        value: double.parse(_valueC.text.trim()),
        minSalary: double.parse(_minSalaryC.text.trim()),
        maxSalary: double.parse(_maxSalaryC.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Earning",
        authorization: AuthorizationModel(),
      ),
      body: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? "Update Earning" : 'Add Earning',
                    style: AppTextStyle.ts16SB(),
                  ),
                  verticalSpacing(),
                  Container(
                    decoration: commonCardDecoration(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomMultipleSelectPopup(
                          initialValue: selectedNameList,
                          title: "Name",
                          hintText: "Select Name",
                          isRequired: true,
                          dataFetchCallBack: _fetchStaticDeductionNames,
                          isMultiSelect: false,
                          dataList: nameList,
                          onSelected: (value) {
                            setState(() {
                              selectedNameList = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        CustomMultipleSelectPopup(
                          initialValue: selectedTypeList,
                          title: "Type",
                          hintText: "Select Type",
                          isRequired: false,
                          dataFetchCallBack: _fetchStaticDeductionTypes,
                          isMultiSelect: false,
                          dataList: typesList,
                          onSelected: (value) {
                            setState(() {
                              selectedTypeList = value;
                            });
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Applicable",
                                  style: AppTextStyle.ts14R(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  "*",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.error,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            ValueListenableBuilder<String>(
                              valueListenable: applicableType,
                              builder: (context, value, _) {
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        applicableType.value = "Percentage";
                                        _valueC.clear();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          color:
                                              value == "Percentage"
                                                  ? AppColor.lightBlue
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color: AppColor.grey,
                                            width: .5,
                                          ),
                                        ),
                                        child: Text(
                                          "Percentage",
                                          style: AppTextStyle.ts12R(
                                            color:
                                                value == "Percentage"
                                                    ? AppColor.primary
                                                    : AppColor.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        applicableType.value = "Lumpsum";
                                        _valueC.clear();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          color:
                                              value == "Lumpsum"
                                                  ? AppColor.lightBlue
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color: AppColor.grey,
                                            width: .5,
                                          ),
                                        ),
                                        child: Text(
                                          "Lumpsum",
                                          style: AppTextStyle.ts12R(
                                            color:
                                                value == "Lumpsum"
                                                    ? AppColor.primary
                                                    : AppColor.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder<String>(
                          valueListenable: applicableType,
                          builder: (context, value, _) {
                            return CustomTextField(
                              textController: _valueC,
                              hint:
                                  value == "Percentage"
                                      ? "Enter Percentage"
                                      : "Enter Amount",
                              title:
                                  value == "Percentage"
                                      ? "Value"
                                      : "Value (Lumpsum)",
                              keyboardType: TextInputType.number,
                              prefixType:
                                  value == "Percentage"
                                      ? CustomTextFieldPrefix.percentage
                                      : CustomTextFieldPrefix.rupees,
                              isRequired: true,
                              inputFormatterList:
                                  value == "Percentage"
                                      ? [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                        LengthLimitingTextInputFormatter(5),
                                      ]
                                      : [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                              validator: (valueText) {
                                if (valueText == null ||
                                    valueText.trim().isEmpty) {
                                  return "Value is required";
                                }

                                if (value == "Percentage") {
                                  final val = double.tryParse(valueText) ?? 0;
                                  if (val > 100) {
                                    return "Percentage cannot exceed 100";
                                  }
                                }

                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          textController: _minSalaryC,
                          title: "Min Salary",
                          hint: "Enter Min Salary",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          validator: (p0) {
                            if (_minSalaryC.text.isEmpty) {
                              return 'Min Salary is required';
                            }
                            return null;
                          },
                          inputFormatterList: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        CustomTextField(
                          textController: _maxSalaryC,
                          title: "Max Salary",
                          hint: "Enter Max Salary",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          validator: (p0) {
                            if (_maxSalaryC.text.isEmpty) {
                              return 'Max Salary is required';
                            }
                            return null;
                          },
                          inputFormatterList: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),

                        CustomMultipleSelectPopup(
                          title: 'Branch',
                          hintText: "Select Branch",
                          isMultiSelect: false,
                          initialValue: selectedBranch,
                          dataList: [],
                          onSelected: (value) {
                            innerState(() {
                              selectedBranch = value;
                            });
                          },
                          dataFetchCallBack: _fetchBranch,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: commonCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
