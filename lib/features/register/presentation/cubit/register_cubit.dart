import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/register/data/repository/register.repository.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_state.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState.initial());

  final RegisterRepository registerRepository =
      serviceLocator<RegisterRepository>();

  // ------------------ TOGGLE TERMS ------------------
  void toggleTerms(bool value) {
    emit(state.copyWith(isCheckedTerms: value));
  }

  // ------------------ SEND PHONE OTP ------------------
  Future<void> sendPhoneOtp(BuildContext context, String phone) async {
    try {
      DialogHelper.showProcessingOverlay(context);

      emit(state.copyWith(isLoading: true));

      final result = await registerRepository.sendOTPModuleBased(
        mobileNumber: phone,
        module: "REGISTER".toLowerCase(),
      );

      goRouter.pop();

      result.fold(
        (failure) {
          showErrorMessage(context, "OTP Failed", failure.message);
          emit(state.copyWith(isLoading: false));
        },
        (response) {
          emit(state.copyWith(isLoading: false));
          showSuccessMessage(context, subTitle: response['message']);

          _showOtpDialog(
            navigatorKey.currentState!.context,
            isPhone: true,
            isEmail: false,
            mobile: phone,
          );
        },
      );
    } catch (e) {
      goRouter.pop();
      showErrorMessage(context, "Error", e.toString());
      emit(state.copyWith(isLoading: false));
    }
  }

  void _showOtpDialog(
    BuildContext context, {
    required bool isPhone,
    required bool isEmail,
    String? mobile,
  }) {
    TextEditingController otpC = TextEditingController();

    DialogHelper.showCustomDialogue(
      navigatorKey.currentContext!,
      title: "Enter Otp",
      childContent: Column(
        children: [
          CustomTextField(
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            textController: otpC,
            hint: "Enter OTP",
          ),
          CustomButton(
            text: "Verify",
            onPressed: () {
              goRouter.pop();

              verifyPhoneOtp(context, mobile ?? "", otpC.text);
            },
          ),
        ],
      ),
    );
  }

  // ------------------ VERIFY PHONE OTP ------------------
  Future verifyPhoneOtp(
    BuildContext context,
    String mobile,
    String enteredOtp,
  ) async {
    final result = await registerRepository.validateOTP(
      mobileNumber: mobile,
      otp: enteredOtp,
      type: "REGISTER".toLowerCase(),
    );
    result.fold(
      (failure) {
        showErrorMessage(context, "Invalid OTP", failure.message);
      },
      (user) async {
        emit(state.copyWith(user: user));

        if (context.mounted) {
          emit(state.copyWith(isPhoneVerified: true));
          showSuccessMessage(context, subTitle: "Phone Verified");
        }
      },
    );
  }

  // ------------------ REGISTER ------------------
  Future<void> register(BuildContext context) async {
    if (!state.isPhoneVerified) {
      showErrorMessage(context, "Error", "Verify phone first");
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Registered Successfully");
        goRouter.goNamed(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        goRouter.pop();
        showErrorMessage(context, "Error", e.toString());
      }
    }
  }
}
