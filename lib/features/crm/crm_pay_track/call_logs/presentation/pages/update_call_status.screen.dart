import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/presentation/cubit/call_logs_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UpdateCallLogsScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final PayTrackCallLogModel callLog;

  const UpdateCallLogsScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.callLog,
  });

  @override
  State<UpdateCallLogsScreen> createState() => _EditCallLogsScreenState();
}

class _EditCallLogsScreenState extends State<UpdateCallLogsScreen> {
  // CUBIT
  late CallLogsCubit _callLogsCubit;
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

    _callLogsCubit = context.read<CallLogsCubit>();
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
  }

  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final callLog = widget.callLog;
    final promiseAmount = double.tryParse(_promisedAmountC.text.trim()) ?? 0;
    _callLogsCubit.updateCallLogs(
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
        screenTitle: "Call Log",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Call Log",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: commonCardDecoration(),
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
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(250),
                      ],
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
                          title: "Reschedule Date",
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
                          title: "Registration Date",
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Update", onPressed: _verifyAndSubmitForm),
        ),
      ),
    );
  }
}
