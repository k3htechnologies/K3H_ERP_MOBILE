import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

class ModuleAddEmployeeScreen extends StatefulWidget {
  final ModulesWorkflowApprovalModel module;
  final int projectId;
  const ModuleAddEmployeeScreen({
    super.key,
    required this.module,
    required this.projectId,
  });
  @override
  State<ModuleAddEmployeeScreen> createState() =>
      _ModuleAddEmployeeScreenState();
}

class _ModuleAddEmployeeScreenState extends State<ModuleAddEmployeeScreen> {
  late ProjectMasterCubit _projectMasterCubit;
  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _selectedEmployee = [];
  @override
  void initState() {
    super.initState();
    _projectMasterCubit = context.read<ProjectMasterCubit>();
  }

  // FETCH EMPLOYEES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _utilsRepository.pullPaginationProjectWithEmployee(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: widget.projectId,
      queryParams: value != null && value.isNotEmpty ? {"FullName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees =
            response['data'] as List<ModulesApprovalEmployeeDataModel>;

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

  String get selectedEmployees => _selectedEmployee
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await _projectMasterCubit.addUpdateModulesWorkflowApproval(
      context: context,
      employeeId: selectedEmployees,
      projectId: widget.projectId,
      modulesMasterId: widget.module.modulesMasterId,
      subModulesMasterId: widget.module.subModulesMasterId,
      subSubModulesMasterId: widget.module.subSubModulesMasterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Add Employee",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: commonCardDecoration(),
                child: CustomMultipleSelectPopup(
                  title: 'Employee',
                  hintText: "Select Employees",
                  isRequired: true,
                  isMultiSelect: true,
                  initialValue: _selectedEmployee,
                  dataList: const [],
                  onSelected: (value) {
                    _selectedEmployee = value;
                  },
                  dataFetchCallBack: _fetchEmployees,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Employee is required.";
                    }
                    return null;
                  },
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
            leading: Icon(Icons.add, size: 16),
            text: "Add",
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }
}
