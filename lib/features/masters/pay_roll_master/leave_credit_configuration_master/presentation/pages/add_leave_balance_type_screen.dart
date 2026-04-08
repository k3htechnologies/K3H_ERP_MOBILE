import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/cubit/leave_credit_configuration_master_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLeaveBalanceTypeScreen extends StatefulWidget {
  final List<LeaveBalanceType> existingLeaveBalanceTypes;
  const AddLeaveBalanceTypeScreen({
    super.key,
    required this.existingLeaveBalanceTypes,
  });

  @override
  State<AddLeaveBalanceTypeScreen> createState() =>
      _AddLeaveBalanceTypeScreenState();
}

class _AddLeaveBalanceTypeScreenState extends State<AddLeaveBalanceTypeScreen> {
  // CUBIT
  late LeaveCreditConfigurationMasterCubit _leaveCreditConfigurationMasterCubit;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // LEAVE TYPE VARIABLE
  final ValueNotifier<List<Map<String, dynamic>>> _selectedLeaveTypeNotifier =
      ValueNotifier([]);

  // TEXT EDITING CONTROLLER
  late TextEditingController _leaveCreditC;

  @override
  void initState() {
    super.initState();
    _leaveCreditConfigurationMasterCubit =
        context.read<LeaveCreditConfigurationMasterCubit>();
    _leaveCreditC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _leaveCreditC.dispose();
  }

  // FETCH LEAVE TYPE
  Future<Map<String, dynamic>> _fetchLeaveType(
    int pageNumber, {
    String? value,
  }) async {
    final pageSize = 15;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final leaveTypeList =
          _leaveCreditConfigurationMasterCubit.state.leaveTypeList;
      final filteredLeaveType =
          leaveTypeList
              .where(
                (leave) =>
                    leave.leaveType.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final lev in filteredLeaveType) {
        uniqueFiltered[lev.leaveTypeMasterId] = {
          "zAttributesId": lev.leaveTypeMasterId,
          "DisplayName": lev.leaveType,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    final currentLoadedCount =
        _leaveCreditConfigurationMasterCubit.state.leaveTypeList.length;
    if (currentLoadedCount == 0) {
      await _leaveCreditConfigurationMasterCubit.getLeaveTypeList(
        context,
        pageNumber,
        pageSize,
      );
    }

    final leaveTypeList =
        _leaveCreditConfigurationMasterCubit.state.leaveTypeList;

    final Map<int, Map<String, dynamic>> uniqueDesignation = {};

    for (final dept in leaveTypeList) {
      uniqueDesignation[dept.leaveTypeMasterId] = {
        "zAttributesId": dept.leaveTypeMasterId,
        "DisplayName": dept.leaveType,
      };
    }

    final items = uniqueDesignation.values.toList();

    return {"itemList": items, "totalNumberOfRecord": items.length};
  }

  // HANDLE ADD
  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      final leaveTypeId = _selectedLeaveTypeNotifier.value[0]["zAttributesId"];

      // Check if leave balance type already exists
      final isDuplicate = widget.existingLeaveBalanceTypes.any(
        (item) => item.leaveTypeId == leaveTypeId,
      );

      if (isDuplicate) {
        DialogHelper.showErrorMessage(
          context: context,
          title: "Duplicate Entry",
          message:
              "This leave balance type has already been added. Please select a different leave type.",
        );
        return;
      }

      final leaveCredit = int.tryParse(_leaveCreditC.text.trim());
      if (leaveCredit != null) {
        final newLeaveBalanceType = LeaveBalanceType(
          leaveTypeBalanceId: 0,
          leaveTypeId: leaveTypeId,
          leaveTypeName: _selectedLeaveTypeNotifier.value[0]["DisplayName"],
          leaveCredit: leaveCredit,
          leaveCreditConfigurationId: 0,
        );
        goRouter.pop(newLeaveBalanceType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Add Leave Balance Type",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Leave Balance Type", style: AppTextStyle.ts16M()),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedLeaveTypeNotifier,
                      builder: (context, selectedDept, child) {
                        return CustomMultipleSelectPopup(
                          title: "Leave Type",
                          hintText: "Select Leave Type",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedDept,
                          dataFetchCallBack: _fetchLeaveType,
                          onSelected: (value) {
                            _selectedLeaveTypeNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Leave Type is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      textController: _leaveCreditC,
                      isRequired: true,
                      title: "Leave Credit",
                      hint: "Enter Leave Credit",
                      inputFormatterList: InputValidator.digit(2),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Leave Credit is required";
                        }
                        if (int.tryParse(value) == null) {
                          return "Please enter a valid number";
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
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            leading: Icon(Icons.add, size: 18, color: AppColor.white),
            text: "Add",
            onPressed: _handleAdd,
          ),
        ),
      ),
    );
  }
}
