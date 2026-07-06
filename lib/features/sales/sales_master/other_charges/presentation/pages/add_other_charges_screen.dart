import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/presentation/cubit/other_charges_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddOtherChargesScreen extends StatefulWidget {
  final OtherChargeModel? otherChargeModel;
  final int index;
  final int projectId;
  const AddOtherChargesScreen({
    super.key,
    this.otherChargeModel,
    required this.index,
    required this.projectId,
  });

  @override
  State<AddOtherChargesScreen> createState() => _AddOtherChargesScreenState();
}

class _AddOtherChargesScreenState extends State<AddOtherChargesScreen> {
  // CUBIT
  late OtherChargesCubit _otherChargesCubit;

  // FORM Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLER
  late TextEditingController _chargeNameC,
      _valueC,
      _gstPercentageC,
      _gstValueC,
      _totalValuePlusGst;

  // SELECTED VALUES
  final ValueNotifier<Map<String, dynamic>?> _selectedCalculatedOnNotifier =
  ValueNotifier(null);

  List<Map<String, dynamic>> calculatedOnList = [
    {"zAttributesId": 1, "DisplayName": "Per Sq Ft"},
    {"zAttributesId": 2, "DisplayName": "Lumpsum"},
  ];

  final ValueNotifier<double> _gstValueNotifier = ValueNotifier<double>(0.0);

  //EDIT MODE
  bool get _isEditMode => widget.otherChargeModel != null;

  @override
  void initState() {
    super.initState();
    _otherChargesCubit = context.read<OtherChargesCubit>();
    _initializeTextController();
    _valueC.addListener(_calculateGST);
    _gstPercentageC.addListener(_calculateGST);
    if (_isEditMode) {
      _prefillForm(widget.otherChargeModel!);
    }
  }

  @override
  void dispose() {
    _valueC.removeListener(_calculateGST);
    _gstPercentageC.removeListener(_calculateGST);

    _chargeNameC.dispose();
    _valueC.dispose();
    _gstPercentageC.dispose();
    _gstValueC.dispose();
    _gstValueNotifier.dispose();
    _totalValuePlusGst.dispose();
    _selectedCalculatedOnNotifier.dispose();
    super.dispose();
  }

  // CALCULATE GST VALUE
  void _calculateGST() {
    final value = double.tryParse(_valueC.text) ?? 0.0;
    final gstPercent = double.tryParse(_gstPercentageC.text) ?? 0.0;
    final gst = (value * gstPercent) / 100;
    _gstValueNotifier.value = gst;
    _gstValueC.text = gst.toStringAsFixed(2);
    _totalValuePlusGst.text = (gst + value).toStringAsFixed(2);
  }

  // INITIALIZE TEXT CONTROLLER
  void _initializeTextController() {
    _chargeNameC = TextEditingController();
    _valueC = TextEditingController();
    _gstPercentageC = TextEditingController();
    _gstValueC = TextEditingController();
    _totalValuePlusGst = TextEditingController();
  }

  // PREFILL FORM
  void _prefillForm(OtherChargeModel otherChargeModel) {
    _chargeNameC.text = otherChargeModel.chargeName;
    _valueC.text = otherChargeModel.value.toString();
    _gstPercentageC.text = otherChargeModel.gstPercentage.toString();
    _gstValueC.text = otherChargeModel.gstValue.toString();
    _selectedCalculatedOnNotifier.value = calculatedOnList.firstWhere(
          (item) => item['DisplayName'] == otherChargeModel.calculatedOn,
      orElse: () => calculatedOnList.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Other Charges",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              !_isEditMode ? "Add Charges" : "Update Charges",
              style: AppTextStyle.ts16SB(),
            ),
            verticalSpacing(),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Charge Name",
                      isRequired: true,
                      hint: "Enter Charge Name",
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      textController: _chargeNameC,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Charge Name";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Value (in ₹)",
                      isRequired: true,
                      hint: "Enter Value",
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(10),
                      textController: _valueC,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Value";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedCalculatedOnNotifier,
                      builder: (context, selectedValue, _) {
                        return CustomDropDownWidget(
                          title: "Calculated On",
                          isRequired: true,
                          hintText: "Select Calculated On",
                          initialValue: selectedValue,
                          dataList: calculatedOnList,
                          onSelected: (value) {
                            _selectedCalculatedOnNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Calculated On is required';
                            }
                            return null;
                          },
                          onValueClear: () {
                            _selectedCalculatedOnNotifier.value = null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "GST (in %)",
                      isRequired: true,
                      hint: "Enter GST %",
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.percentage(),
                      textController: _gstPercentageC,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter GST %";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _gstValueNotifier,
                      builder: (context, gst, _) {
                        return CustomTextField(
                          key: ValueKey(gst),
                          readOnly: true,
                          title: "GST Value (in ₹)",
                          hint: "0",
                          textController: _gstValueC,
                          validator: (value) {
                            if ((double.tryParse(value ?? '') ?? 0) <= 0) {
                              return "GST Value must be greater than 0";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      readOnly: true,
                      title: "Value + GST Value (₹)",
                      hint: "0",
                      textController: _totalValuePlusGst,
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
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_isEditMode) {
                  _otherChargesCubit.updateOtherCharges(
                    context: context,
                    otherChargesId: widget.otherChargeModel!.otherChargesId,
                    uniqueKey: widget.otherChargeModel!.uniquekey,
                    projectId: widget.projectId,
                    chargeName: _chargeNameC.text,
                    calculatedOn: _selectedCalculatedOnNotifier.value?['DisplayName']??"",
                    value: double.parse(_valueC.text),
                    gstPercentage: double.parse(_gstPercentageC.text),
                    gstValue: double.parse(_gstValueC.text),
                    index: widget.index,
                  );
                } else {
                  _otherChargesCubit.addOtherCharges(
                    context: context,
                    projectId: widget.projectId,
                    chargeName: _chargeNameC.text,
                    calculatedOn: _selectedCalculatedOnNotifier.value?['DisplayName']??"",
                    value: double.parse(_valueC.text),
                    gstPercentage: double.parse(_gstPercentageC.text),
                    gstValue: double.parse(_gstValueC.text),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
