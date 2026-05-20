import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

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
  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _refundAmountC = TextEditingController();
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  textController: _refundAmountC,
                  title: "Refund Amount",
                  hint: "Enter Refund Amount",
                  isRequired: true,
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatterList: InputValidator.decimal(2),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Refund amount is required";
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: "Submit",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
