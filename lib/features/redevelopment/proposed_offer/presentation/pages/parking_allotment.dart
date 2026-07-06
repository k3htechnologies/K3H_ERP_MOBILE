import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ParkingAllotment extends StatefulWidget {
  final int projectId;
  final int buildingId;

  const ParkingAllotment({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<ParkingAllotment> createState() => _ParkingAllotmentState();
}

class _ParkingAllotmentState extends State<ParkingAllotment> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _numberOfParkingController;
  late TextEditingController _totalParkingPercentageController;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullParkingAllotment(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _numberOfParkingController.dispose();
    _totalParkingPercentageController.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _numberOfParkingController = TextEditingController();
    _totalParkingPercentageController = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var parkingAllotmentModel = _cubit.state.parkingAllotment!;
    _numberOfParkingController.text =
        parkingAllotmentModel.numberOfParkingAllottedToMembers.toString();
    _totalParkingPercentageController.text =
        parkingAllotmentModel.totalParkingPercentageAllottedToSociety
            .toString();
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateParkingAllotment(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        numberOfParkingAllottedToMembers: int.parse(
          _numberOfParkingController.text,
        ),
        totalParkingPercentageAllottedToSociety: double.parse(
          _totalParkingPercentageController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.parkingAllotment != null) {
            fillData();
          } else {
            _numberOfParkingController.clear();
            _totalParkingPercentageController.clear();
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
                    Text("Parking Allotment", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: 'Number of Parking Allotted to Members',
                      isRequired: true,
                      hint: 'Enter Number of Parking Allotted to Members',
                      textController: _numberOfParkingController,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Number of parking is required";
                        }
                        if (int.parse(value) < 0) {
                          return "Number of parking should be greater than or equal to 0";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title:
                          "Total Parking Percentage Allotted to Society (%)",
                      isRequired: true,
                      hint:
                          "Enter Total Parking Percentage Allotted to Society (%)",
                      textController: _totalParkingPercentageController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(3),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Total parking percentage is required";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter valid Percentage";
                        }
                        if (double.parse(value) > 100) {
                          return "Percentage should be less than or equal to 100";
                        }

                        return null;
                      },
                    ),
                    verticalSpacing(height: 30),
                    CustomButton(text: "Save", onPressed: _onSave),
                    verticalSpacing(),
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
