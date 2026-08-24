import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
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
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberOfParkingC,
      _totalParkingPercentageC,
      _remarkC;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;
  final ValueNotifier<bool> _disableNoOfParking = ValueNotifier(false);
  final ValueNotifier<bool> _disableParkingPercentage = ValueNotifier(false);
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
    _disableNoOfParking.dispose();
    _disableParkingPercentage.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _numberOfParkingC = TextEditingController();
    _totalParkingPercentageC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _populateFormFields() {
    var parkingAllotmentModel = _cubit.state.parkingAllotment!;
    _numberOfParkingC.text =
        parkingAllotmentModel.numberOfParkingAllottedToMembers.toString();
    _totalParkingPercentageC.text =
        parkingAllotmentModel.totalParkingPercentageAllottedToSociety
            .toString();
    _disableNoOfParking.value =
        parkingAllotmentModel.numberOfParkingAllottedToMembers == 0
            ? true
            : false;
    _disableParkingPercentage.value =
        parkingAllotmentModel.totalParkingPercentageAllottedToSociety == 0
            ? true
            : false;
    _remarkC.text = parkingAllotmentModel.remark;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateParkingAllotment(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        numberOfParkingAllottedToMembers:
            int.tryParse(_numberOfParkingC.text) ?? 0,
        totalParkingPercentageAllottedToSociety:
            double.tryParse(_totalParkingPercentageC.text) ?? 0,
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
            _populateFormFields();
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
                        ValueListenableBuilder(
                          valueListenable: _disableNoOfParking,
                          builder: (context, disableNoOfParking, child) {
                            return CustomTextField(
                              title: 'Number of Parking Allotted to Members',
                              hint:
                                  'Enter Number of Parking Allotted to Members',
                              isRequired: true,
                              readOnly: disableAction || disableNoOfParking,
                              textController: _numberOfParkingC,
                              keyboardType: TextInputType.number,
                              onChangeFunction: (value) {
                                if (value.isNotEmpty && value != '0') {
                                  _disableParkingPercentage.value = true;
                                } else {
                                  _disableParkingPercentage.value = false;
                                }
                              },
                              inputFormatterList: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (value) {
                                if (disableNoOfParking) return null;
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    int.parse(value) < 0) {
                                  return "Number of parking is required";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: _disableParkingPercentage,
                          builder: (context, disableParkingPercentage, child) {
                            return CustomTextField(
                              title:
                                  "Total Parking Percentage Allotted to Society (%)",
                              isRequired: true,
                              readOnly:
                                  disableAction || disableParkingPercentage,
                              hint: "0",
                              textController: _totalParkingPercentageC,
                              keyboardType: TextInputType.number,
                              inputFormatterList: InputValidator.percentage(),
                              onChangeFunction: (value) {
                                if (value.isNotEmpty && value != '0') {
                                  _disableNoOfParking.value = true;
                                } else {
                                  _disableNoOfParking.value = false;
                                }
                              },
                              validator: (value) {
                                if (disableParkingPercentage) return null;
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    double.parse(value) <= 0) {
                                  return "Total parking percentage is required";
                                }
                                return null;
                              },
                            );
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
                SectionCard(
                  title: 'Action Details',
                  titleTextColor: AppColor.black,
                  headerBackgroundColor: AppColor.grey20,
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
