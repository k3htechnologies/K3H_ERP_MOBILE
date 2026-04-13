import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddEventDetailsScreen extends StatefulWidget {
  const AddEventDetailsScreen({super.key});

  @override
  State<AddEventDetailsScreen> createState() => _AddEventDetailsScreenState();
}

class _AddEventDetailsScreenState extends State<AddEventDetailsScreen> {
  late CalendarCubit _calendarCubit;

  // TEXT CONTROLLER
  late TextEditingController _titleC, _remarkC;

  // TYPE LIST
  List<Map<String, dynamic>> typeList = [
    {'zAttributesId': '1', 'DisplayName': 'Task'},
    {'zAttributesId': '2', 'DisplayName': 'Meeting'},
    {'zAttributesId': '3', 'DisplayName': 'Conference Room Booking'},
  ];

  // TYPE LIST
  List<Map<String, dynamic>> priorityList = [
    {'zAttributesId': '1', 'DisplayName': 'Low'},
    {'zAttributesId': '2', 'DisplayName': 'Medium'},
    {'zAttributesId': '3', 'DisplayName': 'High'},
  ];

  // ROOM LIST
  List<Map<String, dynamic>> roomList = [
    {'zAttributesId': '-1', 'DisplayName': 'Select Room'},
    {'zAttributesId': '1', 'DisplayName': '13 Floor Meeting Room 1'},
    {'zAttributesId': '2', 'DisplayName': '13 Floor Meeting Room 2'},
    {'zAttributesId': '3', 'DisplayName': '14 Floor Meeting Room 1'},
    {'zAttributesId': '4', 'DisplayName': '14 Floor Meeting Room 2'},
    {'zAttributesId': '5', 'DisplayName': '14 Floor Big Conference'},
  ];

  // INITIAL VALUE
  ValueNotifier<Map<String, dynamic>?> selectedType = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedPriority = ValueNotifier(null);
  Map<String, dynamic>? selectedRoom;
  DateTime? selectedDate;
  DateTime? selectedDeadline;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  List<Map<String, dynamic>> _selectedMembers = [];
  List<Map<String, dynamic>> _selectedDepartments = [];
  Map<String, dynamic> _selectedProjects = {};
  MultiFilePickerModel selectedDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _calendarCubit = context.read<CalendarCubit>();
    initialiseValue();
  }

  @override
  void dispose() {
    super.dispose();
    _titleC.dispose();
    _remarkC.dispose();
  }

  // INITIALISE VALUE
  void initialiseValue() {
    _titleC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // CHECK IF END TIME IS AFTER START TIME
  bool isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Calendar",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Details', style: AppTextStyle.ts16SB()),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: StatefulBuilder(
                  builder: (_, innerState) {
                    return Form(
                      key: _formKey,
                      child: ValueListenableBuilder(
                        valueListenable: selectedType,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              CustomDropDownWidget(
                                title: "Select Type",
                                hintText: "Select Type",
                                initialValue: selectedType.value,
                                isRequired: true,
                                dataList: typeList,
                                onSelected: (value) {
                                  innerState(() {
                                    selectedType.value = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Select valid type";
                                  }
                                  return null;
                                },
                                onValueClear: () {
                                  selectedType.value = null;
                                },
                              ),
                              CustomTextField(
                                textController: _titleC,
                                title:
                                    selectedType.value?["zAttributesId"] == "1"
                                        ? "Task Title"
                                        : selectedType
                                                .value?["zAttributesId"] ==
                                            "2"
                                        ? "Meeting Title"
                                        : selectedType
                                                .value?["zAttributesId"] ==
                                            "3"
                                        ? "Conference Room Title"
                                        : "Add Title",
                                isRequired: true,
                                hint: "Enter title",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter valid title";
                                  }
                                  return null;
                                },
                              ),
                              CustomMultipleSelectPopup(
                                title: "Select Project",
                                initialValue:
                                    _selectedProjects.isNotEmpty &&
                                            _selectedProjects.containsKey(
                                              "zAttributesId",
                                            )
                                        ? [_selectedProjects]
                                        : [],
                                dataFetchCallBack:
                                    _calendarCubit.getProjectList,
                                isMultiSelect: false,
                                dataList: [],
                                onSelected: (values) {
                                  if (values.isNotEmpty &&
                                      values[0].isNotEmpty) {
                                    _selectedProjects = values[0];
                                  } else {
                                    _selectedProjects = {};
                                  }
                                },
                              ),
                              CustomMultipleSelectPopup(
                                title: "Select Department",
                                initialValue:
                                    _selectedDepartments.isNotEmpty
                                        ? _selectedDepartments
                                        : [],
                                dataFetchCallBack:
                                    _calendarCubit.getDepartmentList,
                                isMultiSelect: true,
                                dataList: [],
                                onSelected: (values) {
                                  _selectedDepartments = values;
                                },
                              ),
                              CustomMultipleSelectPopup(
                                title: "Select Members",
                                initialValue: _selectedMembers,
                                dataFetchCallBack:
                                    _calendarCubit.getMembersList,
                                dataList: [],
                                onSelected: (values) {
                                  _selectedMembers = values;
                                },
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] == "1",
                                child: CustomDatePicker(
                                  title: "Deadline",
                                  isRequired: true,
                                  setValue: (value) {
                                    selectedDeadline = value;
                                  },
                                  validator: (value) {
                                    if (selectedType.value?["zAttributesId"] ==
                                            "1" &&
                                        value == null) {
                                      return "Please select deadline";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] == "1",
                                child: CustomTimePicker(
                                  title: "End Time",
                                  isRequired: true,
                                  initialTime: selectedStartTime,
                                  setValue: (time) {
                                    selectedStartTime = time;
                                  },
                                  validator: (value) {
                                    if (selectedType.value?["zAttributesId"] ==
                                            "1" &&
                                        value == null) {
                                      return "Select valid end time";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] == "1",
                                child: ValueListenableBuilder(
                                  valueListenable: selectedPriority,
                                  builder: (context, value, child) {
                                    return CustomDropDownWidget(
                                      title: "Select Priority",
                                      hintText: "Select Priority",
                                      isRequired: true,
                                      initialValue: value,
                                      dataList: priorityList,
                                      onSelected: (value) {
                                        innerState(() {
                                          selectedPriority.value = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (selectedType
                                                    .value?["zAttributesId"] ==
                                                "1" &&
                                            (value == null ||
                                                value["zAttributesId"] ==
                                                    "-1")) {
                                          return "Please select priority";
                                        }
                                        return null;
                                      },
                                      onValueClear: () {
                                        selectedPriority.value = null;
                                      },
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] == "1",
                                child: CustomMultiFilePicker(
                                  title: "Upload Documents",
                                  onFilePickedCallback: (bytes, fileName) {
                                    selectedDocument.fileBytesList = bytes;
                                    selectedDocument.fileNameList = fileName;
                                  },
                                  onFileDeleteCallback: (
                                    bytes,
                                    fileName,
                                    deletedFiles,
                                  ) {
                                    selectedDocument.fileBytesList = bytes;
                                    selectedDocument.fileNameList = fileName;
                                    selectedDocument.deletedFileList =
                                        deletedFiles;
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] ==
                                        "2" ||
                                    selectedType.value?["zAttributesId"] == "3",
                                child: CustomDatePicker(
                                  title:
                                      "Select ${selectedType.value?["zAttributesId"] == "2" ? "Meeting Date" : "Conference Date"}",
                                  hint: "DD/MM/YY",
                                  isRequired: true,
                                  setValue: (value) {
                                    selectedDate = value;
                                  },
                                  validator: (value) {
                                    if ((selectedType.value?["zAttributesId"] ==
                                                "2" ||
                                            selectedType
                                                    .value?["zAttributesId"] ==
                                                "3") &&
                                        value == null) {
                                      return "Please select date";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] ==
                                        "2" ||
                                    selectedType.value?["zAttributesId"] == "3",
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Expanded(
                                      child: CustomTimePicker(
                                        title: "Start Time",
                                        isRequired: true,
                                        initialTime: selectedStartTime,
                                        setValue: (time) {
                                          selectedStartTime = time;
                                        },
                                        validator: (value) {
                                          if ((selectedType
                                                          .value?["zAttributesId"] ==
                                                      "2" ||
                                                  selectedType
                                                          .value?["zAttributesId"] ==
                                                      "3") &&
                                              value == null) {
                                            return "Select valid start time";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTimePicker(
                                        title: "End Time",
                                        isRequired: true,
                                        initialTime: selectedEndTime,
                                        setValue: (time) {
                                          selectedEndTime = time;
                                        },
                                        validator: (value) {
                                          if ((selectedType
                                                          .value?["zAttributesId"] ==
                                                      "2" ||
                                                  selectedType
                                                          .value?["zAttributesId"] ==
                                                      "3") &&
                                              value == null) {
                                            return "Select valid end time";
                                          }

                                          if (selectedStartTime == null) {
                                            return "Select start time first";
                                          }

                                          if (value != null &&
                                              !isEndTimeAfterStart(
                                                selectedStartTime!,
                                                value,
                                              )) {
                                            return "End time must be greater than start time";
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible:
                                    selectedType.value?["zAttributesId"] == "3",
                                child: CustomDropDownWidget(
                                  title: "Select Room",
                                  isRequired: true,
                                  initialValue: selectedRoom,
                                  dataList: roomList,
                                  onSelected: (value) {
                                    innerState(() {
                                      selectedRoom = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (selectedType.value?["zAttributesId"] ==
                                            "3" &&
                                        (value == null ||
                                            value["zAttributesId"] == "-1")) {
                                      return "Please select room";
                                    }
                                    return null;
                                  },
                                  onValueClear: () {
                                    print("Selected Room :  $selectedRoom");
                                    selectedRoom = null;
                                    print("Selected Room :  $selectedRoom");
                                  },
                                ),
                              ),
                              CustomTextField(
                                textController: _remarkC,
                                title:
                                    selectedType.value?["zAttributesId"] == "1"
                                        ? "Task Description"
                                        : selectedType
                                                .value?["zAttributesId"] ==
                                            "2"
                                        ? "Meeting Description"
                                        : selectedType
                                                .value?["zAttributesId"] ==
                                            "3"
                                        ? "Conference Room Description"
                                        : "Description",
                                hint: "Enter description",
                                minLines: 3,
                                maxLines: 3,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColor.white,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: CustomButton(
            text: "Add",
            backgroundColor: AppColor.primary,
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              // Validate that either department or member must be selected
              final hasDepartments =
                  _selectedDepartments.isNotEmpty &&
                  _selectedDepartments.any(
                    (dept) =>
                        dept["zAttributesId"] != -1 &&
                        dept["zAttributesId"] != "-1" &&
                        dept["zAttributesId"] != null,
                  );
              final hasMembers =
                  _selectedMembers.isNotEmpty &&
                  _selectedMembers.any(
                    (member) =>
                        member["zAttributesId"] != -1 &&
                        member["zAttributesId"] != "-1" &&
                        member["zAttributesId"] != null,
                  );

              if (!hasDepartments && !hasMembers) {
                showErrorMessage(
                  context,
                  "Validation Error",
                  "Please select at least one department or member",
                );
                return;
              }

              final typeId = selectedType.value?["zAttributesId"];

              // Convert type ID to type name
              String eventType = "";
              if (typeId == "1") {
                eventType = "Task";
              } else if (typeId == "2") {
                eventType = "Meeting";
              } else if (typeId == "3") {
                eventType = "Conference Room Booking";
              }

              // Convert departments list to comma-separated string
              String departmentsStr = _selectedDepartments
                  .map((dept) => dept["zAttributesId"].toString())
                  .where((id) => id != "-1")
                  .join(",");

              // Convert members list to comma-separated string
              String membersStr = _selectedMembers
                  .map((member) => member["zAttributesId"].toString())
                  .where((id) => id != "-1")
                  .join(",");

              // Get project ID
              String projectId = "";
              if (_selectedProjects.isNotEmpty &&
                  _selectedProjects.containsKey("zAttributesId")) {
                projectId =
                    _selectedProjects["zAttributesId"]?.toString() ?? "";
              }

              // Format date for task deadline or meeting/conference date
              String dateStr = "";
              String deadlineStr = "";
              if (typeId == "1") {
                deadlineStr = selectedDeadline?.toIso8601String() ?? "";
              } else if (typeId == "2" || typeId == "3") {
                dateStr = selectedDate?.toIso8601String() ?? "";
              }

              // Format time strings in HH:mm format (24-hour format)
              String startTimeStr = "";
              String endTimeStr = "";

              if ((typeId == "1" || typeId == "2" || typeId == "3") &&
                  selectedStartTime != null) {
                startTimeStr = formatTimeOfDayHHmm(selectedStartTime!);
              }

              // end time for 1,2,3
              if ((typeId == "2" || typeId == "3") && selectedEndTime != null) {
                endTimeStr = formatTimeOfDayHHmm(selectedEndTime!);
              }

              // Get priority
              String priorityStr =
                  typeId == "1"
                      ? (selectedPriority.value?["DisplayName"]?.toString() ??
                          "")
                      : "";

              // Get room
              String roomStr =
                  typeId == "3" ? (selectedRoom?["DisplayName"] ?? "") : "";

              // Call the add event API
              _calendarCubit.addEvent(
                context: context,
                type: eventType,
                title: _titleC.text.trim(),
                projects: projectId,
                departments: departmentsStr,
                members: membersStr,
                date: dateStr,
                deadlineDate: deadlineStr,
                startTime: startTimeStr,
                endTime: endTimeStr,
                room: roomStr,
                priority: priorityStr,
                description: _remarkC.text.trim(),
                document: selectedDocument,
              );
            },
          ),
        ),
      ),
    );
  }
}
