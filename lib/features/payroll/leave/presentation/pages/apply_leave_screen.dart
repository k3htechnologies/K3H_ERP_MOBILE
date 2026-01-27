import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/payroll/leave/presentation/cubit/leave_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApplyLeaveScreen extends StatefulWidget {
  final LeaveTypeModel? leaveTypeModel;
  final int? index;
  const ApplyLeaveScreen({super.key, this.leaveTypeModel, this.index = 0});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  // CUBIT
  late LeaveCubit _leaveCubit;

  // FORK KEY
  final _formKey = GlobalKey<FormState>();

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
    {"zAttributesId": -1, "DisplayName": "Select Duration"},
    {"zAttributesId": 1, "DisplayName": "Half-Day"},
    {"zAttributesId": 2, "DisplayName": "Full-Day"},
  ];

  // DROPDOWN VARIABLE
  Map<String, dynamic>? selectedStartDuration;
  Map<String, dynamic>? selectedEndDuration;

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
    selectedStartDuration = durationList.first;
    selectedEndDuration = durationList.first;
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

  // FETCH DESIGNATION
  Future<Map<String, dynamic>> _fetchLeaveType(
    int pageNumber, {
    String? value,
  }) async {
    final totalCount = _leaveCubit.state.leaveTypeTotalCount;
    final pageSize = 15;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final leaveTypeList = _leaveCubit.state.leaveTypeList;
      final filteredLeaveType =
          leaveTypeList
              .where(
                (leaveType) => leaveType.leaveType
                    .toString()
                    .toLowerCase()
                    .contains(value.toString().toLowerCase()),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final leaveType in filteredLeaveType) {
        uniqueFiltered[leaveType.leaveTypeMasterId] = {
          "zAttributesId": leaveType.leaveTypeMasterId.toString(),
          "DisplayName": leaveType.leaveType,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    final currentLoadedCount = _leaveCubit.state.leaveTypeList.length;

    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _leaveCubit.getLeaveTypeList(context, pageNumber, pageSize);
    }

    final leaveTypeListList = _leaveCubit.state.leaveTypeList;

    final Map<int, Map<String, dynamic>> uniqueLeaveType = {};

    for (final leaveType in leaveTypeListList) {
      uniqueLeaveType[leaveType.leaveTypeMasterId] = {
        "zAttributesId": leaveType.leaveTypeMasterId.toString(),
        "DisplayName": leaveType.leaveType,
      };
    }

    return {
      "itemList": uniqueLeaveType.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueLeaveType.length,
    };
  }

  // CALCULATE TOTAL DAYS
  void _calculateTotalDays() {
    final startDate = _startDateNotifier.value;
    final endDate = _endDateNotifier.value;

    if (startDate == null || endDate == null) {
      _totalDaysC.clear();
      _formKey.currentState?.validate();
      return;
    }

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (end.isBefore(start)) {
      _totalDaysC.clear();
      _formKey.currentState?.validate();
      return;
    }

    final totalDays = end.difference(start).inDays + 1;
    _totalDaysC.text = totalDays.toString();

    _formKey.currentState?.validate();
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
            Text("Apply Leave", style: AppTextStyle.ts16M()),
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
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: leaveTy,
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
                    Row(
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
                                    return 'Start Date is required';
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
                                        return 'End Date is required';
                                      }
                                      if (startDate != null) {
                                        // Compare dates by day (ignoring time)
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
                                            ) ||
                                            endDateOnly.isAtSameMomentAs(
                                              startDateOnly,
                                            )) {
                                          return 'End Date must be after Start Date';
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
                    FormField<String>(
                      validator: (_) {
                        if (_totalDaysC.text.isEmpty) {
                          return 'Total Days is required';
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
                              isRequired: true,
                              readOnly: true,
                            ),
                          ],
                        );
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Start Day Duration",
                      isRequired: true,
                      dataList: durationList,
                      onSelected: (value) {
                        selectedStartDuration = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Start Duration is required';
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "End Day Duration",
                      isRequired: true,
                      dataList: durationList,
                      onSelected: (value) {
                        selectedEndDuration = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'End Duration is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _reasonC,
                      title: "Reason",
                      hint: "Enter reason",
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reason is required';
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 3,
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
            text: "Apply Leave",
            onPressed: () {
              if (_formKey.currentState!.validate()) {}
            },
          ),
        ),
      ),
    );
  }
}
