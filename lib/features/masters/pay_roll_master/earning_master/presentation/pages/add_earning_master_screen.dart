import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
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
  late TextEditingController _nameC, _typeC, _valueC, _minSalaryC, _maxSalaryC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedBranch = [];

  bool get _isEditMode => widget.earningMasterModel != null;

  @override
  void initState() {
    super.initState();
    _earningMasterCubit = context.read<EarningMasterCubit>();
    _initializeTextEditingController();
    if (_isEditMode && widget.earningMasterModel != null) {
      _populateFormFields(widget.earningMasterModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameC.dispose();
    _typeC.dispose();
    _valueC.dispose();
    _minSalaryC.dispose();
    _maxSalaryC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _nameC = TextEditingController();
    _typeC = TextEditingController();
    _valueC = TextEditingController();
    _minSalaryC = TextEditingController();
    _maxSalaryC = TextEditingController();
  }

  void _populateFormFields(EarningMasterModel earningMasterModel) {
    _nameC.text = earningMasterModel.name;
    _typeC.text = earningMasterModel.type;
    _valueC.text = earningMasterModel.value.toString();
    _selectedBranch = [
      {
        'zAttributesId': earningMasterModel.branchMasterId,
        'DisplayName': earningMasterModel.branchName,
      },
    ];
    _minSalaryC.text = earningMasterModel.minSalary.toString();
    _maxSalaryC.text = earningMasterModel.maxSalary.toString();
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode && widget.earningMasterModel != null) {
      _earningMasterCubit.updateEarning(
        index: widget.index,
        context: context,
        earningMasterId: widget.earningMasterModel!.earningMasterId,
        branchMasterId: _selectedBranch.first["zAttributesId"],
        uniqueKey: widget.earningMasterModel!.uniquekey,
        earningName: _nameC.text.trim(),
        earningType: _typeC.text.trim(),
        value: double.parse(_valueC.text.trim()),
        minSalary: double.parse(_minSalaryC.text.trim()),
        maxSalary: double.parse(_maxSalaryC.text.trim()),
      );
    } else {
      _earningMasterCubit.addEarning(
        context: context,
        branchMasterId: 0,
        earningName: _nameC.text.trim(),
        earningType: _typeC.text.trim(),
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
                        CustomTextField(
                          textController: _nameC,
                          title: "Earning Name",
                          hint: "Enter Earning Name",
                          isRequired: true,
                          inputFormatterList: InputValidator.textDigit(200),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Earning Name is required";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          textController: _typeC,
                          title: "Type",
                          hint: "Enter Earning Type",
                          isRequired: true,
                          inputFormatterList: InputValidator.textDigit(200),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Earning Type is required";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          textController: _valueC,
                          title: "Value",
                          hint: "Enter Earning Value",
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.decimal(10),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Earning Value is required";
                            }
                            return null;
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
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: _selectedBranch,
                          dataList: [],
                          onSelected: (value) {
                            innerState(() {
                              _selectedBranch = value;
                            });
                          },
                          dataFetchCallBack: _fetchBranch,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Branch is required";
                            }
                            return null;
                          },
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
            text: _isEditMode ? "Update Earning" : "Add Earning",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
