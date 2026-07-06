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
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
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
  late TextEditingController _valueC, _minSalaryC, _maxSalaryC;

  bool get _isEditMode => widget.deductionMasterModel != null;

  // INITIALIZE TEXT EDITING CONTROLLERS
  Map<int, List<CityModel>>? groupedStateData = {};
  List<Map<String, dynamic>>? stateList = [];
  List<Map<String, dynamic>>? selectedStateList = [];
  // GENDER LIST
  List<Map<String, dynamic>> genderList = [
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];
  // NAME LIST
  List<Map<String, dynamic>> nameList = [
    {"DisplayName": 'Provident Fund', "zAttributesId": 1},
    {"DisplayName": 'Professional Tax', "zAttributesId": 2},
    {"DisplayName": "Tax Deduction at Source", "zAttributesId": 3},
    {"DisplayName": 'Labor Welfare Fund', "zAttributesId": 4},
    {"DisplayName": 'ESI', "zAttributesId": 5},
    {"DisplayName": 'Labour WaleFare Fund', "zAttributesId": 6},
    {"DisplayName": 'National Pension Scheme', "zAttributesId": 7},
    {"DisplayName": 'Health Insurance Premiums', "zAttributesId": 8},
  ];
  // TYPES LIST
  List<Map<String, dynamic>> typesList = [
    {"DisplayName": "Basic Salary", "zAttributesId": 1},
    {"DisplayName": "HRA", "zAttributesId": 2},
    {"DisplayName": "DA", "zAttributesId": 3},

    {"DisplayName": "Conveyance Allowance", "zAttributesId": 4},
    {"DisplayName": "Medical Allowance", "zAttributesId": 5},
    {"DisplayName": "Special Allowance", "zAttributesId": 6},
    {"DisplayName": "Other Allowance", "zAttributesId": 7},
    {"DisplayName": "LTA", "zAttributesId": 8},

    {"DisplayName": "Performance Bonus", "zAttributesId": 9},
    {"DisplayName": "Incentive", "zAttributesId": 10},
    {"DisplayName": "Variable Pay", "zAttributesId": 11},
    {"DisplayName": "Annual Bonus", "zAttributesId": 12},
    {"DisplayName": "Joining Bonus", "zAttributesId": 13},
    {"DisplayName": "Retention Bonus", "zAttributesId": 14},
    {"DisplayName": "Mobile Reimbursement", "zAttributesId": 15},
    {"DisplayName": "Internet Reimbursement", "zAttributesId": 16},
    {"DisplayName": "Fuel Reimbursement", "zAttributesId": 17},
    {"DisplayName": "Food Allowance", "zAttributesId": 18},
    {"DisplayName": "Shift Allowance", "zAttributesId": 19},
    {"DisplayName": "Night Shift Allowance", "zAttributesId": 20},
    {"DisplayName": "City Compensatory Allowance", "zAttributesId": 21},
    {"DisplayName": "Employer PF", "zAttributesId": 22},
    {"DisplayName": "Employer ESI", "zAttributesId": 23},
    {"DisplayName": "Gratuity", "zAttributesId": 24},
    {"DisplayName": "Superannuation", "zAttributesId": 25},
    {"DisplayName": "NPS Employer", "zAttributesId": 26},
    {"DisplayName": "Health Insurance", "zAttributesId": 27},
    {"DisplayName": "Overtime Pay", "zAttributesId": 28},
    {"DisplayName": "Leave Encashment", "zAttributesId": 29},
    {"DisplayName": "Arrears", "zAttributesId": 30},
    {"DisplayName": "Ex-Gratia", "zAttributesId": 31},
    {"DisplayName": "Relocation Allowance", "zAttributesId": 32},
  ];

  // SELECTED VALUES
  Map<String, dynamic>? selectedGender;
  List<Map<String, dynamic>> selectedNameList = [];
  List<Map<String, dynamic>> selectedTypeList = [];
  List<Map<String, dynamic>>? selectedBranch = [];

  late ValueNotifier<String> applicableType;

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    apiCallPullCountryStateCityDistrictVillage();
    _deductionMasterCubit = context.read<DeductionMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    if (_isEditMode && widget.deductionMasterModel != null) {
      final model = widget.deductionMasterModel!;

      applicableType = ValueNotifier(
        (model.applicable).toLowerCase().trim() == 'percentage'
            ? 'Percentage'
            : 'Lumpsum',
      );

      _populateFormFields(model);
    } else {
      applicableType = ValueNotifier("Percentage");
    }
  }

  @override
  void dispose() {
    super.dispose();
    applicableType.dispose();
    _disposeTextEditingControllers();
  }

  // DISPOSE TEXT EDITING CONTROLLERS
  void _disposeTextEditingControllers() {
    _valueC.dispose();
    _minSalaryC.dispose();
    _maxSalaryC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _valueC = TextEditingController();
    _minSalaryC = TextEditingController();
    _maxSalaryC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(DeductionMasterModel deductionMasterModel) {
    _valueC.text = deductionMasterModel.value.toString();
    _minSalaryC.text = deductionMasterModel.minSalary.toString();
    _maxSalaryC.text = deductionMasterModel.maxSalary.toString();
    selectedGender =
        genderList
            .where(
              (item) =>
                  item['DisplayName'].toString().toLowerCase().trim() ==
                  (deductionMasterModel.gender).toLowerCase().trim(),
            )
            .firstOrNull;
    selectedNameList = [
      nameList.firstWhere(
        (item) => item['DisplayName'] == deductionMasterModel.name,
        orElse: () => nameList.first,
      ),
    ];
    if (deductionMasterModel.type.isNotEmpty) {
      selectedTypeList = [
        typesList.firstWhere(
          (item) => item['DisplayName'] == deductionMasterModel.type,
          orElse: () => typesList.first,
        ),
      ];
    }
    if (deductionMasterModel.branchName.isNotEmpty) {
      selectedBranch = [
        {
          "zAttributesId": deductionMasterModel.branchMasterId,
          "DisplayName": deductionMasterModel.branchName,
        },
      ];
    }

    if (deductionMasterModel.stateName.isNotEmpty) {
      selectedStateList = [
        {
          "zAttributesId": deductionMasterModel.stateMasterId,
          "DisplayName": deductionMasterModel.stateName,
        },
      ];
    }
    applicableType.value =
        (deductionMasterModel.applicable).toLowerCase().trim() == 'percentage'
            ? 'Percentage'
            : 'Lumpsum';
  }

  // API CALL FOR PULL COUNTRY STATE CITY DISTRICT VILLAGE
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

      groupedStateData?.forEach((key, value) {
        stateList?.add({
          "zAttributesId": key,
          "DisplayName": value[0].stateName,
        });
      });

      setState(() {});
    } catch (error) {
      ErrorHandler.getErrorMessage(error);
    }
  }

  // FETCH STATIC DEDUCTION NAMES
  Future<Map<String, dynamic>> _fetchStaticDeductionNames(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? nameList
            : nameList
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

  // FETCH STATIC DEDUCTION TYPES
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

  // FETCH STATES
  Future<Map<String, dynamic>> _fetchStates(
    int pageNumber, {
    String? value,
  }) async {
    final filteredList =
        value == null || value.isEmpty
            ? stateList
            : stateList
                ?.where(
                  (e) => e["DisplayName"].toString().toLowerCase().contains(
                    value.toLowerCase(),
                  ),
                )
                .toList();

    return {
      "itemList": filteredList,
      "totalNumberOfRecord": filteredList?.length,
    };
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final int? branchId =
        (selectedBranch != null && selectedBranch!.isNotEmpty)
            ? selectedBranch!.first['zAttributesId'] as int
            : null;

    final int? stateId =
        (selectedStateList != null && selectedStateList!.isNotEmpty)
            ? selectedStateList!.first['zAttributesId'] as int
            : null;

    final String? genderValue =
        (selectedGender != null && selectedGender!['zAttributesId'] != -1)
            ? selectedGender!['DisplayName'].toString()
            : null;

    final String? typeValue =
        selectedTypeList.isNotEmpty
            ? selectedTypeList.first['DisplayName'].toString()
            : null;
    if (_isEditMode && widget.deductionMasterModel != null) {
      _deductionMasterCubit.updateDeduction(
        index: widget.index,
        context: context,
        deductionMasterId: widget.deductionMasterModel!.deductionMasterId,
        uniqueKey: widget.deductionMasterModel!.uniquekey,
        name: selectedNameList.first['DisplayName'].toString(),
        type: typeValue ?? "",
        applicable: applicableType.value,
        value: double.parse(_valueC.text),
        branchMasterId: branchId,
        stateMasterId: stateId,
        minSalary: double.parse(_minSalaryC.text),
        maxSalary: double.parse(_maxSalaryC.text),
        gender: genderValue,
      );
    } else {
      _deductionMasterCubit.addDeductionMapping(
        context: context,
        name: selectedNameList.first['DisplayName'].toString(),
        type: typeValue ?? "",
        applicable: applicableType.value,
        value: double.parse(_valueC.text),
        branchMasterId: branchId,
        stateMasterId: stateId,
        minSalary: double.parse(_minSalaryC.text),
        maxSalary: double.parse(_maxSalaryC.text),
        gender: genderValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Deduction Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Basic Deduction Details", style: AppTextStyle.ts16SB()),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultipleSelectPopup(
                      initialValue: selectedNameList,
                      hintText: "Select Name",
                      title: "Name",
                      isRequired: true,
                      dataFetchCallBack: _fetchStaticDeductionNames,
                      isMultiSelect: false,
                      dataList: nameList,
                      onSelected: (value) {
                        setState(() {
                          selectedNameList = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Deduction Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedTypeList,
                      title: "Type",
                      hintText: "Select Type",
                      isRequired: false,
                      dataFetchCallBack: _fetchStaticDeductionTypes,
                      isMultiSelect: false,
                      dataList: typesList,
                      onSelected: (value) {
                        selectedTypeList = value;
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Applicable",
                              style: AppTextStyle.ts14R(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              "*",
                              style: AppTextStyle.ts14R(color: AppColor.error),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder<String>(
                          valueListenable: applicableType,
                          builder: (context, value, _) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    applicableType.value = "Percentage";
                                    _valueC.clear();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color:
                                          value == "Percentage"
                                              ? AppColor.lightBlue
                                              : Colors.transparent,
                                      border: Border.all(
                                        color: AppColor.grey,
                                        width: .5,
                                      ),
                                    ),
                                    child: Text(
                                      "Percentage",
                                      style: AppTextStyle.ts12R(
                                        color:
                                            value == "Percentage"
                                                ? AppColor.primary
                                                : AppColor.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    applicableType.value = "Lumpsum";
                                    _valueC.clear();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color:
                                          value == "Lumpsum"
                                              ? AppColor.lightBlue
                                              : Colors.transparent,
                                      border: Border.all(
                                        color: AppColor.grey,
                                        width: .5,
                                      ),
                                    ),
                                    child: Text(
                                      "Lumpsum",
                                      style: AppTextStyle.ts12R(
                                        color:
                                            value == "Lumpsum"
                                                ? AppColor.primary
                                                : AppColor.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<String>(
                      valueListenable: applicableType,
                      builder: (context, value, _) {
                        return CustomTextField(
                          textController: _valueC,
                          hint:
                              value == "Percentage"
                                  ? "Enter Percentage (%)"
                                  : "Enter Amount",
                          title:
                              value == "Percentage"
                                  ? "Value (%)"
                                  : "Value (Lumpsum)",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          inputFormatterList:
                              value == "Percentage"
                                  ? [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                    LengthLimitingTextInputFormatter(5),
                                  ]
                                  : [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                          validator: (valueText) {
                            if (valueText == null || valueText.trim().isEmpty) {
                              return "Value is required";
                            }

                            if (value == "Percentage") {
                              final val = double.tryParse(valueText) ?? 0;
                              if (val > 100) {
                                return "Percentage cannot exceed 100";
                              }
                            }

                            return null;
                          },
                        );
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
                    CustomMultipleSelectPopup(
                      initialValue:
                          selectedGender != null ? [selectedGender!] : [],
                      title: "Gender",
                      hintText: "Select Gender",
                      isMultiSelect: false,
                      dataFetchCallBack: (
                        int pageNumber, {
                        String? value,
                      }) async {
                        final filteredList =
                            value == null || value.isEmpty
                                ? genderList
                                : genderList
                                    .where(
                                      (e) => e["DisplayName"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase()),
                                    )
                                    .toList();

                        return {
                          "itemList": filteredList,
                          "totalNumberOfRecord": filteredList.length,
                        };
                      },
                      dataList: genderList,
                      onSelected: (value) {
                        selectedGender = value.isNotEmpty ? value.first : null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedStateList,
                      title: "State Name",
                      hintText: "Select State",
                      isMultiSelect: false,
                      dataFetchCallBack: _fetchStates,
                      dataList: stateList,
                      onSelected: (value) {
                        selectedStateList = value;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      initialValue: selectedBranch,
                      title: "Branch Name",
                      hintText: "Select Branch",
                      dataFetchCallBack: _fetchBranch,
                      isMultiSelect: false,
                      dataList: [],
                      onSelected: (value) {
                        selectedBranch = value;
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
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(_isEditMode ? Icons.edit : Icons.add, size: 16),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () => _submitForm(),
          ),
        ),
      ),
    );
  }
}
