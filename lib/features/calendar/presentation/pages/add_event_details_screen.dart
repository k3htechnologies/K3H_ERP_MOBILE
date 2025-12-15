import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
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
  // TEXT CONTROLLER
  late TextEditingController _titleC, _remarkC;

  // TYPE LIST
  List<Map<String, dynamic>> typeList = [
    {'zAttributesId': '-1', 'DisplayName': 'Select Type'},
    {'zAttributesId': '1', 'DisplayName': 'Task'},
    {'zAttributesId': '2', 'DisplayName': 'Meeting'},
    {'zAttributesId': '3', 'DisplayName': 'Conference Room'},
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
  late Map<String, dynamic> selectedRoom;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> _selectedMembers = [];
  final List<Map<String, dynamic>> _dummyMembers = const [
    {"zAttributesId": "1", "DisplayName": "Alice"},
    {"zAttributesId": "2", "DisplayName": "Bob"},
    {"zAttributesId": "3", "DisplayName": "Charlie"},
    {"zAttributesId": "4", "DisplayName": "Diana"},
    {"zAttributesId": "5", "DisplayName": "Ethan"},
  ];

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    selectedRoom = roomList.first;
    _titleC = TextEditingController();
    _remarkC = TextEditingController();
  }

  Future<Map<String, dynamic>> getEmployeeDropdownData(
    int pageNumber, {
    String? value,
  }) async {
    // TODO: Replace with API call when backend is ready.
    await Future.delayed(const Duration(milliseconds: 120));
    final filtered =
        value == null || value.isEmpty
            ? _dummyMembers
            : _dummyMembers
                .where(
                  (m) => (m['DisplayName'] as String).toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {"itemList": filtered, "totalNumberOfRecord": filtered.length};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(screenTitle: "Add Details"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomDropDownWidget(
                  title: "Select Type",
                  initialValue: selectedType,
                  isRequired: true,
                  dataList: typeList,
                  onSelected: (value) {
                    selectedType = value;
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
                  title: "Add Title",
                  isRequired: true,
                  hint: "Enter title",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter valid title";
                    }
                    return null;
                  },
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        initialDate: selectedDate,
                        title: "Select Date",
                        isRequired: true,
                        hint: "DD/MM/YYYY",
                        setValue: (value) {
                          selectedDate = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Select valid date";
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomTimePicker(
                        title: "Start Time",
                        isRequired: true,
                        initialTime: selectedTime,
                        setValue: (time) {
                          selectedTime = time;
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Select valid time";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                CustomMultipleSelectPopup(
                  title: "Select Members",
                  initialValue: _selectedMembers,
                  dataFetchCallBack: getEmployeeDropdownData,
                  dataList: _dummyMembers,
                  onSelected: (values) {
                    _selectedMembers = values;
                  },
                ),
                CustomDropDownWidget(
                  title: "Select Room",
                  initialValue: selectedRoom,
                  dataList: roomList,
                  onSelected: (value) {
                    selectedRoom = value;
                  },
                ),
                CustomTextField(
                  textController: _remarkC,
                  title: "Remark",
                  hint: "Enter remark",
                  minLines: 3,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomButton.add(
            onPressed: () {
              if (_formKey.currentState!.validate()) {}
            },
          ),
        ),
      ),
    );
  }
}
