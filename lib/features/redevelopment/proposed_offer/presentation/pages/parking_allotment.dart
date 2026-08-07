import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ParkingAllotment extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;

  const ParkingAllotment({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
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
  late TextEditingController _numberOfParkingC,
      _totalParkingPercentageC,
      _remarkC;

  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    widget.onSave(_onSave);
    _cubit.pullParkingAllotment(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _numberOfParkingC.dispose();
    _totalParkingPercentageC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _numberOfParkingC = TextEditingController();
    _totalParkingPercentageC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var parkingAllotmentModel = _cubit.state.parkingAllotment!;
    _numberOfParkingC.text =
        parkingAllotmentModel.numberOfParkingAllottedToMembers.toString();
    _totalParkingPercentageC.text =
        parkingAllotmentModel.totalParkingPercentageAllottedToSociety
            .toString();
    _remarkC.text = parkingAllotmentModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateParkingAllotment(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        numberOfParkingAllottedToMembers: int.parse(_numberOfParkingC.text),
        totalParkingPercentageAllottedToSociety: double.parse(
          _totalParkingPercentageC.text,
        ),
        remark: _remarkC.text.trim(),
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
            _numberOfParkingC.clear();
            _totalParkingPercentageC.clear();
            _remarkC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardHeaderTile(
                          svgIcon: AppAssets.parkingIcon,
                          title: "Parking Allotment",
                        ),
                        verticalSpacing(height: 15),
                        CustomTextField(
                          title: 'Number of Parking Allotted to Members',
                          hint: 'Enter Number of Parking Allotted to Members',
                          isRequired: true,
                          readOnly: disableAction,
                          textController: _numberOfParkingC,
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
                          readOnly: disableAction,
                          hint:
                              "Enter Total Parking Percentage Allotted to Society (%)",
                          textController: _totalParkingPercentageC,
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
                        CustomTextField(
                          title: 'Remark',
                          hint: 'Enter Remark',
                          textController: _remarkC,
                          minLines: 3,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                sectionCard(
                  title: 'Action Details',
                  textColor: AppColor.black,
                  bgColor: AppColor.grey20,
                  children: [
                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: state.parkingAllotment?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            state.parkingAllotment?.createdDate,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.parkingAllotment?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.parkingAllotment?.modifiedDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
