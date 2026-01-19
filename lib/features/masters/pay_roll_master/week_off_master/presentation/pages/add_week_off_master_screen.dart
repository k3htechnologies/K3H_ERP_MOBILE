import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddWeekOffMasterScreen extends StatefulWidget {
  final WeekOffMasterModel? weekOffMasterModel;
  final int index;
  const AddWeekOffMasterScreen({
    super.key,
    required this.weekOffMasterModel,
    this.index = 0,
  });

  @override
  State<AddWeekOffMasterScreen> createState() => _AddWeekOffMasterScreenState();
}

class _AddWeekOffMasterScreenState extends State<AddWeekOffMasterScreen> {
  //CUBIT
  late WeekOffMasterCubit _weekOffMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  //EDIT MODE
  bool get _isEditMode => widget.weekOffMasterModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _weekOffNameC,
      _weekOffCodeC,
      _weekDaysC,
      _weekOff2TypeC,
      _weekDaysStartsOnC;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectWeekOff = [];
  List<Map<String, dynamic>> _selectWeekOff2 = [];
  List<Map<String, dynamic>> _selectNotApplicableForMonth = [];
  List<Map<String, dynamic>> allMonths = [
    {"zAttributesId": 1, "DisplayName": "January"},
    {"zAttributesId": 2, "DisplayName": "February"},
    {"zAttributesId": 3, "DisplayName": "March"},
    {"zAttributesId": 4, "DisplayName": "April"},
    {"zAttributesId": 5, "DisplayName": "May"},
    {"zAttributesId": 6, "DisplayName": "June"},
    {"zAttributesId": 7, "DisplayName": "July"},
    {"zAttributesId": 8, "DisplayName": "August"},
    {"zAttributesId": 9, "DisplayName": "September"},
    {"zAttributesId": 10, "DisplayName": "October"},
    {"zAttributesId": 11, "DisplayName": "November"},
    {"zAttributesId": 12, "DisplayName": "December"},
  ];
  final List<Map<String, dynamic>> allDays = [
    {"zAttributesId": 1, "DisplayName": "Sunday"},
    {"zAttributesId": 2, "DisplayName": "Monday"},
    {"zAttributesId": 3, "DisplayName": "Tuesday"},
    {"zAttributesId": 4, "DisplayName": "Wednesday"},
    {"zAttributesId": 5, "DisplayName": "Thursday"},
    {"zAttributesId": 6, "DisplayName": "Friday"},
    {"zAttributesId": 7, "DisplayName": "Saturday"},
  ];

  @override
  void initState() {
    super.initState();
    _weekOffMasterCubit = context.read<WeekOffMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addWeekOffMaster] ??
        AuthorizationModel();
    _initializeTextEditingControllers();
    if (_isEditMode) {
      _populateFormFields(widget.weekOffMasterModel!);
    }
  }

  void _populateFormFields(WeekOffMasterModel weekOffMaster) {
    _selectWeekOff = [
      {"DisplayName": weekOffMaster.weeklyOff},
    ];
    _selectWeekOff2 =
        weekOffMaster.weeklyOff2.isEmpty
            ? []
            : [
              {"DisplayName": weekOffMaster.weeklyOff2},
            ];

    _selectNotApplicableForMonth =
        weekOffMaster.notApplicableForMonths
            .split(", ")
            .map((name) => {"DisplayName": name})
            .toList();
    _weekOffNameC.text = weekOffMaster.weekOffPolicyName;
    _weekOffCodeC.text = weekOffMaster.weekOffPolicyCode;
    _weekOff2TypeC.text = weekOffMaster.weeklyOff2Type;
    _weekDaysC.text = weekOffMaster.weekDays.toString();
    _weekDaysStartsOnC.text = weekOffMaster.weekDaysStartsOn;
  }

  String get selectedMonthNames => _selectNotApplicableForMonth
      .map((month) => month["DisplayName"])
      .join(", ");

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectWeekOff.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select a week off');
      return;
    }
    if (_isEditMode) {
      _weekOffMasterCubit.updateWeekOff(
        index: widget.index,
        context: context,
        weekOffPolicyMasterId: widget.weekOffMasterModel!.weekOffPolicyMasterId,
        uniqueKey: widget.weekOffMasterModel!.uniqueKey,
        weekOffPolicyCode: _weekOffCodeC.text.trim(),
        weekOffPolicyName: _weekOffNameC.text.trim(),
        weekDays: int.parse(_weekDaysC.text.trim()),
        weekDaysStartsOn: _weekDaysStartsOnC.text.trim(),
        weeklyOff: _selectWeekOff.first['DisplayName'],
        weeklyOff2:
            _selectWeekOff2.isEmpty ? "" : _selectWeekOff2.first['DisplayName'],
        weeklyOff2Type: _weekOff2TypeC.text.trim(),
        notApplicableForMonths: selectedMonthNames,
      );
    } else {
      _weekOffMasterCubit.addWeekOff(
        context: context,
        weekOffPolicyCode: _weekOffCodeC.text.trim(),
        weekOffPolicyName: _weekOffNameC.text.trim(),
        weekDays: int.parse(_weekDaysC.text.trim()),
        weekDaysStartsOn: _weekDaysStartsOnC.text.trim(),
        weeklyOff: _selectWeekOff.first['DisplayName'],
        weeklyOff2:
            _selectWeekOff2.isEmpty ? "" : _selectWeekOff2.first['DisplayName'],
        weeklyOff2Type: _weekOff2TypeC.text.trim(),
        notApplicableForMonths: selectedMonthNames,
      );
    }
  }

  void _initializeTextEditingControllers() {
    _weekOffNameC = TextEditingController();
    _weekOffCodeC = TextEditingController();
    _weekDaysC = TextEditingController();
    _weekOff2TypeC = TextEditingController();
    _weekDaysStartsOnC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Week Off" : "Add Week Off",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Week Off Name",
                  textController: _weekOffNameC,
                  hint: "Enter Week Off Name",
                  inputFormatterList: [InputValidator.digitAndCharacterOnly()],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Week Off Name is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "Week Off Code",
                  textController: _weekOffCodeC,
                  hint: "Enter Week Off Code",
                  inputFormatterList: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Week Off Code is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "Week Days",
                  textController: _weekDaysC,
                  hint: "Enter Week Days",
                  inputFormatterList: InputValidator.digit(4),
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Week Days is reqiured";
                    }

                    return null;
                  },
                ),
                CustomMultipleSelectPopup(
                  title: 'Week Off',
                  isRequired: true,
                  isMultiSelect: false,
                  initialValue: _selectWeekOff,
                  onSelected: (value) {
                    setState(() {
                      _selectWeekOff = value;
                    });
                  },

                  dataFetchCallBack: (int pageNumber, {String? value}) {
                    //  Filter based on search value
                    final filteredList =
                        value == null || value.isEmpty
                            ? allDays
                            : allDays
                                .where(
                                  (day) => day["DisplayName"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
                                )
                                .toList();

                    return Future.value({
                      "itemList": filteredList,
                      "totalNumberOfRecord": filteredList.length,
                    });
                  },
                ),

                CustomMultipleSelectPopup(
                  title: 'Week Off2',
                  isMultiSelect: false,
                  initialValue: _selectWeekOff2,
                  onSelected: (value) {
                    setState(() {
                      _selectWeekOff2 = value;
                    });
                  },

                  dataFetchCallBack: (int pageNumber, {String? value}) {
                    //  Filter based on search value
                    final filteredList =
                        value == null || value.isEmpty
                            ? allDays
                            : allDays
                                .where(
                                  (day) => day["DisplayName"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
                                )
                                .toList();

                    return Future.value({
                      "itemList": filteredList,
                      "totalNumberOfRecord": filteredList.length,
                    });
                  },
                ),

                CustomTextField(
                  title: "Weekly Off2 Type",
                  textController: _weekOff2TypeC,
                  hint: "Enter Weekly Off2 Type",
                  inputFormatterList: [
                    InputValidator.digitAndCharacterOnly(),
                    LengthLimitingTextInputFormatter(200),
                  ],
                  keyboardType: TextInputType.text,
                ),
                CustomTextField(
                  title: "Week Days Starts On",
                  textController: _weekDaysStartsOnC,
                  isRequired: true,
                  hint: "Enter Week Days Starts On",
                  inputFormatterList: [
                    InputValidator.digitAndCharacterOnly(),
                    LengthLimitingTextInputFormatter(200),
                  ],
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Week Days Starts On is reqiured";
                    }

                    return null;
                  },
                ),
                CustomMultipleSelectPopup(
                  title: 'Not Applicable For Months',
                  isRequired: true,
                  isMultiSelect: true,
                  initialValue:
                      _selectNotApplicableForMonth.isEmpty
                          ? []
                          : allMonths
                              .where(
                                (month) => _selectNotApplicableForMonth
                                    .map((e) => e["DisplayName"])
                                    .contains(month["DisplayName"]),
                              )
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList(),
                  onSelected: (value) {
                    setState(() {
                      _selectNotApplicableForMonth = value;
                    });
                  },

                  dataFetchCallBack: (int pageNumber, {String? value}) {
                    //  Filter based on search value
                    final filteredList =
                        (value == null || value.isEmpty)
                            ? allMonths
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList()
                            : allMonths
                                .where(
                                  (month) => month["DisplayName"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
                                )
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();

                    return Future.value({
                      "itemList": filteredList,
                      "totalNumberOfRecord": filteredList.length,
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Week Off" : "Add Week Off",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
