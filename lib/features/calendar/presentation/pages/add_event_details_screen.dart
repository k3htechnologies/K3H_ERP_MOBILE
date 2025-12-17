import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddEventDetailsScreen extends StatefulWidget {
  const AddEventDetailsScreen({super.key});

  @override
  State<AddEventDetailsScreen> createState() => _AddEventDetailsScreenState();
}

class _AddEventDetailsScreenState extends State<AddEventDetailsScreen> {
  late CalendarCubit _calendarCubit;

  // TEXT CONTROLLER
  late TextEditingController _titleC, _projectC, _remarkC;

  // TYPE LIST
  List<Map<String, dynamic>> typeList = [
    {'zAttributesId': '-1', 'DisplayName': 'Select Type'},
    {'zAttributesId': '1', 'DisplayName': 'Task'},
    {'zAttributesId': '2', 'DisplayName': 'Meeting'},
    {'zAttributesId': '3', 'DisplayName': 'Conference Room'},
  ];

  // TYPE LIST
  List<Map<String, dynamic>> priorityList = [
    {'zAttributesId': '-1', 'DisplayName': 'Select Priority'},
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
  late Map<String, dynamic> selectedType;
  late Map<String, dynamic> selectedPriority;
  late Map<String, dynamic> selectedRoom;
  DateTime? selectedDate;
  DateTime? selectedDeadline;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  List<Map<String, dynamic>> _selectedMembers = [];
  List<Map<String, dynamic>> _selectedDepartments = [];
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
    selectedType = typeList.first;
    selectedPriority = priorityList.first;
    selectedRoom = roomList.first;
    _titleC = TextEditingController();
    _projectC = TextEditingController();
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
      appBar: CustomAppBarWithBackButton(screenTitle: "Add Details",authorization: AuthorizationModel(),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (_, innerState) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomDropDownWidget(
                      title: "Select Type",
                      initialValue: selectedType,
                      isRequired: true,
                      dataList: typeList,
                      onSelected: (value) {
                        innerState(() {
                          selectedType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == "-1") {
                          return "Select valid type";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _titleC,
                      title:
                          selectedType["zAttributesId"] == "1"
                              ? "Task Title"
                              : selectedType["zAttributesId"] == "2"
                              ? "Meeting Title"
                              : selectedType["zAttributesId"] == "3"
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
                    CustomTextField(
                      title: "Select Project",
                      textController: _projectC,
                      hint: "Enter project",
                    ),
                    CustomMultipleSelectPopup(
                      title: "Select Department",
                      initialValue: _selectedDepartments,
                      dataFetchCallBack: _calendarCubit.getDepartmentList,
                      dataList: [],
                      onSelected: (values) {
                        _selectedDepartments = values;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Select Members",
                      initialValue: _selectedMembers,
                      dataFetchCallBack: _calendarCubit.getMembersList,
                      dataList: [],
                      onSelected: (values) {
                        _selectedMembers = values;
                      },
                    ),
                    Visibility(
                      visible: selectedType["zAttributesId"] == "1",
                      child: CustomDatePicker(
                        title: "Deadline",
                        setValue: (value) {
                          selectedDeadline = value;
                        },
                      ),
                    ),
                    Visibility(
                      visible: selectedType["zAttributesId"] == "1",
                      child: CustomDropDownWidget(
                        title: "Select Priority",
                        initialValue: selectedPriority,
                        dataList: priorityList,
                        onSelected: (value) {
                          innerState(() {
                            selectedPriority = value;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: selectedType["zAttributesId"] == "1",
                      child: CustomMultiFilePicker(
                        title: "Upload Documents",
                        onFilePickedCallback: (bytes, fileName) {
                          selectedDocument.fileBytesList = bytes;
                          selectedDocument.fileNameList = fileName;
                        },
                        onFileDeleteCallback: (bytes, fileName, deletedFiles) {
                          selectedDocument.fileBytesList = bytes;
                          selectedDocument.fileNameList = fileName;
                          selectedDocument.deletedFileList = deletedFiles;
                        },
                      ),
                    ),
                    Visibility(
                      visible:
                          selectedType["zAttributesId"] == "2" ||
                          selectedType["zAttributesId"] == "3",
                      child: CustomDatePicker(
                        title:
                            "Select ${selectedType["zAttributesId"] == "2" ? "Meeting Date" : "Conference Date"}",
                        hint: "DD/MM/YY",
                        setValue: (value) {
                          selectedDate = value;
                        },
                      ),
                    ),
                    Visibility(
                      visible:
                          selectedType["zAttributesId"] == "2" ||
                          selectedType["zAttributesId"] == "3",
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomTimePicker(
                              title: "Start Time",
                              initialTime: selectedStartTime,
                              setValue: (time) {
                                selectedStartTime = time;
                              },
                              // validator: (value) {
                              //   if (value == null) {
                              //     return "Select valid start time";
                              //   }
                              //   return null;
                              // },
                            ),
                          ),
                          Expanded(
                            child: CustomTimePicker(
                              title: "End Time",
                              initialTime: selectedEndTime,
                              setValue: (time) {
                                selectedEndTime = time;
                              },
                              // validator: (value) {
                              //   if (value == null) {
                              //     return "Select valid end time";
                              //   }
                              //
                              //   if (selectedStartTime == null) {
                              //     return "Select start time first";
                              //   }
                              //
                              //   if (!isEndTimeAfterStart(
                              //     selectedStartTime!,
                              //     value,
                              //   )) {
                              //     return "End time must be greater than start time";
                              //   }
                              //
                              //   return null;
                              // },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible:
                          selectedType["zAttributesId"] == "2" ||
                          selectedType["zAttributesId"] == "3",
                      child: CustomDropDownWidget(
                        title: "Select Room",
                        initialValue: selectedRoom,
                        dataList: roomList,
                        onSelected: (value) {
                          selectedRoom = value;
                        },
                      ),
                    ),
                    CustomTextField(
                      textController: _remarkC,
                      title:
                          selectedType["zAttributesId"] == "1"
                              ? "Task Description"
                              : selectedType["zAttributesId"] == "2"
                              ? "Meeting Description"
                              : selectedType["zAttributesId"] == "3"
                              ? "Conference Room Description"
                              : "Description",
                      hint: "Enter description",
                      minLines: 3,
                      maxLines: 3,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomButton.add(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              final typeId = selectedType["zAttributesId"];

              if ((typeId == "2" || typeId == "3") && selectedDate == null) {
                print("Please select date");
                return;
              }

              if ((typeId == "2" || typeId == "3") &&
                  (selectedStartTime == null || selectedEndTime == null)) {
                print("Please select start and end time");
                return;
              }

              if ((typeId == "1" ) && selectedDeadline==null) {
                print("Please select deadline");
                return;
              }

              if ((typeId == "1" ) && selectedPriority["zAttributesId"]=="-1") {
                print("Please select priority");
                return;
              }

              if (typeId == "3" && selectedRoom['zAttributedId'] == "-1") {
                print("Please select room");
                return;
              }

              final Map<String, String> payload = {
                "typeId": typeId ?? "",
                "title": _titleC.text,
                "project": _projectC.text,
                "departments": "",
                "members": "",
                "deadline": typeId == "1"
                    ? (selectedDeadline?.toIso8601String() ?? "")
                    : "",
                "priorityId": typeId == "1"
                    ? (selectedPriority["zAttributesId"] ?? "")
                    : "",
                "date": (typeId == "2" || typeId == "3")
                    ? (selectedDate?.toIso8601String() ?? "")
                    : "",
                "startTime": (typeId == "2" || typeId == "3")
                    ? (selectedStartTime != null
                    ? selectedStartTime!.format(context)
                    : "")
                    : "",
                "endTime": (typeId == "2" || typeId == "3")
                    ? (selectedEndTime != null
                    ? selectedEndTime!.format(context)
                    : "")
                    : "",
                "roomId": typeId == "3"
                    ? (selectedRoom["DisplayName"] ?? "")
                    : "",
                "description": _remarkC.text.trim(),
              };

              debugPrint("FORM PAYLOAD → $payload");
            },
          ),
        ),
      ),
    );
  }
}
