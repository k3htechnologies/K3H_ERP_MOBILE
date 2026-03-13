import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

Future<void> showCompleteVerificationDialog(
  BuildContext context, {
  required TextEditingController otpController,
  required VoidCallback onVerifyOTP,
  required VoidCallback onResendOTP,
  required Map<String, bool> verificationSteps,
}) {
  otpController.clear();
  return DialogHelper.showCustomDialogue(
    context,
    title: "Complete Verification",
    childContent: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verify Details To Continue",
          style: AppTextStyle.ts12R(color: AppColor.grey),
        ),
        verticalSpacing(height: 15),

        ...verificationSteps.entries.map(
          (step) => _buildVerificationStep(step.key, step.value),
        ),

        verticalSpacing(height: 10),

        Text("Verify Otp", style: AppTextStyle.ts14R()),
        verticalSpacing(height: 5),

        TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          cursorColor: AppColor.primary,
          maxLength: 4,

          decoration: InputDecoration(
            isDense: true,
            hintText: "Enter OTP",
            counterText: "",
            hintStyle: AppTextStyle.ts14R().copyWith(color: AppColor.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColor.grey30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColor.primary),
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(top: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              otpController.clear();
              onResendOTP();
            },
            child: Text("Resend OTP", style: AppTextStyle.ts12R()),
          ),
        ),
      ],
    ),
    bottomSection: SizedBox(
      height: 40,
      child: CustomButton(
        text: "Verify OTP & Add",
        onPressed: () {
          if (otpController.text.length == 4) {
            onVerifyOTP();
          } else {
            showErrorMessage(
              context,
              "Error",
              "Please enter valid 4-digit OTP",
            );
          }
        },
      ),
    ),
  );
}

//  HELPER: Verification Step Widget
Widget _buildVerificationStep(String title, bool isCompleted) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isCompleted ? AppColor.lightBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  isCompleted
                      ? AppColor.primary
                      : AppColor.grey.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child:
              isCompleted
                  ? const Center(
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppColor.primary,
                      weight: 800,
                    ),
                  )
                  : null,
        ),
        horizontalSpacing(width: 12),
        Text(title, style: AppTextStyle.ts14M()),
      ],
    ),
  );
}
