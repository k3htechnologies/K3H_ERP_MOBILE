// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/rent_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RentDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const RentDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<RentDetails> createState() => _RentDetailsState();
}

class _RentDetailsState extends State<RentDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _amountController;
  late TextEditingController _carpetAreaSqFtController;

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _rentStartDate = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _rentEndDate = ValueNotifier<DateTime?>(null);

  // DROPDOWN SELECTIONS
  Map<String, dynamic>? _selectedType;
  Map<String, dynamic>? _selectedTenure;
  Map<String, dynamic>? _selectedUnitSqFtLumsum;

  // BOOLEAN VALUES
  final ValueNotifier<bool> _isAdditionalRent = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPayBrokerage = ValueNotifier<bool>(false);

  // DROPDOWN LISTS
  final List<Map<String, dynamic>> _typeList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Residential"},
    {"zAttributesId": 2, "DisplayName": "Commercial"},
  ];

  // TENURE LIST
  final List<Map<String, dynamic>> _tenureList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Tenure 1"},
    {"zAttributesId": 2, "DisplayName": "Tenure 2"},
    {"zAttributesId": 3, "DisplayName": "Tenure 3"},
    {"zAttributesId": 4, "DisplayName": "Tenure 4"},
    {"zAttributesId": 5, "DisplayName": "Tenure 5"},
  ];

  // UNIT SQ FT LUMSUM LIST
  final List<Map<String, dynamic>> _unitSqFtLumsumList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Per Sq Ft"},
    {"zAttributesId": 2, "DisplayName": "Lump Sum"},
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.pullRentDetails(
        context: context,
        pageNumber: 1,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _carpetAreaSqFtController.dispose();
    _rentStartDate.dispose();
    _rentEndDate.dispose();
    _isAdditionalRent.dispose();
    _isPayBrokerage.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _amountController = TextEditingController();
    _carpetAreaSqFtController = TextEditingController();
  }

  // DIALOGUE TO DELETE RENT DETAILS
  Future<void> _showPopupToDeleteRentDetails(
    BuildContext context,
    RentDetailsModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a rent detail?',
      'Deleting this rent detail will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _cubit.deleteRentDetails(
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferRentDetailsId: obj.proposedOfferRentDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // BOTTOM SHEET TO UPDATE RENT DETAILS
  void __prefillBottomSheetToUpdatedRentDetails(
    RentDetailsModel rentDetailsModel,
  ) {
    _amountController.text = rentDetailsModel.amount.toString();
    _carpetAreaSqFtController.text = rentDetailsModel.carpetAreaSqFt.toString();
    _rentStartDate.value = rentDetailsModel.rentStartDate;
    _rentEndDate.value = rentDetailsModel.rentEndDate;
    _isAdditionalRent.value = rentDetailsModel.isAdditionalRent;
    _isPayBrokerage.value = rentDetailsModel.isPayBrokerage;

    // Prefill dropdowns
    _selectedType = _typeList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.type,
      orElse: () => _typeList.first,
    );

    _selectedTenure = _tenureList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.tenure,
      orElse: () => _tenureList.first,
    );

    _selectedUnitSqFtLumsum = _unitSqFtLumsumList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.unitSqFtLumsum,
      orElse: () => _unitSqFtLumsumList.first,
    );
  }

  // COMMON CARD SECTION
  Widget _buildCardSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts16M()),
          verticalSpacing(height: 16),
          ...children,
        ],
      ),
    );
  }

  // RADIO BUTTON
  Widget _buildRadio({
    required String title,
    required String value,
    required String? groupValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.grey30),
      ),
      child: RadioListTile<String>(
        dense: true,
        activeColor: AppColor.slightDarkBlue,
        title: Text(title),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }

  // BOTTOM SHEET TO ADD RENT DETAILS
  Future<void> _showBottomSheetToAddRentDetails({
    RentDetailsModel? rentDetailsModel,
    int? index,
  }) async {
    if (rentDetailsModel != null) {
      __prefillBottomSheetToUpdatedRentDetails(rentDetailsModel);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Details",
      ValueListenableBuilder<bool>(
        valueListenable: _isAdditionalRent,
        builder: (context, isAdditionalRent, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isPayBrokerage,
            builder: (context, isPayBrokerage, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC DETAILS
                      _buildCardSection("Basic Details", [
                        Row(
                          children: [
                            Expanded(
                              child: _buildRadio(
                                title: "Is Additional Rent",
                                value: 'additional',
                                groupValue:
                                    isAdditionalRent
                                        ? 'additional'
                                        : isPayBrokerage
                                        ? 'brokerage'
                                        : null,
                                onChanged: (val) {
                                  _isAdditionalRent.value = true;
                                  _isPayBrokerage.value = false;
                                },
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: _buildRadio(
                                title: "Is Pay Brokerage",
                                value: 'brokerage',
                                groupValue:
                                    isAdditionalRent
                                        ? 'additional'
                                        : isPayBrokerage
                                        ? 'brokerage'
                                        : null,
                                onChanged: (val) {
                                  _isAdditionalRent.value = false;
                                  _isPayBrokerage.value = true;
                                },
                              ),
                            ),
                          ],
                        ),

                        verticalSpacing(),

                        Row(
                          children: [
                            Expanded(
                              child: CustomDropDownWidget(
                                title: 'Type',
                                isRequired: true,
                                dataList: _typeList,
                                initialValue: _selectedType,
                                onSelected: (v) => _selectedType = v,
                                validator:
                                    (v) =>
                                        v == null || v['zAttributesId'] == -1
                                            ? "Type is required"
                                            : null,
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child:
                                  !isAdditionalRent
                                      ? CustomDropDownWidget(
                                        title: 'Tenure',
                                        isRequired: true,
                                        dataList: _tenureList,
                                        initialValue: _selectedTenure,
                                        onSelected: (v) => _selectedTenure = v,
                                        validator: (v) {
                                          if (isAdditionalRent) return null;
                                          if (v == null ||
                                              v['zAttributesId'] == -1) {
                                            return "Tenure is required";
                                          }
                                          return null;
                                        },
                                      )
                                      : const SizedBox(),
                            ),
                          ],
                        ),
                      ]),

                      // AMOUNT & AREA
                      _buildCardSection("Amount & Area Details*", [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                title: "Amount",
                                isRequired: true,
                                hint: "Enter Amount",
                                textController: _amountController,
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      10,
                                    ),
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? "Amount is required"
                                            : null,
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: CustomDropDownWidget(
                                title: 'Unit Sq Ft Lumsum',
                                isRequired: true,
                                dataList: _unitSqFtLumsumList,
                                initialValue: _selectedUnitSqFtLumsum,
                                onSelected: (v) => _selectedUnitSqFtLumsum = v,
                                validator:
                                    (v) =>
                                        v == null || v['zAttributesId'] == -1
                                            ? "Unit Sq Ft Lumsum is required"
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          title: "Carpet Area Sq Ft",
                          isRequired: true,
                          hint: "Enter Carpet Area Sq Ft",
                          textController: _carpetAreaSqFtController,
                          keyboardType: TextInputType.number,
                          inputFormatterList:
                              inputFormatterListForDecimalValuesFixedToTwo(10),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? "Carpet Area Sq Ft is required"
                                      : null,
                        ),
                      ]),

                      // DATE DETAILS
                      ValueListenableBuilder<DateTime?>(
                        valueListenable: _rentStartDate,
                        builder: (context, rentStartDate, _) {
                          return ValueListenableBuilder<DateTime?>(
                            valueListenable: _rentEndDate,
                            builder: (context, rentEndDate, __) {
                              return _buildCardSection("Date Details*", [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomDatePicker(
                                        title: "Rent Start Date",
                                        isRequired: true,
                                        initialDate: rentStartDate,
                                        startDate: DateTime(2000),
                                        endDate: DateTime(2100),
                                        setValue:
                                            (d) => _rentStartDate.value = d,
                                        validator:
                                            (v) =>
                                                v == null
                                                    ? "Rent Start Date is required"
                                                    : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomDatePicker(
                                        title: "Rent End Date",
                                        isRequired: true,
                                        initialDate: rentEndDate,
                                        startDate: DateTime(2000),
                                        endDate: DateTime(2100),
                                        setValue: (d) => _rentEndDate.value = d,
                                        validator: (v) {
                                          if (v == null) {
                                            return "Rent End Date is required";
                                          }
                                          if (rentStartDate == v) {
                                            return "Dates can't be same";
                                          }
                                          if (rentStartDate != null &&
                                              rentStartDate.isAfter(v)) {
                                            return "End date must be greater";
                                          }
                                          if (isAdditionalRent &&
                                              (v.month !=
                                                      rentStartDate?.month ||
                                                  v.year !=
                                                      rentStartDate?.year)) {
                                            return "Must be same month";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ]);
                            },
                          );
                        },
                      ),

                      verticalSpacing(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomButton(
                          text: "Save",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final startDate = _rentStartDate.value;
                              final endDate = _rentEndDate.value;
                              if (isAdditionalRent &&
                                  (startDate?.month != endDate?.month ||
                                      startDate?.year != endDate?.year)) {
                                showErrorMessage(
                                  context,
                                  "Invalid Dates",
                                  "Dates must be in same month.",
                                );
                                return;
                              }

                              if (isAdditionalRent) {
                                _selectedTenure = {
                                  'zAttributesId': -1,
                                  'zAttributesName': '',
                                };
                              }

                              _onSave(
                                rentDetailsModel: rentDetailsModel,
                                index: index,
                              );

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    _clearDialogueToUpdatedRentDetails();
  }

  // CLEAR DIALOGUE TO UPDATED RENT DETAILS
  void _clearDialogueToUpdatedRentDetails() {
    _selectedType = null;
    _selectedTenure = null;
    _selectedUnitSqFtLumsum = null;
    _amountController.clear();
    _carpetAreaSqFtController.clear();
    _rentStartDate.value = null;
    _rentEndDate.value = null;
    _isAdditionalRent.value = false;
    _isPayBrokerage.value = false;
  }

  // API CALLS TO ADD/UPDATE RENT DETAILS
  Future<void> _addUpdateRentDetails(
    BuildContext context,
    RentDetailsModel? rentDetailsModel,
    ProposedOfferState state,
    int index,
  ) async {
    if (_formKey.currentState!.validate()) {
      rentDetailsModel != null
          ? _cubit.updateRentDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            proposedOfferRentDetailsId:
                rentDetailsModel.proposedOfferRentDetailsId,
            uniqueKey: rentDetailsModel.uniquekey,
            isAdditionalRent: _isAdditionalRent.value,
            type: _selectedType!['DisplayName'],
            tenure: _selectedTenure?['DisplayName'] ?? "",
            amount: double.parse(_amountController.text),
            unitSqFtLumsum: _selectedUnitSqFtLumsum!['DisplayName'],
            carpetAreaSqFt: double.parse(_carpetAreaSqFtController.text),
            rentStartDate: _rentStartDate.value!,
            rentEndDate: _rentEndDate.value!,
            isPayBrokerage: _isPayBrokerage.value,
            index: index,
          )
          : _cubit.addUpdateRentDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            isAdditionalRent: _isAdditionalRent.value,
            type: _selectedType!['DisplayName'],
            tenure: _selectedTenure?['DisplayName'] ?? "",
            amount: double.parse(_amountController.text),
            unitSqFtLumsum: _selectedUnitSqFtLumsum!['DisplayName'],
            carpetAreaSqFt: double.parse(_carpetAreaSqFtController.text),
            rentStartDate: _rentStartDate.value!,
            rentEndDate: _rentEndDate.value!,
            isPayBrokerage: _isPayBrokerage.value,
          );
    }
  }

  // SAVE
  void _onSave({RentDetailsModel? rentDetailsModel, int? index}) {
    if (_formKey.currentState!.validate()) {
      _addUpdateRentDetails(
        context,
        rentDetailsModel,
        _cubit.state,
        index ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            verticalSpacing(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: "Add",
                  leading: Icon(Icons.add, color: AppColor.white),
                  onPressed: () async {
                    await _showBottomSheetToAddRentDetails();
                  },
                ),
              ],
            ),
            verticalSpacing(),
            BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
              builder: (context, state) {
                if (state.isLoading ?? true) {
                  return loader();
                }

                if (state.rentDetails.isEmpty) {
                  return noDataWidget();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.rentDetails.length,
                  itemBuilder: (context, index) {
                    final rent = state.rentDetails[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.grey.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rent.type,
                                    style: AppTextStyle.ts16M(),
                                  ),
                                ),
                                CustomIconButton.edit(
                                  onPressed: () {
                                    _showBottomSheetToAddRentDetails(
                                      rentDetailsModel: rent,
                                      index: index,
                                    );
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.delete(
                                  onPressed: () {
                                    _showPopupToDeleteRentDetails(
                                      context,
                                      rent,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),

                            Divider(
                              color: AppColor.grey.withValues(alpha: 0.4),
                            ),

                            _buildRentInfoRow("Amount", rent.amount.toString()),
                            _buildRentInfoRow("Tenure", rent.tenure.toString()),
                            _buildRentInfoRow(
                              "Unit SqFt Lumsum",
                              rent.unitSqFtLumsum.toString(),
                            ),
                            _buildRentInfoRow(
                              "Carpet Area SqFt",
                              rent.carpetAreaSqFt.toString(),
                            ),
                            _buildRentInfoRow(
                              "Rent Start Date",
                              formatDateTimeAsDDMMMYYYY(rent.rentStartDate),
                            ),
                            _buildRentInfoRow(
                              "Rent End Date",
                              formatDateTimeAsDDMMMYYYY(rent.rentEndDate),
                            ),
                            _buildRentInfoRow(
                              "Pay Brokerage",
                              rent.isPayBrokerage==true ? "Yes" : "No",
                            ),
                            _buildRentInfoRow(
                              "Additional Rent",
                              rent.isAdditionalRent==true?"Yes":"No",
                            ),
                            _buildRentInfoRow(
                              "Last Modified By",
                              rent.modifiedBy.isNotEmpty
                                  ? rent.modifiedBy
                                  : "-",
                            ),
                            _buildRentInfoRow(
                              "Last Modified Date",
                              rent.modifiedDate != null
                                  ? formatDateTimeAsDDMMMYYYY(
                                    rent.modifiedDate!,
                                  )
                                  : "-",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // BUILD RENT INFO ROW
  Widget _buildRentInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          ),
          const Text(": "),
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
