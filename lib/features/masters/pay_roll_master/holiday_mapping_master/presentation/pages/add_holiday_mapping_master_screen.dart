import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/repository/holiday_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddHolidayMappingMasterScreen extends StatefulWidget {
  final HolidayMappingModel? holidayMapping;
  final int? index;
  const AddHolidayMappingMasterScreen({
    super.key,
    this.holidayMapping,
    this.index = 0,
  });

  @override
  State<AddHolidayMappingMasterScreen> createState() =>
      _AddHolidayMappingMasterScreenState();
}

class _AddHolidayMappingMasterScreenState
    extends State<AddHolidayMappingMasterScreen> {
  // CUBIT
  late HolidayMappingMasterCubit _holidayMappingMasterCubit;

  // REPOSITORY
  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  final HolidayMasterRepository _holidayMasterRepository =
      serviceLocator<HolidayMasterRepository>();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedBranch = [];
  List<Map<String, dynamic>> _selectedDepartment = [];
  List<Map<String, dynamic>> _selectedHoliday = [];

  // DATE PICKERS
  DateTime? _holidayDate;

  bool get _isEditMode => widget.holidayMapping != null;

  @override
  void initState() {
    super.initState();
    _holidayMappingMasterCubit = context.read<HolidayMappingMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    if (_isEditMode && widget.holidayMapping != null) {
      _populateFormFields(widget.holidayMapping!);
    }
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(HolidayMappingModel holidayMapping) {
    if ((holidayMapping.branchMasterId).toString().isNotEmpty &&
        (holidayMapping.branchName).toString().isNotEmpty) {
      _selectedBranch = [
        {
          'zAttributesId': holidayMapping.branchMasterId,
          'DisplayName': holidayMapping.branchName,
        },
      ];
    } else {
      _selectedBranch = [];
    }
    _selectedHoliday = [
      {
        'zAttributesId': holidayMapping.holidayMasterId,
        'DisplayName': holidayMapping.holidayName,
      },
    ];

    if (holidayMapping.departmentMasterId.isNotEmpty &&
        holidayMapping.departmentName.isNotEmpty) {
      final ids = holidayMapping.departmentMasterId.split(',');
      final names = holidayMapping.departmentName.split(',');

      _selectedDepartment = List.generate(ids.length, (index) {
        return {
          'zAttributesId': int.parse(ids[index]),
          'DisplayName': names[index],
        };
      });
    } else {
      _selectedDepartment = [];
    }

    _holidayDate = holidayMapping.holidayDate;
  }

  // FETCH HOLIDAY
  Future<Map<String, dynamic>> _fetchHolidays(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _holidayMasterRepository.getHolidayList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"HolidayName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final assets = response['data'] as List<HolidayMasterModel>;

        return {
          "itemList":
              assets.map((asset) {
                return {
                  "zAttributesId": asset.holidayMasterId,
                  "DisplayName": asset.holidayName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH BRANCH
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

  // FETCH DEPARTMENTS
  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"DepartmentName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final departments = response['data'] as List<DepartmentModel>;

        return {
          "itemList":
              departments.map((department) {
                return {
                  "zAttributesId": department.departmentMasterId,
                  "DisplayName": department.departmentName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String departmentIds = _selectedDepartment
        .map((e) => e['zAttributesId'].toString())
        .join(',');

    int holidayId =
        _selectedHoliday.isNotEmpty
            ? _selectedHoliday.first['zAttributesId'] as int
            : 0;

    String branchId =
        _selectedBranch.isNotEmpty
            ? _selectedBranch.first['zAttributesId'].toString()
            : "";

    if (_isEditMode && widget.holidayMapping != null) {
      _holidayMappingMasterCubit.updateHolidayMapping(
        index: widget.index!,
        context: context,
        holidayMappingMasterId: widget.holidayMapping!.holidayMappingMasterId,
        uniqueKey: widget.holidayMapping!.uniquekey,
        holidayMasterId: holidayId,
        branchMasterId: branchId,
        holidayDate: _holidayDate!,
        departmentIds: departmentIds,
      );
    } else {
      _holidayMappingMasterCubit.addHolidayMapping(
        context: context,
        holidayMasterId: holidayId,
        branchMasterId: branchId,
        holidayDate: _holidayDate!,
        departmentIds: departmentIds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Holiday Mapping Master",
        authorization: _routeAuthorizationModel,
      ),
      body: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode
                          ? "Update Holiday Mapping"
                          : "Add Holiday Mapping",
                      style: AppTextStyle.ts16SB(),
                    ),
                    verticalSpacing(),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: commonCardDecoration(),
                      child: Column(
                        children: [
                          CustomMultipleSelectPopup(
                            title: 'Holiday Name',
                            isRequired: true,
                            isMultiSelect: false,
                            hintText: "Select Holiday Name",
                            initialValue: _selectedHoliday,
                            dataList: [],
                            onSelected: (value) {
                              innerState(() {
                                _selectedHoliday = value;
                              });
                            },
                            dataFetchCallBack: _fetchHolidays,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Holiday is required";
                              }
                              return null;
                            },
                          ),
                          CustomDatePicker(
                            title: 'Holiday Date',
                            initialDate: _holidayDate,
                            isRequired: true,
                            setValue: (date) {
                              innerState(() {
                                _holidayDate = date;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Holiday Date is required";
                              }
                              return null;
                            },
                          ),
                          CustomMultipleSelectPopup(
                            title: 'Branch',
                            isMultiSelect: false,
                            hintText: "Select Branch Name",
                            initialValue: _selectedBranch,
                            dataList: [],
                            onSelected: (value) {
                              innerState(() {
                                _selectedBranch = value;
                              });
                            },
                            dataFetchCallBack: _fetchBranch,
                          ),
                          CustomMultipleSelectPopup(
                            title: 'Department',
                            isMultiSelect: true,
                            hintText: "Select Department Name",
                            initialValue: _selectedDepartment,
                            dataList: [],
                            onSelected: (value) {
                              innerState(() {
                                _selectedDepartment = value;
                              });
                            },
                            dataFetchCallBack: _fetchDepartment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
