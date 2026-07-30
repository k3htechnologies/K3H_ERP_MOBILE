import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddRefundScreen extends StatefulWidget {
  final BookingModel booking;

  const AddRefundScreen({super.key, required this.booking});

  @override
  State<AddRefundScreen> createState() => _AddRefundScreenState();
}

class _AddRefundScreenState extends State<AddRefundScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _refundAmountC;

  late RequestManagementCubit _requestManagementCubit;
  late PayTrackCubit _payTrackCubit;
  late ProjectModel _selectedProject;
  late ValueNotifier<bool> finalizeRefundAmountNotifier;
  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _payTrackCubit = context.read<PayTrackCubit>();
    _refundAmountC = TextEditingController();
    finalizeRefundAmountNotifier = ValueNotifier(false);
    _selectedProject = getProject();
    _payTrackCubit.getPayTrackListByBookingId(
      context,
      1,
      _selectedProject.projectId,
      widget.booking.bookingId,
    );
  }

  @override
  void dispose() {
    _refundAmountC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Initiate Refund",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<PayTrackCubit, PayTrackState>(
        builder: (context, state) {
          if (state.isLoading ?? false) {
            return Center(child: loader());
          }

          final addRefundData = state.payTrackOverview;
          final totalReceived =
              addRefundData?.totalAmountReceivedAgainstBooking ?? 0.0;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: AppColor.lightBluebg,
                    ),
                    child: Column(
                      spacing: 10.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Received Amount",
                          style: AppTextStyle.ts14M(
                            color: AppColor.black.withValues(alpha: 0.5),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Stamp Duty",
                                value:
                                    addRefundData?.receivedStampDutyAmount
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Registration Fees",
                                value:
                                    addRefundData?.receivedRegistrationFees
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Agreement Value(Without TDS)",
                                value:
                                    addRefundData?.receivedAgreementValue
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Agreement Value GST",
                                value:
                                    addRefundData
                                        ?.receivedAgreementValueGstAmount
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Agreement Value TDS",
                                value:
                                    addRefundData?.receivedAgreementValueTds
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Other Charges",
                                value:
                                    addRefundData?.receivedOtherChargesAmount
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Other Charges GST",
                                value:
                                    addRefundData?.receivedOtherChargesGstAmount
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                            horizontalSpacing(),
                            Expanded(
                              child: buildColumnTitleValueNormal(
                                title: "Total Received",
                                value:
                                    addRefundData
                                        ?.totalAmountReceivedAgainstBooking
                                        .toIndianCurrency() ??
                                    "",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(height: 20.0),
                  CustomTextField(
                    textController: _refundAmountC,
                    title: "Refund Amount",
                    hint: "Enter Refund Amount",
                    isRequired: true,
                    keyboardType: TextInputType.numberWithOptions(),
                    inputFormatterList: InputValidator.decimal(2),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Refund amount is required";
                      }

                      final refundAmount = double.tryParse(value) ?? 0.0;

                      if (refundAmount > totalReceived) {
                        return "Refund Amount cannot be greater than Total Received Amount";
                      }

                      return null;
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: finalizeRefundAmountNotifier,
                    builder: (context, isChecked, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomCheckBox(
                              isSelected: isChecked,
                              title:
                                  "Finalize Refund Amount (No Further Changes Allowed)",
                              onChanged: (_) {
                                finalizeRefundAmountNotifier.value =
                                    !finalizeRefundAmountNotifier.value;
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  verticalSpacing(height: 10.0),
                  Text(
                    "By selecting this option, the Initial Refund Amount will be finalized and cannot be changed later.",
                    style: AppTextStyle.ts14R(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: "Save",
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              _requestManagementCubit.initiateRefund(
                context,
                uniquekey: widget.booking.uniquekey,
                projectId: widget.booking.projectId,
                bookingId: widget.booking.bookingId,
                totalRefundAmountAgainstBooking: _refundAmountC.text,
              );
            },
          ),
        ),
      ),
    );
  }
}
