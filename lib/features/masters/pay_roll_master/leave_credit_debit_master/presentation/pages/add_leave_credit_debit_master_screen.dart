import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/model/leave_credit_debit_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/presentation/cubit/leave_credit_debit_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLeaveCreditDebitMasterScreen extends StatefulWidget {
  final LeaveCreditDebitMasterModel? leaveCreditDebitMasterModel;
  final int index;
  const AddLeaveCreditDebitMasterScreen({
    super.key,
    this.leaveCreditDebitMasterModel,
    this.index = 0,
  });

  @override
  State<AddLeaveCreditDebitMasterScreen> createState() =>
      _AddLeaveCreditDebitMasterScreenState();
}

class _AddLeaveCreditDebitMasterScreenState
    extends State<AddLeaveCreditDebitMasterScreen> {
  // CUBIT
  late LeaveCreditDebitMasterCubit _leaveCreditDebitMasterCubit;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //EDIT MODE
  bool get _isEditMode => widget.leaveCreditDebitMasterModel != null;

  // TEXT EDITING CONTROLLER
  late TextEditingController _leaveCreditC;

  // STATIC LEAVE PERIOD LIST
  List<Map<String, dynamic>> leavePeriodList = [
    {"zAttributesId": -1, "DisplayName": "Select Leave Period"},
    {"zAttributesId": 1, "DisplayName": "Yearly"},
    {"zAttributesId": 2, "DisplayName": "Monthly"},
  ];

  // STATIC LEAVE TYPE LIST
  List<Map<String, dynamic>> leaveTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Leave Type"},
    {"zAttributesId": 1, "DisplayName": "Maternity - Maternity Leave"},
    {"zAttributesId": 2, "DisplayName": "CL - Casual Leave"},
    {"zAttributesId": 3, "DisplayName": "Birthday - Birthday Leave"},
    {"zAttributesId": 4, "DisplayName": "Adoption - Adoption Leave"},
  ];

  // DROPDOWN VARIABLE
  Map<String, dynamic>? selectedLeavePeriod;
  Map<String, dynamic>? selectedLeaveType;

  // DATE VARIABLES
  DateTime? startDate;
  DateTime? endDate;

  // DEPARTMENT VARIABLE (using ValueNotifier instead of setState)
  final ValueNotifier<List<Map<String, dynamic>>> _selectedDepartmentNotifier =
      ValueNotifier([]);

  // DEPARTMENT VARIABLE (using ValueNotifier instead of setState)
  final ValueNotifier<List<Map<String, dynamic>>> _selectedDesignationNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _leaveCreditDebitMasterCubit = context.read<LeaveCreditDebitMasterCubit>();
    selectedLeavePeriod = leavePeriodList.first;
    selectedLeaveType = leaveTypeList.first;
    _initializeTextEditingControllers();
  }

  @override
  void dispose() {
    super.dispose();
    _leaveCreditC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _leaveCreditC = TextEditingController();
  }

  // FETCH DEPARTMENT
  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    final totalCount = _leaveCreditDebitMasterCubit.state.departmentTotalCount;
    final pageSize = 15;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final departmentList = _leaveCreditDebitMasterCubit.state.departmentList;
      final filteredDepartments =
          departmentList
              .where(
                (dept) => dept.departmentName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final dept in filteredDepartments) {
        uniqueFiltered[dept.departmentMasterId] = {
          "zAttributesId": dept.departmentMasterId,
          "DisplayName": dept.departmentName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    final currentLoadedCount =
        _leaveCreditDebitMasterCubit.state.departmentList.length;

    // Always call API if list is empty or if we need more data
    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _leaveCreditDebitMasterCubit.getDepartmentList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final departmentList = _leaveCreditDebitMasterCubit.state.departmentList;

    final Map<int, Map<String, dynamic>> uniqueDepartments = {};

    for (final dept in departmentList) {
      uniqueDepartments[dept.departmentMasterId] = {
        "zAttributesId": dept.departmentMasterId,
        "DisplayName": dept.departmentName,
      };
    }

    return {
      "itemList": uniqueDepartments.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDepartments.length,
    };
  }

  // FETCH DESIGNATION
  Future<Map<String, dynamic>> _fetchDesignation(
    int pageNumber, {
    String? value,
  }) async {
    final totalCount = _leaveCreditDebitMasterCubit.state.designationTotalCount;
    final pageSize = 15;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final designationList =
          _leaveCreditDebitMasterCubit.state.designationList;
      final filteredDesignation =
          designationList
              .where(
                (dept) => dept.designationName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final dept in filteredDesignation) {
        uniqueFiltered[dept.designationMasterId] = {
          "zAttributesId": dept.designationMasterId,
          "DisplayName": dept.designationName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    final currentLoadedCount =
        _leaveCreditDebitMasterCubit.state.designationList.length;

    // Always call API if list is empty or if we need more data
    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _leaveCreditDebitMasterCubit.getDesignationList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final designationList = _leaveCreditDebitMasterCubit.state.designationList;

    final Map<int, Map<String, dynamic>> uniqueDesignation = {};

    for (final dept in designationList) {
      uniqueDesignation[dept.designationMasterId] = {
        "zAttributesId": dept.designationMasterId,
        "DisplayName": dept.designationName,
      };
    }

    return {
      "itemList": uniqueDesignation.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDesignation.length,
    };
  }

  // BOTTOM SHEET FOR ADDING LEAVE BALANCE TYPE
  Future<void> _showCorpusBottomSheet() async {
    DialogHelper.showCustomBottomSheet(
      context,
      "Leave Balance Type",
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CustomDropDownWidget(
              dataList: leaveTypeList,
              onSelected: (value) {
                selectedLeaveType = value;
              },
              initialValue: selectedLeaveType,
              title: "Leave Type",
              isRequired: true,
              validator: (value) {
                if (value == null || value["zAttributesId"] == -1) {
                  return 'Leave Type is required';
                }
                return null;
              },
            ),
            CustomTextField(
              textController: _leaveCreditC,
              isRequired: true,
              title: "Leave Credit",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Leave Credit is required";
                }
                return null;
              },
            ),
            CustomButton(
              leading: Icon(Icons.add, size: 18, color: AppColor.white),
                text: "Add", onPressed: () {}),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave Credit Debit Management",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? "Update Leave Credit Debit Master"
                    : "Add Leave Credit Debit Master",
                style: AppTextStyle.ts16M(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    CustomDropDownWidget(
                      dataList: leavePeriodList,
                      onSelected: (value) {
                        selectedLeavePeriod = value;
                      },
                      initialValue: selectedLeavePeriod,
                      title: "Leave Period",
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Leave Period is required';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDatePicker(
                            title: "Start Date",
                            isRequired: true,
                            initialDate: startDate,
                            setValue: (value) {
                              startDate = value;
                            },
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: CustomDatePicker(
                            title: "End Date",
                            isRequired: true,
                            initialDate: endDate,
                            setValue: (value) {
                              endDate = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedDepartmentNotifier,
                      builder: (context, selectedDept, child) {
                        return CustomMultipleSelectPopup(
                          title: "Department",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedDept,
                          dataFetchCallBack: _fetchDepartment,
                          onSelected: (value) {
                            _selectedDepartmentNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Department is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedDesignationNotifier,
                      builder: (context, selectedDes, child) {
                        return CustomMultipleSelectPopup(
                          title: "Department",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedDes,
                          dataFetchCallBack: _fetchDesignation,
                          onSelected: (value) {
                            _selectedDesignationNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Designation is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Leave Balance Type", style: AppTextStyle.ts16M()),
                        Spacer(),
                        CustomButton(
                          leading: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColor.white,
                          ),
                          text: "Add",
                          onPressed: () {
                            _showCorpusBottomSheet();
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
