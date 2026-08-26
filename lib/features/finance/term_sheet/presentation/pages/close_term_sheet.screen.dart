import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CloseTermSheetScreen extends StatefulWidget {
  final int termSheetId;
  final int projectId;
  const CloseTermSheetScreen({
    super.key,
    required this.termSheetId,
    required this.projectId,
  });

  @override
  State<CloseTermSheetScreen> createState() => _CloseTermSheetScreenState();
}

class _CloseTermSheetScreenState extends State<CloseTermSheetScreen> {
  late TermSheetCubit _termSheetCubit;
  late TextEditingController _remarkC;

  // DATE PICKERS
  DateTime? closingDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _termSheetCubit = context.read<TermSheetCubit>();
    _remarkC = TextEditingController();
    super.initState();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _termSheetCubit.finalizeTermSheetApproval(
      context,
      termSheetId: widget.termSheetId,
      projectId: widget.projectId,
      closingDate: closingDate,
      closingRemark: _remarkC.text.trim(),
    );
  }

  @override
  void dispose() {
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Close Term Sheet",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Close Term Sheet",
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
                    CustomDatePicker(
                      title: "Closing Date",
                      hint: "Enter Closing Date",
                      initialDate: closingDate,
                      setValue: (value) => closingDate = value,
                      isRequired: true,
                      validator: (value) {
                        if (value == null) {
                          return 'Closing Date is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Closing Remarks",
                      hint: "Enter Closing Remarks",
                      textController: _remarkC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Closing Remarks is required.";
                        }
                        return null;
                      },
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
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(text: "Close", onPressed: _submit),
        ),
      ),
    );
  }
}
