import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:pinput/pinput.dart';

class OTPMobileScreen extends StatefulWidget {
  final String mobileNumber;
  const OTPMobileScreen({super.key, required this.mobileNumber});

  @override
  State<OTPMobileScreen> createState() => _OTPMobileScreenState();
}

class _OTPMobileScreenState extends State<OTPMobileScreen> {
  final defaultPinTheme = PinTheme(
    width: 52,
    height: 47,
    margin: const EdgeInsets.symmetric(horizontal: 0),
    textStyle: AppTextStyle.ts20R().copyWith(color: AppColor.primary),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
    ),
  );

  late LoginCubit _loginCubit;
  late final TextEditingController _otpC;
  late final FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _loginCubit = BlocProvider.of<LoginCubit>(context);
    _otpC = TextEditingController();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _otpC.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = getActualHeight(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -2),
                          blurRadius: 30,
                          color: AppColor.black10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              AppAssets.appLogo,
                              width: 92,
                              height: 120,
                            ),
                          ),
                        ),
                        Text(
                          "OTP Verification",
                          style: AppTextStyle.ts16M(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Please enter the 4-digit code sent you",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 34),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 6.0,
                              children: [
                                BlocBuilder<LoginCubit, LoginState>(
                                  buildWhen:
                                      (previous, current) =>
                                  previous.isSendOtp !=
                                      current.isSendOtp &&
                                      current.stateType ==
                                          StateType.sendOTP,
                                  builder: (context, state) {
                                    if (state.isSendOtp) {
                                      Future.microtask(() {
                                        _otpFocusNode.requestFocus();
                                      });
                                    }
                                    return Pinput(
                                      length: 4,
                                      controller: _otpC,
                                      autofocus: true,
                                      focusNode: _otpFocusNode,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: defaultPinTheme
                                          .copyWith(
                                        decoration: defaultPinTheme
                                            .decoration!
                                            .copyWith(
                                          border: Border.all(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ),
                                      submittedPinTheme: defaultPinTheme
                                          .copyWith(
                                        decoration: defaultPinTheme
                                            .decoration!
                                            .copyWith(
                                          color: AppColor.white,
                                          border: Border.all(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ),
                                      onCompleted: (value) {
                                        _loginCubit.validateOtp(
                                          context,
                                          widget.mobileNumber,
                                          value,
                                        );
                                      },
                                    );
                                  },
                                ),
                                BlocBuilder<LoginCubit, LoginState>(
                                  buildWhen:
                                      (previous, current) =>
                                  current.stateType ==
                                      StateType.sendOTP,
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap:
                                      (!state.isSendOtp)
                                          ? null
                                          : () {
                                        _loginCubit.sendOTP(
                                          context,
                                          widget.mobileNumber,
                                        );
                                      },
                                      child: Text(
                                        "resend otp",
                                        style: AppTextStyle.ts14R().copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                          state.isSendOtp
                                              ? AppColor.primary
                                              : AppColor.grey,
                                          color:
                                          state.isSendOtp
                                              ? AppColor.primary
                                              : AppColor.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 26),
                        Align(
                          alignment: Alignment.center,
                          child: BlocBuilder<LoginCubit, LoginState>(
                            buildWhen:
                                (previous, current) =>
                            current.stateType == StateType.sendOTP,
                            builder: (context, state) {
                              return CustomButton(
                                text: "Login",
                                // isDisable: state.isSendOtp,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                onPressed: () {},
                                backgroundColor: AppColor.primary,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 86),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text: "By signing up, you agree to the ",
                            style: AppTextStyle.ts12R(color: AppColor.grey),
                            children: [
                              TextSpan(
                                text: "Terms of Service\n",
                                style: AppTextStyle.ts12M().copyWith(
                                  color: AppColor.blue,
                                ),
                              ),
                              TextSpan(
                                text: "and ",
                                style: AppTextStyle.ts12R(color: AppColor.grey),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: AppTextStyle.ts12M().copyWith(
                                  color: AppColor.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}