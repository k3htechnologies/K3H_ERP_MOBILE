import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AssignTicketMaster extends StatefulWidget {
  final TicketModel? ticket;
  final int index;
  const AssignTicketMaster({super.key, this.ticket, this.index = 0});

  @override
  State<AssignTicketMaster> createState() => _AssignTicketMasterState();
}

class _AssignTicketMasterState extends State<AssignTicketMaster> {
  late TicketCubit _ticketCubit;
  late TextEditingController _remakrC;
  DateTime? estimatedCompletionDate;
  //EDIT MODE
  bool get _isEditMode => widget.ticket != null;
  late ValueNotifier<List<Map<String, dynamic>>> selectedPrimaryAssignee;
  late ValueNotifier<List<Map<String, dynamic>>> selectedCollaborators;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    selectedPrimaryAssignee = ValueNotifier<List<Map<String, dynamic>>>([]);
    selectedCollaborators = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentModeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
    _ticketCubit = context.read<TicketCubit>();
    initialiseControllers();
    if (_isEditMode) {
      _prefillTicket(widget.ticket!);
    }
  }

  void initialiseControllers() {
    _remakrC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    selectedPrimaryAssignee.dispose();
    selectedCollaborators.dispose();
    _selectedPaymentModeNotifier.dispose();
    _remakrC.dispose();
  }

  void _prefillTicket(TicketModel model) {
    debugPrint("employeeId => ${model.employeeId}");
    debugPrint("employeeName => ${model.employeeName}");

    debugPrint("collaboratorsEmployeeId => ${model.collaboratorsEmployeeId}");
    debugPrint("collaboratorsName => ${model.collaboratorsName}");

    debugPrint("assignedStatus => ${model.assignedStatus}");
    debugPrint("assignedRemark => ${model.assignedRemark}");
    debugPrint("resolvedTillDate => ${model.resolvedTillDate}");
    _remakrC.text = model.assignedRemark;
    if (model.employeeId != 0) {
      selectedPrimaryAssignee.value = [
        {
          "zAttributesId": model.employeeId,
          "EmployeeId": model.employeeId,
          "DisplayName": model.employeeName,
        },
      ];
    }
    if (model.collaboratorsEmployeeId.isNotEmpty) {
      final ids = model.collaboratorsEmployeeId.split(',');
      final names = model.collaboratorsName.split(',');

      selectedCollaborators.value =
          ids.asMap().entries.map((entry) {
            final index = entry.key;

            return {
              "zAttributesId": int.tryParse(entry.value.trim()) ?? 0,
              "EmployeeId": int.tryParse(entry.value.trim()) ?? 0,
              "DisplayName": index < names.length ? names[index].trim() : "",
            };
          }).toList();
    }
    estimatedCompletionDate = model.resolvedTillDate;

    final selectedStatus =
        statusModeList
            .where(
              (e) =>
                  (e["DisplayName"] ?? "").toString().toLowerCase() ==
                  model.assignedStatus.toLowerCase(),
            )
            .toList();

    _selectedPaymentModeNotifier.value = selectedStatus;
  }

  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final assignToEmployeeId =
        selectedPrimaryAssignee.value.isNotEmpty
            ? (selectedPrimaryAssignee.value.first["EmployeeId"] as int? ?? 0)
            : 0;

    final collaboratorsEmployeeId = selectedCollaborators.value
        .map((e) => e["EmployeeId"].toString())
        .join(",");

    final assignedStatus =
        _selectedPaymentModeNotifier.value.isNotEmpty
            ? _selectedPaymentModeNotifier.value.first["DisplayName"].toString()
            : "";

    final ticketRemark = _remakrC.text.trim();

    if (estimatedCompletionDate == null) {
      showErrorMessage(context, "Error", "Select Estimated Completion Date");
      return;
    }

    if (_isEditMode) {
      _ticketCubit.updateAssignTask(
        context,
        ticketId: widget.ticket!.ticketId,
        assignToEmployeeId: assignToEmployeeId,
        collaboratorsEmployeeId: collaboratorsEmployeeId,
        assignedStatus: assignedStatus,
        ticketRemark: ticketRemark,
        resolvedTillDate: estimatedCompletionDate!,
      );
    } else {
      _ticketCubit.addAssignTask(
        context,
        ticketId: 0,
        assignToEmployeeId: assignToEmployeeId,
        collaboratorsEmployeeId: collaboratorsEmployeeId,
        assignedStatus: assignedStatus,
        ticketRemark: ticketRemark,
        resolvedTillDate: estimatedCompletionDate!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Ticket" : "Add Ticket",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 12.0,
          bottom: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: AppColor.lightBluebg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Platform",
                          value: widget.ticket?.platform ?? "-",
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Module",
                          value: widget.ticket?.module ?? "-",
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Raised By",
                          value: widget.ticket?.createdBy ?? "-",
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Department",
                          value: widget.ticket?.departmentName ?? "-",
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildColumnTitleValueNormal(
                        title: "Description",
                        value: widget.ticket?.ticketDescription ?? "-",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 16.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Assign Ticket",
                              style: AppTextStyle.ts14M(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                            verticalSpacing(),
                            ValueListenableBuilder(
                              valueListenable: selectedPrimaryAssignee,
                              builder: (context, selectedValue, child) {
                                return CustomMultipleSelectPopup(
                                  title: "Primary Assignee",
                                  hintText: "Select Primary Assignee",
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedValue,
                                  dataList: const [],
                                  dataFetchCallBack:
                                      _ticketCubit
                                          .getEmployeeActiveTicketsDropdown,
                                  onSelected: (value) {
                                    selectedPrimaryAssignee.value = value;
                                  },
                                  onClear: () {
                                    selectedPrimaryAssignee.value = [];
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Primary Assignee is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: selectedCollaborators,
                              builder: (context, selectedValue, _) {
                                return CustomMultipleSelectPopup(
                                  title: "Collaborators",
                                  hintText: "Select Collaborators",
                                  isRequired: false,
                                  isMultiSelect: true,
                                  initialValue: selectedValue,
                                  dataList: const [],
                                  dataFetchCallBack:
                                      _ticketCubit
                                          .getEmployeeActiveTicketsDropdown,
                                  onSelected: (value) {
                                    selectedCollaborators.value = value;
                                  },
                                  onClear: () {
                                    selectedCollaborators.value = [];
                                  },
                                );
                              },
                            ),
                            CustomDatePicker(
                              title: "Esitmated Completion Date",
                              hint: "Select Esitmated Completion Date",
                              isRequired: true,
                              initialDate: estimatedCompletionDate,
                              setValue:
                                  (value) => estimatedCompletionDate = value,
                              validator: (value) {
                                if (value == null) {
                                  return 'Select Esitmated Completion Date';
                                }

                                return null;
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _selectedPaymentModeNotifier,
                              builder: (context, selectedPaymentMode, _) {
                                return CustomDropDownWidget(
                                  title: "Status",
                                  hintText: "Select Status",
                                  isRequired: true,
                                  initialValue:
                                      selectedPaymentMode.isNotEmpty
                                          ? selectedPaymentMode.first
                                          : null,
                                  dataList: statusModeList,
                                  onSelected: (value) {
                                    _selectedPaymentModeNotifier.value = [
                                      value,
                                    ];
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Payment Mode is required";
                                    }
                                    return null;
                                  },
                                  onValueClear: () {
                                    _selectedPaymentModeNotifier.value = [];
                                  },
                                );
                              },
                            ),
                            CustomTextField(
                              textController: _remakrC,
                              isRequired: true,
                              title: "Remark",
                              hint: "Enter Remark",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _verifyAndSubmitForm,
          ),
        ),
      ),
    );
  }
}
