import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDeductionMasterScreen extends StatefulWidget {
  final DeductionMasterModel? deductionMasterModel;
  final int index;
  const AddDeductionMasterScreen({
    super.key,
    this.deductionMasterModel,
    this.index = 0,
  });

  @override
  State<AddDeductionMasterScreen> createState() =>
      _AddDeductionMasterScreenState();
}

class _AddDeductionMasterScreenState extends State<AddDeductionMasterScreen> {
  // CUBIT
  late DeductionMasterCubit _deductionMasterCubit;

  // BASE CLIENT
  final BaseClient _baseClient = BaseClient();

  // REPOSITORY
  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _nameC, _valueC, _minSalaryC, _maxSalaryC;

  bool get _isEditMode => widget.deductionMasterModel != null;

  // INITIALIZE TEXT EDITING CONTROLLERS
  Map<int, List<CityModel>> groupedStateData = {};
  List<Map<String, dynamic>> stateList = [];
  List<Map<String, dynamic>> selectedStateList = [];
  // GENDER LIST
  List<Map<String, dynamic>> genderList = [
    {"zAttributesId": -1, "DisplayName": "Select Gender"},
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];

  // TYPES LIST
  List<Map<String, dynamic>> typesList = [
    {"DisplayName": "Provident Fund", "zAttributesId": 1},
    {"DisplayName": "Professional Tax", "zAttributesId": 2},
    {"DisplayName": "Tax Deducted at Source", "zAttributesId": 3},
    {"DisplayName": "Labour Welfare", "zAttributesId": 4},
    {"DisplayName": "ESI", "zAttributesId": 5},
    {"DisplayName": "Labour Welfare Fund", "zAttributesId": 6},
    {"DisplayName": "National Pension Scheme", "zAttributesId": 7},
    {"DisplayName": "National Pension Scheme", "zAttributesId": 8},
    {"DisplayName": "Health Insurance Premiums", "zAttributesId": 9},
  ];

  // SELECTED VALUES
  Map<String, dynamic>? selectedGender;
  List<Map<String, dynamic>> selectedTypeList = [];
  List<Map<String, dynamic>> selectedBranch = [];

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    apiCallPullCountryStateCityDistrictVillage();
    _deductionMasterCubit = context.read<DeductionMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    selectedGender = genderList.first;
    if (_isEditMode && widget.deductionMasterModel != null) {
      _populateFormFields(widget.deductionMasterModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposeTextEditingControllers();
  }

  void _disposeTextEditingControllers() {
    _nameC.dispose();
    _valueC.dispose();
    _minSalaryC.dispose();
    _maxSalaryC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _nameC = TextEditingController();
    _valueC = TextEditingController();
    _minSalaryC = TextEditingController();
    _maxSalaryC = TextEditingController();
  }

  void _populateFormFields(DeductionMasterModel deductionMasterModel) {
    _nameC.text = deductionMasterModel.name;
    _valueC.text = deductionMasterModel.value.toString();
    _minSalaryC.text = deductionMasterModel.minSalary.toString();
    _maxSalaryC.text = deductionMasterModel.maxSalary.toString();
    selectedGender = genderList.firstWhere(
      (item) => item['DisplayName'] == deductionMasterModel.gender,
      orElse: () => genderList.first,
    );
    selectedTypeList = [
      typesList.firstWhere(
        (item) => item['DisplayName'] == deductionMasterModel.type,
        orElse: () => typesList.first,
      ),
    ];
    selectedBranch = [
      {
        "zAttributesId": deductionMasterModel.branchMasterId,
        "DisplayName": deductionMasterModel.branchName,
      },
    ];

    selectedStateList = [
      {
        "zAttributesId": deductionMasterModel.stateMasterId,
        "DisplayName": deductionMasterModel.stateName,
      },
    ];
  }

  Future apiCallPullCountryStateCityDistrictVillage() async {
    String pullCountryStateCityDistrictVillage =
        'Static/PullCountryStateCityDistrictVillage';

    try {
      var networkResponse = await _baseClient.getRequestWithAuthentication(
        pullCountryStateCityDistrictVillage,
      );

      var dataList = List<CityModel>.from(
        networkResponse['data']["CountryStateCityDistrictVillageData"].map(
          (e) => CityModel.fromJson(e),
        ),
      );

      groupedStateData = groupBy(dataList, (e) => e.stateMasterId);

      groupedStateData.forEach((key, value) {
        stateList.add({
          "zAttributesId": key,
          "DisplayName": value[0].stateName,
        });
      });

      setState(() {});
    } catch (error) {
      ErrorHandler.getErrorMessage(error);
    }
  }

  Future<Map<String, dynamic>> _fetchStaticDeductionTypes(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? typesList
            : typesList
                .where(
                  (e) => e["DisplayName"].toString().toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {
      "itemList": filteredList,
      "totalNumberOfRecord": filteredList.length,
    };
  }

  Future<Map<String, dynamic>> _fetchBranch(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _branchMasterRepository.getBranchList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"BranchName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final assets = response['data'] as List<BranchMasterModel>;

        return {
          "itemList":
              assets.map((asset) {
                return {
                  "zAttributesId": asset.branchMasterId,
                  "DisplayName": asset.branchName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<Map<String, dynamic>> _fetchStates(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? stateList
            : stateList
                .where(
                  (e) => e["DisplayName"].toString().toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {
      "itemList": filteredList,
      "totalNumberOfRecord": filteredList.length,
    };
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (selectedTypeList.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select deduction type');
      return;
    }
    if (selectedStateList.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select state');
      return;
    }
    if (selectedBranch.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select branch');
      return;
    }
    if (_isEditMode && widget.deductionMasterModel != null) {
      _deductionMasterCubit.updateDeduction(
        index: widget.index,
        context: context,
        deductionMasterId: widget.deductionMasterModel!.deductionMasterId,
        uniqueKey: widget.deductionMasterModel!.uniquekey,
        name: _nameC.text.trim(),
        type: selectedTypeList.first['DisplayName'].toString(),
        value: double.parse(_valueC.text),
        branchMasterId: selectedBranch.first['zAttributesId'] as int,
        stateMasterId: selectedStateList.first['zAttributesId'] as int,
        minSalary: double.parse(_minSalaryC.text),
        maxSalary: double.parse(_maxSalaryC.text),
        gender: selectedGender!['DisplayName'].toString(),
      );
    } else {
      _deductionMasterCubit.addDeductionMapping(
        context: context,
        name: _nameC.text.trim(),
        type: selectedTypeList.first['DisplayName'].toString(),
        value: double.parse(_valueC.text),
        branchMasterId: selectedBranch.first['zAttributesId'] as int,
        stateMasterId: selectedStateList.first['zAttributesId'] as int,
        minSalary: double.parse(_minSalaryC.text),
        maxSalary: double.parse(_maxSalaryC.text),
        gender: selectedGender!['DisplayName'].toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Deduction",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Deduction" : "Add Deduction",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      textController: _nameC,
                      hint: "Enter Deduction Name",
                      title: "Deduction Name",
                      inputFormatterList: InputValidator.textDigit(200),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Deduction Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedTypeList,
                      title: "Deduction Type",
                      isRequired: true,
                      dataFetchCallBack: _fetchStaticDeductionTypes,
                      isMultiSelect: false,
                      dataList: typesList,
                      onSelected: (value) {
                        setState(() {
                          selectedTypeList = value;
                        });
                      },
                    ),
                    CustomTextField(
                      textController: _valueC,
                      hint: "Enter Deduction Value",
                      title: "Deduction Value",
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Deduction Value is required";
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: 'Gender',
                      isRequired: true,
                      initialValue: selectedGender,
                      dataList: genderList,
                      onSelected: (value) => selectedGender = value,
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Gender is required';
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedStateList,
                      title: "State",
                      isRequired: true,
                      isMultiSelect: false,
                      dataFetchCallBack: _fetchStates,
                      dataList: stateList,
                      onSelected: (value) {
                        setState(() {
                          selectedStateList = value;
                        });
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedBranch,
                      title: "Branch",
                      isRequired: true,
                      dataFetchCallBack: _fetchBranch,
                      isMultiSelect: false,
                      dataList: [],
                      onSelected: (value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                    ),
                    CustomTextField(
                      textController: _minSalaryC,
                      title: "Min Salary",
                      hint: "Enter Min Salary",
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (p0) {
                        if (_minSalaryC.text.isEmpty) {
                          return 'Min Salary is required';
                        }
                        return null;
                      },
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    CustomTextField(
                      textController: _maxSalaryC,
                      title: "Max Salary",
                      hint: "Enter Max Salary",
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (p0) {
                        if (_maxSalaryC.text.isEmpty) {
                          return 'Max Salary is required';
                        }
                        return null;
                      },
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
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
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Deduction" : "Add Deduction",
            onPressed: () => _submitForm(),
          ),
        ),
      ),
    );
  }
}
