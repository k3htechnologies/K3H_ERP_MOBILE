import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class GstOnExistingPlusFreeArea extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const GstOnExistingPlusFreeArea({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<GstOnExistingPlusFreeArea> createState() =>
      _GstOnExistingPlusFreeAreaState();
}

class _GstOnExistingPlusFreeAreaState extends State<GstOnExistingPlusFreeArea> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _gstOnAreaByMemberPercentController;
  late TextEditingController _gstOnAreaByDeveloperPercentController;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullGSTonExistingPlusFreeArea(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _gstOnAreaByMemberPercentController.dispose();
    _gstOnAreaByDeveloperPercentController.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _gstOnAreaByMemberPercentController = TextEditingController();
    _gstOnAreaByDeveloperPercentController = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var gstModel = _cubit.state.gstOnExistingPlusFreeArea!;
    _gstOnAreaByMemberPercentController.text =
        gstModel.gstOnAreaByMemberPercent.toString();
    _gstOnAreaByDeveloperPercentController.text =
        gstModel.gstOnAreaByDeveloperPercent.toString();
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateGSTonExistingPlusFreeArea(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        gstOnAreaByMemberPercent: double.parse(
          _gstOnAreaByMemberPercentController.text,
        ),
        gstOnAreaByDeveloperPercent: double.parse(
          _gstOnAreaByDeveloperPercentController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.gstOnExistingPlusFreeArea != null) {
            fillData();
          } else {
            _gstOnAreaByMemberPercentController.clear();
            _gstOnAreaByDeveloperPercentController.clear();
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
                child: Builder(
                  builder: (context) {
                    bool isMemberEditing = false;
                    bool isDeveloperEditing = false;

                    adjustValues({required bool fromMember}) {
                      if (fromMember) {
                        final member =
                            double.tryParse(
                              _gstOnAreaByMemberPercentController.text,
                            ) ??
                            0;
                        final developer = (100 - member).clamp(0, 100);

                        if (!isDeveloperEditing) {
                          _gstOnAreaByDeveloperPercentController
                              .text = developer.toStringAsFixed(2);
                        }
                      } else {
                        final developer =
                            double.tryParse(
                              _gstOnAreaByDeveloperPercentController.text,
                            ) ??
                            0;
                        final member = (100 - developer).clamp(0, 100);

                        if (!isMemberEditing) {
                          _gstOnAreaByMemberPercentController.text = member
                              .toStringAsFixed(2);
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GST on Existing + Free Area",
                          style: AppTextStyle.ts16M(),
                        ),
                        verticalSpacing(height: 15),
                        Focus(
                          onFocusChange: (hasFocus) {
                            isMemberEditing = hasFocus;
                          },
                          child: CustomTextField(
                            title: 'GST on Area by Member Percent (%)',
                            isRequired: true,
                            hint: "Enter GST on Area by Member Percent (%)",
                            textController: _gstOnAreaByMemberPercentController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatterList: [
                              // allow decimals up to 2 digits
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                              ),
                            ],
                            onChangeFunction:
                                (_) => adjustValues(fromMember: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "GST on area by member percent is required";
                              }

                              final numValue = double.tryParse(value);
                              if (numValue == null) return "Invalid number";

                              if (numValue < 0 || numValue > 100) {
                                return "Value must be between 0 and 100";
                              }

                              return null;
                            },
                          ),
                        ),
                        Focus(
                          onFocusChange: (hasFocus) {
                            isDeveloperEditing = hasFocus;
                          },
                          child: CustomTextField(
                            title: 'GST on Area by Developer Percent (%)',
                            isRequired: true,
                            hint: "Enter GST on Area by Developer Percent (%)",
                            textController:
                                _gstOnAreaByDeveloperPercentController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatterList: [
                              // allow decimals up to 2 digits
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                              ),
                            ],
                            onChangeFunction:
                                (_) => adjustValues(fromMember: false),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "GST on area by developer percent is required";
                              }

                              final numValue = double.tryParse(value);
                              if (numValue == null) return "Invalid number";

                              if (numValue < 0 || numValue > 100) {
                                return "Value must be between 0 and 100";
                              }

                              return null;
                            },
                          ),
                        ),
                        verticalSpacing(height: 30),
                        CustomButton(text: "Save", onPressed: _onSave),
                        verticalSpacing(),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
