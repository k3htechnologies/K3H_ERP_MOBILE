import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/leave/model/leave.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final LeaveModel? leaveModel;
  final int? index;
  const ApplyLeaveScreen({super.key, this.leaveModel, this.index = 0});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  // CUBIT
  late LeaveCubit _leaveCubit;

  // FORK KEY
  final _formKey = GlobalKey<FormState>();

  //EDIT MODE
  bool get _isEditMode => widget.leaveModel != null;

  // DEPARTMENT VARIABLE
  final ValueNotifier<List<Map<String, dynamic>>> _selectedLeaveTypeNotifier =
      ValueNotifier([]);

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  // TEXT EDITING CONTROLLER
  late TextEditingController _totalDaysC, _reasonC;

  // STATIC DURATION LIST
  List<Map<String, dynamic>> durationList = [
    {
      "zAttributesId": 1,
      "DisplayName": "Half Day (First Half)",
      "value": "HalfFirst",
    },
    {
      "zAttributesId": 2,
      "DisplayName": "Half Day (Second Half)",
      "value": "HalfSecond",
    },
    {"zAttributesId": 3, "DisplayName": "Full Day", "value": "Full"},
  ];

  // DROPDOWN VARIABLE
  ValueNotifier<Map<String, dynamic>?> selectedStartDuration = ValueNotifier(
    null,
  );
  ValueNotifier<Map<String, dynamic>?> selectedEndDuration = ValueNotifier(
    null,
  );

  // FILE VARIABLES
  MultiFilePickerModel leaveDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _leaveCubit = context.read<LeaveCubit>();
    _initializeTextController();
    if (_isEditMode && widget.leaveModel != null) {
      _populateFormFields(widget.leaveModel!);
    }
  }

  void _populateFormFields(LeaveModel m) {
    _selectedLeaveTypeNotifier.value = [
      {"zAttributesId": m.leaveTypeMasterId, "DisplayName": m.leaveType},
    ];
    _startDateNotifier.value = m.startDate;
    _endDateNotifier.value = m.endDate;
    _totalDaysC.text = m.noOfDays.toString();
    _reasonC.text = m.reason;
    selectedStartDuration.value = durationList.firstWhere(
      (d) => d['value'].toString().toUpperCase() == m.startDateLeaveDuration,
      orElse: () => durationList.first,
    );
    selectedEndDuration.value = durationList.firstWhere(
      (d) => d['value'].toString().toUpperCase() == m.endDateLeaveDuration,
      orElse: () => durationList.first,
    );
    final urls =
        m.leaveDocumentUrl.trim().isEmpty
            ? <String>[]
            : m.leaveDocumentUrl
                .split(",")
                .map((e) => e.trim())
                .where((s) => s.isNotEmpty)
                .toList();
    leaveDocument.fileNameList = urls;
    leaveDocument.fileBytesList = List.generate(
      urls.length,
      (_) => Uint8List(0),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _totalDaysC.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _selectedLeaveTypeNotifier.dispose();
    _reasonC.dispose();
  }

  // INITIALIZE TEXT CONTROLLER
  void _initializeTextController() {
    _totalDaysC = TextEditingController();
    _reasonC = TextEditingController();
  }

  // CALCULATE TOTAL DAYS
  void _calculateTotalDays() {
    final startDate = _startDateNotifier.value;
    final endDate = _endDateNotifier.value;

    if (startDate == null || endDate == null) {
      _totalDaysC.clear();
      return;
    }

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (end.isBefore(start)) {
      _totalDaysC.clear();
      return;
    }

    double totalDays = (end.difference(start).inDays + 1).toDouble();
    if ((selectedStartDuration.value != null &&
        selectedStartDuration.value?['zAttributesId'] != 3)) {
      totalDays = totalDays - 0.5;
    }
    if (selectedEndDuration.value != null &&
        selectedEndDuration.value?['zAttributesId'] != 3) {
      totalDays = totalDays - 0.5;
    }
    _totalDaysC.text = totalDays.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Leave" : "Apply Leave",
              style: AppTextStyle.ts16SB(),
            ),
            verticalSpacing(),
            Form(
              key: _formKey,
              child: Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedLeaveTypeNotifier,
                      builder: (context, leaveTy, child) {
                        return CustomMultipleSelectPopup(
                          title: "Leave Type",
                          hintText: "Select Leave Type",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: leaveTy,
                          dataFetchCallBack:
                              _leaveCubit.fetchConfiguredLeaveType,
                          onSelected: (value) {
                            _selectedLeaveTypeNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Leave Type is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return CustomDatePicker(
                                title: "Start Date",
                                isRequired: true,
                                initialDate: startDate,
                                setValue: (value) {
                                  _startDateNotifier.value = value;
                                  _calculateTotalDays();
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Start Date is required.';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: _endDateNotifier,
                            builder: (context, endDate, child) {
                              return ValueListenableBuilder<DateTime?>(
                                valueListenable: _startDateNotifier,
                                builder: (context, startDate, child) {
                                  return CustomDatePicker(
                                    title: "End Date",
                                    isRequired: true,
                                    initialDate: endDate,
                                    setValue: (value) {
                                      _endDateNotifier.value = value;
                                      _calculateTotalDays();
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'End Date is required.';
                                      }

                                      if (startDate != null) {
                                        final startDateOnly = DateTime(
                                          startDate.year,
                                          startDate.month,
                                          startDate.day,
                                        );
                                        final endDateOnly = DateTime(
                                          value.year,
                                          value.month,
                                          value.day,
                                        );

                                        if (endDateOnly.isBefore(
                                          startDateOnly,
                                        )) {
                                          return 'End Date cannot be before Start Date';
                                        }
                                      }
                                      return null;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    ValueListenableBuilder(
                      valueListenable: selectedStartDuration,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: "Start Day Duration",
                          hintText: "Select Start Day Duration",
                          isRequired: true,
                          dataList: durationList,
                          initialValue: value,
                          onSelected: (value) {
                            selectedStartDuration.value = value;
                            _calculateTotalDays();
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'Start Duration is required.';
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedStartDuration.value = null;
                            _calculateTotalDays();
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedEndDuration,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: "End Day Duration",
                          hintText: "Select End Day Duration",
                          isRequired: true,
                          dataList: durationList,
                          initialValue: value,
                          onSelected: (value) {
                            selectedEndDuration.value = value;
                            _calculateTotalDays();
                          },
                          validator: (value) {
                            if (value == null || value["zAttributesId"] == -1) {
                              return 'End Duration is required.';
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedEndDuration.value = null;
                            _calculateTotalDays();
                          },
                        );
                      },
                    ),
                    FormField<String>(
                      validator: (_) {
                        if (_totalDaysC.text.isEmpty) {
                          return 'Total Days is required.';
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              textController: _totalDaysC,
                              title: "Total Days",
                              hint: "0",
                              isRequired: true,
                              readOnly: true,
                            ),
                          ],
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _reasonC,
                      title: "Reason",
                      hint: "Enter reason",
                      minLines: 3,
                      maxLines: 3,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reason is required.';
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 3,
                      filePickType: FilePickType.kycDocument,
                      initialFileList: leaveDocument.fileNameList,
                      title: "Leave Document",
                      onFilePickedCallback: (fileByteList, fileNameList) {
                        leaveDocument.fileBytesList = fileByteList;
                        leaveDocument.fileNameList = fileNameList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedUrl,
                      ) {
                        leaveDocument.fileBytesList = fileBytesList;
                        leaveDocument.fileNameList = fileNameList;
                        leaveDocument.deletedFileList = deletedUrl;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Leave" : "Apply Leave",
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final leaveTypeMasterId =
                  _selectedLeaveTypeNotifier.value[0]["zAttributesId"]
                      .toString();
              final startDate = _startDateNotifier.value!;
              final endDate = _endDateNotifier.value!;
              final startDateLeaveDuration =
                  selectedStartDuration.value!["value"];
              final endDateLeaveDuration = selectedEndDuration.value!["value"];
              final reason = _reasonC.text;

              if (_isEditMode && widget.leaveModel != null) {
                _leaveCubit.updateLeave(
                  index: widget.index ?? 0,
                  context: context,
                  leaveId: widget.leaveModel!.leaveId.toString(),
                  uniquekey: widget.leaveModel!.uniquekey,
                  leaveTypeMasterId: leaveTypeMasterId,
                  startDate: startDate.toIso8601String(),
                  endDate: endDate.toIso8601String(),
                  startDateLeaveDuration: startDateLeaveDuration,
                  endDateLeaveDuration: endDateLeaveDuration,
                  reason: reason,
                  leaveDocument: leaveDocument,
                );
              } else {
                _leaveCubit.applyLeave(
                  context: context,
                  leaveTypeMasterId: leaveTypeMasterId,
                  startDate: startDate.toIso8601String(),
                  endDate: endDate.toIso8601String(),
                  startDateLeaveDuration: startDateLeaveDuration,
                  endDateLeaveDuration: endDateLeaveDuration,
                  reason: reason,
                  leaveDocument: leaveDocument,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
