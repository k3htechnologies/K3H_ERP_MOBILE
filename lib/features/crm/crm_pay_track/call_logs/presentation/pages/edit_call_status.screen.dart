import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class EditCallLogsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final PayTrackCallLogModel callLog;

  const EditCallLogsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.callLog,
  });

  @override
  State<EditCallLogsScreen> createState() => _EditCallLogsScreenState();
}

class _EditCallLogsScreenState extends State<EditCallLogsScreen> {
  // CUBIT
  late PayTrackCubit _payTrackCubit;
  late TextEditingController _remarkC, _promisedAmountC;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<Map<String, dynamic>?> _selectedCallStatus =
      ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedCallPurpose =
      ValueNotifier(null);

  final ValueNotifier<DateTime?> _fromDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _toDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();

    _payTrackCubit = context.read<PayTrackCubit>();
    initialiseControllers();
    _prefillData();
  }

  @override
  void dispose() {
    super.dispose();
    _remarkC.dispose();
    _promisedAmountC.dispose();
  }

  void initialiseControllers() {
    _remarkC = TextEditingController();
    _promisedAmountC = TextEditingController();
  }

  void _prefillData() {
    final callLog = widget.callLog;

    _remarkC.text = callLog.remark;
    _promisedAmountC.text = callLog.promiseAmount.toString();

    _fromDateNotifier.value = callLog.rescheduleDate;
    _toDateNotifier.value = callLog.registrationDate;

    // CALL STATUS
    final status =
        callStatus.where((item) {
          final displayName =
              item['DisplayName']?.toString().trim().toLowerCase() ?? '';

          return displayName == callLog.callStatus.trim().toLowerCase();
        }).toList();

    _selectedCallStatus.value = status.isNotEmpty ? status.first : null;

    // CALL PURPOSE
    final purpose =
        callPurpose.where((item) {
          final displayName =
              item['DisplayName']?.toString().trim().toLowerCase() ?? '';

          return displayName == callLog.callPurpose.trim().toLowerCase();
        }).toList();

    _selectedCallPurpose.value = purpose.isNotEmpty ? purpose.first : null;

    debugPrint("Call Status from API: ${callLog.callStatus}");
    debugPrint("Selected Status: ${_selectedCallStatus.value}");

    debugPrint("Call Purpose from API: ${callLog.callPurpose}");
    debugPrint("Selected Purpose: ${_selectedCallPurpose.value}");
  }

  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final callLog = widget.callLog;
    final promiseAmount =
        double.tryParse(
          _promisedAmountC.text.replaceAll('₹', '').replaceAll(',', '').trim(),
        ) ??
        0;
    _payTrackCubit.updatePayTrackCallLogs(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      payTrackCallLogId: callLog.payTrackCallLogId,
      uniquekey: callLog.uniquekey,
      callStatus: _selectedCallStatus.value?['DisplayName'] ?? '',
      remark: _remarkC.text.trim(),
      rescheduleDate: _fromDateNotifier.value,
      registrationDate: _toDateNotifier.value,
      callPurpose: _selectedCallPurpose.value?['DisplayName'] ?? '',
      promisedAmount: promiseAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Update Call Log",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _selectedCallStatus,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    title: "Call Status",
                    hintText: "Select Call Status",
                    isRequired: true,
                    initialValue: value,
                    dataList: callStatus,
                    onSelected: (value) {
                      _selectedCallStatus.value = value;
                    },
                    onValueClear: () {
                      _selectedCallStatus.value = null;
                    },
                    validator: (value) {
                      if (value == null || value['zAttributesId'] == -1) {
                        return 'Call Status is required';
                      }
                      return null;
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _selectedCallPurpose,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    isRequired: true,
                    title: "Call Purpose",
                    hintText: "Select Call Purpose",
                    initialValue: value,
                    dataList: callPurpose,
                    onSelected: (value) {
                      _selectedCallPurpose.value = value;
                    },
                    onValueClear: () {
                      _selectedCallPurpose.value = null;
                    },
                    validator: (value) {
                      if (value == null || value['zAttributesId'] == -1) {
                        return 'Call Purpose is required';
                      }
                      return null;
                    },
                  );
                },
              ),
              CustomTextField(
                textController: _remarkC,
                title: "Remark",
                hint: "Enter Remark",
                isRequired: true,
                minLines: 3,
                maxLines: 10,
                inputFormatterList: [LengthLimitingTextInputFormatter(250)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Remark is required';
                  }
                  return null;
                },
              ),
              ValueListenableBuilder<DateTime?>(
                valueListenable: _fromDateNotifier,
                builder: (context, fromDate, child) {
                  return CustomDatePicker(
                    title: "Reschedule From Date",
                    initialDate: fromDate,
                    setValue: (value) {
                      _fromDateNotifier.value = value;
                    },
                    validator: (value) => null,
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _toDateNotifier,
                builder: (context, toDate, child) {
                  return CustomDatePicker(
                    title: "Reschedule To Date",
                    initialDate: toDate,
                    setValue: (value) {
                      _toDateNotifier.value = value;
                    },
                    validator: (value) => null,
                  );
                },
              ),

              CustomTextField(
                textController: _promisedAmountC,
                title: "Promise Amount (₹)",
                hint: "Enter Promise Amount (₹)",
                keyboardType: TextInputType.numberWithOptions(),
                inputFormatterList: InputValidator.decimal(2),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Update", onPressed: _verifyAndSubmitForm),
        ),
      ),
    );
  }
}
