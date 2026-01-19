import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

class AddBranchAssociationMasterScreen extends StatefulWidget {
  final BranchAssociationModel? branchAssociation;
  final int index;
  const AddBranchAssociationMasterScreen({
    super.key,
    this.branchAssociation,
    this.index = 0,
  });

  @override
  State<AddBranchAssociationMasterScreen> createState() =>
      _AddBranchAssociationMasterScreenState();
}

class _AddBranchAssociationMasterScreenState
    extends State<AddBranchAssociationMasterScreen> {
  // CUBIT
  late BranchAssociationMasterCubit _branchAssociationMasterCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedEmployee = [];
  List<Map<String, dynamic>> _selectedBranch = [];

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  bool get _isEditMode => widget.branchAssociation != null;

  @override
  void initState() {
    super.initState();
    _branchAssociationMasterCubit =
        context.read<BranchAssociationMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    if (_isEditMode && widget.branchAssociation != null) {
      _populateFormFields(widget.branchAssociation!);
    }
  }

  void _populateFormFields(BranchAssociationModel branchAssociation) {
    _selectedEmployee = [
      {
        'zAttributesId': branchAssociation.employeeId,
        'DisplayName': branchAssociation.employeeName,
      },
    ];
    _selectedBranch = [
      {
        'zAttributesId': int.parse(branchAssociation.branchMasterId),
        'DisplayName': branchAssociation.branchName,
      },
    ];
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.branchAssociation != null) {
      _branchAssociationMasterCubit.updateBranchAssociation(
        index: widget.index,
        context: context,
        branchAssociationsId: widget.branchAssociation!.branchAssociationsId,
        employeeId: _selectedEmployee.first['zAttributesId'],
        branchMasterId: int.parse(
          _selectedBranch.first['zAttributesId'].toString(),
        ),
        uniqueKey: widget.branchAssociation!.uniquekey,
      );
    } else {
      _branchAssociationMasterCubit.addBranchAssociation(
        context: context,
        employeeId: _selectedEmployee.first['zAttributesId'],
        branchMasterId: _selectedBranch.first['zAttributesId'],
      );
    }
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
        final assets = response['data'] as List<BranchMasterModel>;

        return {
          "itemList":
              assets.map((asset) {
                return {
                  "zAttributesId": asset.branchMasterId,
                  "DisplayName": asset.branchName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Branch Association",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                _isEditMode
                    ? "Update Branch Association"
                    : "Add Branch Association",
                style: AppTextStyle.ts16SB(),
              ),
              StatefulBuilder(
                builder: (context, innerState) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      spacing: 10,
                      children: [
                        CustomMultipleSelectPopup(
                          title: 'Employee',
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: _selectedEmployee,
                          dataList: [],
                          onSelected: (value) {
                            innerState(() {
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
                  );
                },
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
                _isEditMode
                    ? "Update Branch Association"
                    : "Add Branch Association",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
