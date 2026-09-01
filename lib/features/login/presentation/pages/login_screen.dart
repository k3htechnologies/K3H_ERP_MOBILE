import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginCubit _loginCubit;
  late GlobalKey<FormState> _loginFormKey;
  late final TextEditingController _mobileNumberC, _otpC;

  late FocusNode _mobileFocus;
  late FocusNode _otpFocus;

  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
    _loginFormKey = GlobalKey<FormState>();
    _mobileNumberC = TextEditingController();
    _otpC = TextEditingController();
    _mobileFocus = FocusNode();
    _otpFocus = FocusNode();
    _loginCubit.resetState();
  }

  @override
  void dispose() {
    _mobileNumberC.dispose();
    _otpC.dispose();
    _mobileFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, -2),
                        blurRadius: 40,
                        color: AppColor.black10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      Text(
                        "Welcome !",
                        style: AppTextStyle.ts24B(),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Enter details to get started",
                        style: AppTextStyle.ts14R(color: AppColor.grey),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Form(
                          key: _loginFormKey,
                          child: BlocListener<LoginCubit, LoginState>(
                            listenWhen:
                                (previous, current) =>
                                    previous.isSendOtp != current.isSendOtp,
                            listener: (context, state) {
                              if (state.isSendOtp) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    _otpFocus.requestFocus();
                                  }
                                });
                              }
                            },
                            child: BlocBuilder<LoginCubit, LoginState>(
                              buildWhen:
                                  (previous, current) =>
                                      current.stateType == StateType.sendOTP,
                              builder: (context, state) {
                                return Column(
                                  children: [
                                    // MOBIlE FIELD
                                    CustomTextField(
                                      focusNode: _mobileFocus,
                                      title: "Mobile Number",
                                      hint: "Enter Mobile Number",
                                      readOnly: state.isSendOtp,
                                      prefixWidget: IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 10),
                                            Text("+91"),
                                            VerticalDivider(
                                              color: AppColor.black,
                                              thickness: 0.5,
                                              width: 15,
                                              indent: 5,
                                              endIndent: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      inputFormatterList: InputValidator.digit(
                                        10,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      textController: _mobileNumberC,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Mobile number is required.";
                                        } else if (!isValidMobileNumber(
                                          value,
                                        )) {
                                          return "Mobile number is invalid";
                                        }
                                        return null;
                                      },
                                      onSubmitFunction: (value) {
                                        if (_loginFormKey.currentState!
                                            .validate()) {
                                          _loginCubit.sendOTP(
                                            context,
                                            _mobileNumberC.text,
                                          );
                                        }
                                      },
                                    ),

                                    // OTP FIELD
                                    if (state.message.isNotEmpty)
                                      CustomTextField(
                                        focusNode: _otpFocus,
                                        readOnly: !state.isSendOtp,
                                        inputFormatterList:
                                            InputValidator.digit(4),
                                        keyboardType: TextInputType.number,
                                        title:
                                            state.message
                                                    .trim()
                                                    .toLowerCase()
                                                    .contains('mpin')
                                                ? "MPIN"
                                                : "OTP",
                                        hint: "- - - -",
                                        textController: _otpC,
                                        onSubmitFunction: (value) {
                                          FocusScope.of(context).unfocus();
                                          _loginCubit.validateOtp(
                                            context,
                                            _mobileNumberC.text,
                                            value,
                                            state.message
                                                    .trim()
                                                    .toLowerCase()
                                                    .contains('mpin')
                                                ? "mpin"
                                                : "otp",
                                          );
                                        },
                                        validator: (value) {
                                          final isMpin = state.message
                                              .trim()
                                              .toLowerCase()
                                              .contains('mpin');

                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return isMpin
                                                ? "MPIN is required"
                                                : "OTP is required.";
                                          }

                                          return null;
                                        },
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 26),
                      Align(
                        alignment: Alignment.center,
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: CustomButton(
                                    text:
                                        !state.isSendOtp
                                            ? "Verify Mobile Number"
                                            : "Log In",
                                    // isDisable: state.isSendOtp,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 40.0,
                                    ),
                                    onPressed: () {
                                      if (_loginFormKey.currentState!
                                          .validate()) {
                                        if (!state.isSendOtp) {
                                          final mobileNumber =
                                              _mobileNumberC.text;
                                          if (_loginFormKey.currentState!
                                              .validate()) {
                                            _loginCubit.sendOTP(
                                              context,
                                              mobileNumber,
                                            );
                                          }
                                        } else {
                                          _loginCubit.validateOtp(
                                            context,
                                            _mobileNumberC.text,
                                            _otpC.text,
                                            state.message
                                                    .trim()
                                                    .toLowerCase()
                                                    .contains('mpin')
                                                ? "mpin"
                                                : "otp",
                                          );
                                        }
                                      }
                                    },
                                    backgroundColor: AppColor.primary,
                                  ),
                                ),
                                verticalSpacing(),
                                Visibility(
                                  visible: state.isSendOtp && state.isOtpFlow,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Didn’t Receive a code ? "),

                                      state.canResend
                                          ? GestureDetector(
                                            onTap: () {
                                              _loginCubit.sendOTP(
                                                context,
                                                _mobileNumberC.text,
                                              );
                                            },
                                            child: Text(
                                              "Resend",
                                              style: AppTextStyle.ts14B(
                                                color: AppColor.primary,
                                              ),
                                            ),
                                          )
                                          : Text(
                                            "Resend in ${state.resendSeconds}s",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
