import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ExtraCarpetArea extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const ExtraCarpetArea({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<ExtraCarpetArea> createState() => _ExtraCarpetAreaState();
}

class _ExtraCarpetAreaState extends State<ExtraCarpetArea> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialPercentController;

  late TextEditingController _commercialPercentController;

  // DROPDOWN SELECTIONS
  final ValueNotifier<Map<String, dynamic>?> _selectedExtraCarpetType =
      ValueNotifier(null);

  // DROPDOWN LISTS
  final List<Map<String, dynamic>> _extraCarpetTypeList = [
    {"zAttributesId": 1, "DisplayName": "RERA"},
    {"zAttributesId": 2, "DisplayName": "MOFA"},
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullExtraCarpetArea(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialPercentController.dispose();
    _commercialPercentController.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialPercentController = TextEditingController();
    _commercialPercentController = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var extraCarpetModel = _cubit.state.extraCarpetArea!;

    _residentialPercentController.text =
        extraCarpetModel.residentialExtraCarpetPercent.toString();

    _commercialPercentController.text =
        extraCarpetModel.commercialExtraCarpetPercent.toString();

    _selectedExtraCarpetType.value = _extraCarpetTypeList.firstWhere(
      (e) => e['DisplayName'] == extraCarpetModel.extraCarpetAreaOfferedType,
      orElse: () => _extraCarpetTypeList.first,
    );
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateExtraCarpetArea(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        extraCarpetAreaOfferedType:
            _selectedExtraCarpetType.value!['DisplayName'],
        residentialExtraCarpetPercent: double.parse(
          _residentialPercentController.text,
        ),
        commercialExtraCarpetPercent: double.parse(
          _commercialPercentController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.extraCarpetArea != null) {
            fillData();
          } else {
            _residentialPercentController.clear();
            _commercialPercentController.clear();
            _selectedExtraCarpetType.value = null;
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Extra Carpet Area", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    Text(
                      "Basic Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedExtraCarpetType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Extra Carpet Area Type',
                          hintText: 'Select Extra Carpet Area Type',
                          isRequired: true,
                          dataList: _extraCarpetTypeList,
                          initialValue: value,
                          onSelected: (value) {
                            _selectedExtraCarpetType.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Extra Carpet Area Type is required";
                            }
                            return null;
                          },
                          onValueClear:
                              () => _selectedExtraCarpetType.value = null,
                        );
                      },
                    ),
                    verticalSpacing(),
                    Text(
                      "Percentage Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: "Residential Extra Carpet Percent (%)",
                      isRequired: true,
                      hint: "Enter Residential Extra Carpet Percent (%)",
                      textController: _residentialPercentController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(3),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Residential percentage is required";
                        }
                        if (double.parse(value) > 100) {
                          return "Percentage should be less than 100";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Commercial Extra Carpet Percent (%)",
                      isRequired: true,
                      hint: "Enter Commercial Extra Carpet Percent (%)",
                      keyboardType: TextInputType.number,
                      textController: _commercialPercentController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(3),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Commercial percentage is required";
                        }
                        if (double.parse(value) > 100) {
                          return "Percentage should be less than 100";
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(height: 30),
                    CustomButton(text: "Save", onPressed: _onSave),
                    verticalSpacing(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
