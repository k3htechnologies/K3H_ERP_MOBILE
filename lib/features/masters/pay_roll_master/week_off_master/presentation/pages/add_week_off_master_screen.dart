import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  late TextEditingController _weekOffNameC, _weekOffCodeC;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectWeekDays = [];
  List<Map<String, dynamic>> _selectWeekDayStartOn = [];
  List<Map<String, dynamic>> _selectWeekOff = [];
  List<Map<String, dynamic>> _selectWeekOff2 = [];
  List<Map<String, dynamic>> _selectWeeklyOff2Type = [];
  List<Map<String, dynamic>> _selectNotApplicableForMonth = [];

  late ValueNotifier<bool> _showWeeklyOff2Type;

  List<Map<String, dynamic>> allMonthsList = [
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
  final List<Map<String, dynamic>> allDaysList = [
    {"zAttributesId": 1, "DisplayName": "Sunday"},
    {"zAttributesId": 2, "DisplayName": "Monday"},
    {"zAttributesId": 3, "DisplayName": "Tuesday"},
    {"zAttributesId": 4, "DisplayName": "Wednesday"},
    {"zAttributesId": 5, "DisplayName": "Thursday"},
    {"zAttributesId": 6, "DisplayName": "Friday"},
    {"zAttributesId": 7, "DisplayName": "Saturday"},
  ];

  final List<Map<String, dynamic>> weekDaysList = [
    {"zAttributesId": 1, "DisplayName": "1"},
    {"zAttributesId": 2, "DisplayName": "2"},
    {"zAttributesId": 3, "DisplayName": "3"},
    {"zAttributesId": 4, "DisplayName": "4"},
    {"zAttributesId": 5, "DisplayName": "5"},
    {"zAttributesId": 6, "DisplayName": "6"},
  ];

  final List<Map<String, dynamic>> weeklyOff2Type = [
    {"zAttributesId": 1, "DisplayName": "Every"},
    {"zAttributesId": 2, "DisplayName": "Alt(2,4)"},
    {"zAttributesId": 3, "DisplayName": "Alt(1,3)"},
    {"zAttributesId": 4, "DisplayName": "1st"},
    {"zAttributesId": 5, "DisplayName": "2nd"},
    {"zAttributesId": 6, "DisplayName": "3rd"},
    {"zAttributesId": 7, "DisplayName": "4th"},
    {"zAttributesId": 8, "DisplayName": "5th"},
  ];

  @override
  void initState() {
    super.initState();
    _weekOffMasterCubit = context.read<WeekOffMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addWeekOffMaster] ??
        AuthorizationModel();
    _initializeTextEditingControllers();
    _showWeeklyOff2Type = ValueNotifier(false);
    if (_isEditMode) {
      _populateFormFields(widget.weekOffMasterModel!);
      _showWeeklyOff2Type.value = _selectWeekOff2.isNotEmpty;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _weekOffNameC.dispose();
    _weekOffCodeC.dispose();
    _showWeeklyOff2Type.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _weekOffNameC = TextEditingController();
    _weekOffCodeC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(WeekOffMasterModel weekOffMaster) {
    _selectWeekDays =
        weekDaysList
            .where(
              (day) => day["DisplayName"] == weekOffMaster.weekDays.toString(),
            )
            .toList();

    _selectWeekOff =
        allDaysList
            .where((day) => day["DisplayName"] == weekOffMaster.weeklyOff)
            .toList();

    _selectWeekDayStartOn =
        allDaysList
            .where(
              (day) => day["DisplayName"] == weekOffMaster.weekDaysStartsOn,
            )
            .toList();

    _selectWeekOff2 =
        weekOffMaster.weeklyOff2.trim().isEmpty
            ? []
            : allDaysList
                .where((day) => day["DisplayName"] == weekOffMaster.weeklyOff2)
                .toList();

    _selectWeeklyOff2Type =
        weekOffMaster.weeklyOff2Type.trim().isEmpty
            ? []
            : weeklyOff2Type
                .where(
                  (type) =>
                      type["DisplayName"] ==
                      weekOffMaster.weeklyOff2Type.trim(),
                )
                .toList();

    final selectedMonthNames =
        weekOffMaster.notApplicableForMonths
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet();

    _selectNotApplicableForMonth =
        allMonthsList
            .where((month) => selectedMonthNames.contains(month["DisplayName"]))
            .toList();

    _weekOffNameC.text = weekOffMaster.weekOffPolicyName;
    _weekOffCodeC.text = weekOffMaster.weekOffPolicyCode;
  }

  String get selectedMonthNames => _selectNotApplicableForMonth
      .map((month) => month["DisplayName"])
      .join(",");

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weekDays =
        _selectWeekDays.isEmpty ? "" : _selectWeekDays.first['DisplayName'];

    final weekDaysStartsOn =
        _selectWeekDayStartOn.isEmpty
            ? ""
            : _selectWeekDayStartOn.first['DisplayName'];

    final weeklyOff =
        _selectWeekOff.isEmpty ? "" : _selectWeekOff.first['DisplayName'];

    final weeklyOff2 =
        _selectWeekOff2.isEmpty ? "" : _selectWeekOff2.first['DisplayName'];

    final weeklyOff2Type =
        _selectWeekOff2.isEmpty || _selectWeeklyOff2Type.isEmpty
            ? ""
            : _selectWeeklyOff2Type.first['DisplayName'];

    if (_isEditMode) {
      _weekOffMasterCubit.updateWeekOff(
        index: widget.index,
        context: context,
        weekOffPolicyMasterId: widget.weekOffMasterModel!.weekOffPolicyMasterId,
        uniqueKey: widget.weekOffMasterModel!.uniqueKey,
        weekOffPolicyCode: _weekOffCodeC.text.trim(),
        weekOffPolicyName: _weekOffNameC.text.trim(),
        weekDays: int.parse(weekDays),
        weekDaysStartsOn: weekDaysStartsOn,
        weeklyOff: weeklyOff,
        weeklyOff2: weeklyOff2,
        weeklyOff2Type: weeklyOff2Type,
        notApplicableForMonths: selectedMonthNames,
      );
    } else {
      _weekOffMasterCubit.addWeekOff(
        context: context,
        weekOffPolicyCode: _weekOffCodeC.text.trim(),
        weekOffPolicyName: _weekOffNameC.text.trim(),
        weekDays: int.parse(weekDays),
        weekDaysStartsOn: weekDaysStartsOn,
        weeklyOff: weeklyOff,
        weeklyOff2: weeklyOff2,
        weeklyOff2Type: weeklyOff2Type,
        notApplicableForMonths: selectedMonthNames,
      );
    }
  }

  String _getSelectedDisplayName(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return '';
    return list.first["DisplayName"]?.toString().trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Week Off Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Week Off" : "Add Week Off",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Week Off Policy Details",
                      style: AppTextStyle.ts14M(),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: "Week Off Name",
                      textController: _weekOffNameC,
                      hint: "Enter Week Off Name",
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      keyboardType: TextInputType.text,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Week Off Policy Name is required";
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
                          return "Week Off Code is required";
                        }

                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: 'Weekdays',
                      isRequired: true,
                      isMultiSelect: false,
                      hintText: "Select Weekdays",
                      initialValue: _selectWeekDays,
                      onSelected: (value) {
                        _selectWeekDays = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weekdays is required';
                        }
                        return null;
                      },
                      dataFetchCallBack: (int pageNumber, {String? value}) {
                        //  Filter based on search value
                        final filteredList =
                            value == null || value.isEmpty
                                ? weekDaysList
                                : weekDaysList
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
                      title: 'Weekday Starts On',
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectWeekDayStartOn,
                      onSelected: (value) {
                        _selectWeekDayStartOn = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weekday Starts On is required';
                        }

                        return null;
                      },
                      dataFetchCallBack: (int pageNumber, {String? value}) {
                        final filteredList =
                            value == null || value.isEmpty
                                ? allDaysList
                                : allDaysList
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Week Off Details", style: AppTextStyle.ts14M()),
                    verticalSpacing(),
                    CustomMultipleSelectPopup(
                      title: 'Week Off 1',
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectWeekOff,
                      onSelected: (value) {
                        _selectWeekOff = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Week Off 1 is required';
                        }

                        final weekOff1 =
                            value.first["DisplayName"]?.toString().trim() ?? '';
                        final weekDayStartOn = _getSelectedDisplayName(
                          _selectWeekDayStartOn,
                        );
                        final weekOff2 = _getSelectedDisplayName(
                          _selectWeekOff2,
                        );

                        if (weekDayStartOn.isNotEmpty &&
                            weekOff1 == weekDayStartOn) {
                          return "Week day start on & Week off 1 can't be the same";
                        }

                        if (weekOff2.isNotEmpty && weekOff1 == weekOff2) {
                          return "Weekly Off 2 must be different from Weekly Off 1";
                        }

                        return null;
                      },
                      dataFetchCallBack: (int pageNumber, {String? value}) {
                        final filteredList =
                            value == null || value.isEmpty
                                ? allDaysList
                                : allDaysList
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
                      title: 'Week Off 2',
                      isMultiSelect: false,
                      initialValue: _selectWeekOff2,
                      onSelected: (value) {
                        _selectWeekOff2 = value;
                        _showWeeklyOff2Type.value = _selectWeekOff2.isNotEmpty;

                        if (_selectWeekOff2.isEmpty) {
                          _selectWeeklyOff2Type.clear();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }

                        final weekOff2 =
                            value.first["DisplayName"]?.toString().trim() ?? '';
                        final weekDayStartOn = _getSelectedDisplayName(
                          _selectWeekDayStartOn,
                        );
                        final weekOff1 = _getSelectedDisplayName(
                          _selectWeekOff,
                        );

                        if (weekDayStartOn.isNotEmpty &&
                            weekOff2 == weekDayStartOn) {
                          return "Week day start on & Week off 2 can't be the same";
                        }

                        if (weekOff1.isNotEmpty && weekOff2 == weekOff1) {
                          return 'Weekly Off 2 must be different from Weekly Off 1';
                        }

                        return null;
                      },
                      dataFetchCallBack: (int pageNumber, {String? value}) {
                        final filteredList =
                            value == null || value.isEmpty
                                ? allDaysList
                                : allDaysList
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

                    ValueListenableBuilder<bool>(
                      valueListenable: _showWeeklyOff2Type,
                      builder: (context, showWeeklyOff2Type, child) {
                        return Visibility(
                          visible: showWeeklyOff2Type,
                          child: CustomMultipleSelectPopup(
                            title: 'Weekly Off2 Type',
                            isRequired: _selectWeekOff2.isNotEmpty,
                            isMultiSelect: false,
                            initialValue: _selectWeeklyOff2Type,
                            onSelected: (value) {
                              _selectWeeklyOff2Type = value;
                            },
                            validator: (value) {
                              if (_selectWeekOff2.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Weekly Off2 Type is required';
                              }
                              return null;
                            },
                            dataFetchCallBack: (
                              int pageNumber, {
                              String? value,
                            }) {
                              final filteredList =
                                  value == null || value.isEmpty
                                      ? weeklyOff2Type
                                      : weeklyOff2Type
                                          .where(
                                            (type) => type["DisplayName"]
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
                        );
                      },
                    ),

                    CustomMultipleSelectPopup(
                      title: 'Not Applicable For Months',
                      isMultiSelect: true,
                      initialValue: _selectNotApplicableForMonth,
                      onSelected: (value) {
                        _selectNotApplicableForMonth = value;
                      },

                      dataFetchCallBack: (int pageNumber, {String? value}) {
                        //  Filter based on search value
                        final filteredList =
                            (value == null || value.isEmpty)
                                ? allMonthsList
                                : allMonthsList
                                    .where(
                                      (month) => month["DisplayName"]
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
