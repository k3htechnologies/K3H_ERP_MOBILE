import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';

class AddOutdoorScreen extends StatefulWidget {
  final OutdoorModel? outdoorModel;
  final int index;
  const AddOutdoorScreen({super.key, this.outdoorModel, required this.index});

  @override
  State<AddOutdoorScreen> createState() => _AddOutdoorScreenState();
}

class _AddOutdoorScreenState extends State<AddOutdoorScreen> {
  // CUBIT
  late OutdoorCubit _outdoorCubit;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //TIME VARIABLES
  String? meetingTime;
  TimeOfDay? initialMeetingTime;

  // DATE VARIABLE
  DateTime? outdoorDate;

  // TEXT EDITING CONTROLLER
  late TextEditingController _purposeC, _companyNameC, _companyAddressC;

  // DEPARTMENT VARIABLE (using ValueNotifier instead of setState)
  final ValueNotifier<List<Map<String, dynamic>>> _selectedDepartmentNotifier =
      ValueNotifier([]);

  // EMPLOYEE VARIABLE (using ValueNotifier instead of setState)
  final ValueNotifier<List<Map<String, dynamic>>> _selectedEmployeeNotifier =
      ValueNotifier([]);

  // FILE PICKER
  MultiFilePickerModel visitingCardFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  //EDIT MODE
  bool get _isEditMode => widget.outdoorModel != null;

  @override
  void initState() {
    super.initState();
    _outdoorCubit = context.read<OutdoorCubit>();

    _initializeTextEditingControllers();

    // Pre-fill data if in edit mode
    if (_isEditMode && widget.outdoorModel != null) {
      _prefillData();
    }

    // Load departments initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDepartments();
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    _purposeC.dispose();
    _companyNameC.dispose();
    _companyAddressC.dispose();
    _selectedDepartmentNotifier.dispose();
    _selectedEmployeeNotifier.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _purposeC = TextEditingController();
    _companyNameC = TextEditingController();
    _companyAddressC = TextEditingController();
  }

  // PREFILL DATA IF IN EDIT MODE
  void _prefillData() {
    _purposeC.text = widget.outdoorModel!.purpose;
    _companyNameC.text = widget.outdoorModel!.companyName;
    _companyAddressC.text = widget.outdoorModel!.companyAddress;

    outdoorDate = widget.outdoorModel!.outDoorDate;

    // Extract time from DateTime and format it
    final dateTime = widget.outdoorModel!.outDoorTime;
    initialMeetingTime = TimeOfDay(
      hour: dateTime.hour,
      minute: dateTime.minute,
    );
    meetingTime = formatTimeOfDayHHmm(initialMeetingTime);

    // Pre-fill department if available
    if (widget.outdoorModel!.departmentId > 0) {
      _selectedDepartmentNotifier.value = [
        {
          "zAttributesId": widget.outdoorModel!.departmentId,
          "DisplayName": widget.outdoorModel!.departmentName,
        },
      ];
    }

      if (widget.outdoorModel!.accompaniedById.isNotEmpty) {
        final employeeId = int.tryParse(widget.outdoorModel!.accompaniedById);
        if (employeeId != null && employeeId > 0) {
          _selectedEmployeeNotifier.value = [
            {
              "zAttributesId": employeeId,
              "DisplayName": widget.outdoorModel!.accompaniedByName,
            },
          ];
        }
      }

      // Pre-fill visiting card file if available
      if (widget.outdoorModel!.visitingCardUrl.isNotEmpty) {
        visitingCardFile.fileNameList = [widget.outdoorModel!.visitingCardUrl];
      }
    }

  // LOAD DEPARTMENTS INITIALLY
  Future<void> _loadDepartments() async {
    if (_outdoorCubit.state.departmentList.isEmpty) {
      await _outdoorCubit.getDepartmentList(context, 1, 12);
    }
  }

  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    final totalCount = _outdoorCubit.state.departmentTotalCount;
    final pageSize = 12;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final departmentList = _outdoorCubit.state.departmentList;
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

    final currentLoadedCount = _outdoorCubit.state.departmentList.length;

    // Always call API if list is empty or if we need more data
    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _outdoorCubit.getDepartmentList(context, pageNumber, pageSize);
    }

    final departmentList = _outdoorCubit.state.departmentList;

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

  Future<Map<String, dynamic>> _fetchEmployee(
    int pageNumber,
    String departmentName, {
    String? value,
  }) async {
    final totalCount = _outdoorCubit.state.employeeTotalCount;
    final pageSize = 12;

    // SEARCH MODE
    if (value != null && value.isNotEmpty) {
      // Filter employees by current department (API filters server-side, but ensure client-side too)
      final employeeList =
          departmentName.isEmpty
              ? _outdoorCubit.state.employeeList
              : _outdoorCubit.state.employeeList
                  .where((emp) => emp.department == departmentName)
                  .toList();
      final filteredEmployees =
          employeeList
              .where(
                (emp) =>
                    emp.fullName.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final emp in filteredEmployees) {
        uniqueFiltered[emp.employeeId] = {
          "zAttributesId": emp.employeeId,
          "DisplayName": emp.fullName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    // Filter employees by current department to get accurate count
    final currentDeptEmployees =
        departmentName.isEmpty
            ? _outdoorCubit.state.employeeList
            : _outdoorCubit.state.employeeList
                .where((emp) => emp.department == departmentName)
                .toList();
    final currentLoadedCount = currentDeptEmployees.length;

    // Always call API if list is empty or if we need more data for this department
    if (currentLoadedCount == 0 || currentLoadedCount < totalCount) {
      await _outdoorCubit.getEmployeeListByDepartment(
        context,
        pageNumber,
        pageSize,
        departmentName.isEmpty ? '' : departmentName,
      );
    }

    // Get employees filtered by current department
    final employeeList =
        departmentName.isEmpty
            ? _outdoorCubit.state.employeeList
            : _outdoorCubit.state.employeeList
                .where((emp) => emp.department == departmentName)
            .toList();

    final Map<int, Map<String, dynamic>> uniqueEmployees = {};

    for (final emp in employeeList) {
      uniqueEmployees[emp.employeeId] = {
        "zAttributesId": emp.employeeId,
        "DisplayName": emp.fullName,
      };
    }

    return {
      "itemList": uniqueEmployees.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueEmployees.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Outdoor",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Outdoor" : "Add Outdoor",
              style: AppTextStyle.ts14M(),
            ),
            verticalSpacing(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: commonCardDecoration(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
                    const SizedBox(height: 10),
              CustomDatePicker(
                title: 'Outdoor Date',
                isRequired: true,
                initialDate: outdoorDate,
                validator: (value) {
                  if (value == null) {
                    return 'Outdoor Date is required';
                  }
                  return null;
                },
                setValue: (value) => outdoorDate = value,
              ),
              CustomTimePicker(
                setValue: (value) {
                  meetingTime = formatTimeOfDayHHmm(value);
                        initialMeetingTime = value;
                },
                title: "Meeting Time",
                isRequired: true,
                      initialTime: initialMeetingTime,
                validator: (value) {
                  if (value == null) {
                    return "Meeting Time is required";
                  }
                  return null;
                },
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
                            // Clear employee list and selection first, before updating department
                            _outdoorCubit.clearEmployeeList();
                            _selectedEmployeeNotifier.value = [];
                            // Then update department
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
                      valueListenable: _selectedDepartmentNotifier,
                      builder: (context, selectedDept, child) {
                        return ValueListenableBuilder<
                          List<Map<String, dynamic>>
                        >(
                          valueListenable: _selectedEmployeeNotifier,
                          builder: (context, selectedEmp, child) {
                            return CustomMultipleSelectPopup(
                              title: "Accompanied By",
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedEmp,
                              dataFetchCallBack:
                                  (pageNumber, {String? value}) =>
                                      _fetchEmployee(
                                        pageNumber,
                                        selectedDept.isNotEmpty
                                            ? selectedDept.first['DisplayName']
                                                as String
                                            : 'No Department',
                                        value: value,
                                      ),
                              onSelected: (value) {
                                _selectedEmployeeNotifier.value = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Employee is required';
                                }
                                return null;
                              },
                            );
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: 'Purpose',
                      hint: "Enter Purpose",
                      textController: _purposeC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Purpose is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Company Name',
                      hint: "Enter Company Name",
                      textController: _companyNameC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Company Name is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Company Address',
                      hint: "Enter Company Address",
                      textController: _companyAddressC,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Company Address is required';
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Visiting Card",
                      initialFileList: visitingCardFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        visitingCardFile.fileNameList = fileNameList;
                        visitingCardFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        visitingCardFile.fileBytesList = fileBytesList;
                        visitingCardFile.fileNameList = fileNameList;
                        visitingCardFile.deletedFileList = deleted;
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
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 16,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update Outdoor" : "Add Outdoor",
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }

  // HANDLE SUBMIT
  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate required fields
    if (outdoorDate == null) {
      showErrorMessage(context, 'Error', 'Outdoor Date is required');
      return;
    }

    if (meetingTime == null || meetingTime!.isEmpty) {
      showErrorMessage(context, 'Error', 'Meeting Time is required');
      return;
    }

    if (_selectedDepartmentNotifier.value.isEmpty) {
      showErrorMessage(context, 'Error', 'Department is required');
      return;
    }

    if (_selectedEmployeeNotifier.value.isEmpty) {
      showErrorMessage(context, 'Error', 'Employee is required');
      return;
    }

    final departmentId = _selectedDepartmentNotifier.value.first['zAttributesId'].toString();
    final employeeId = _selectedEmployeeNotifier.value.first['zAttributesId'].toString();

    // Format date and time
    final formattedDate = outdoorDate!.toIso8601String();
    final formattedTime = meetingTime!;

    if (_isEditMode && widget.outdoorModel != null) {
      // UPDATE MODE
      _outdoorCubit.updateOutdoor(
        index: widget.index,
        context: context,
        outdoorId: widget.outdoorModel!.outdoorId.toString(),
        uniquekey: widget.outdoorModel!.uniquekey,
        outDoorDate: formattedDate,
        outDoorTime: formattedTime,
        departmentId: departmentId,
        companyName: _companyNameC.text.trim(),
        companyAddress: _companyAddressC.text.trim(),
        purpose: _purposeC.text.trim(),
        accompaniedById: employeeId,
        visitingCardFile: visitingCardFile,
      );
    } else {
      // ADD MODE
      _outdoorCubit.addOutdoor(
        context: context,
        outDoorDate: formattedDate,
        outDoorTime: formattedTime,
        departmentId: departmentId,
        companyName: _companyNameC.text.trim(),
        companyAddress: _companyAddressC.text.trim(),
        purpose: _purposeC.text.trim(),
        accompaniedById: employeeId,
        visitingCardFile: visitingCardFile,
      );
    }
  }
}
