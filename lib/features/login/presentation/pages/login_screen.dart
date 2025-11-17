import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/login/presentation/widgets/login_text_field.widget.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginCubit _loginCubit;
  late GlobalKey<FormState> _loginFormKey;
  late final TextEditingController _mobileNumberC;

  @override
  void initState() {
    super.initState();
    _loginCubit = BlocProvider.of<LoginCubit>(context);
    _loginFormKey = GlobalKey<FormState>();
    _mobileNumberC = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginCubit.resetState();
  }

  @override
  void dispose() {
    _mobileNumberC.dispose();
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
                          "LOGIN",
                          style: AppTextStyle.ts16M(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Enter your mobile number to continue",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 34),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6.0,
                            children: [
                              Text(
                                "Mobile Number*",
                                style: AppTextStyle.ts14R(),
                              ),
                              Form(
                                key: _loginFormKey,
                                child: BlocBuilder<LoginCubit, LoginState>(
                                  buildWhen:
                                      (previous, current) =>
                                  current.stateType ==
                                      StateType.sendOTP,
                                  builder:
                                      (context, state) => LoginTextFieldWidget(
                                    textController: _mobileNumberC,
                                    readOnly: state.isSendOtp,
                                    inputFormatterList:
                                    InputValidator.digit(10),
                                    keyboardType: TextInputType.phone,
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
                                    validator: (value) {
                                      if (value == null ||
                                          !isValidMobileNumber(value)) {
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
                                ),
                              ),
                            ],
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
                                text: "Get OTP",
                                // isDisable: state.isSendOtp,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                onPressed: () {
                                  final mobileNumber = _mobileNumberC.text;
                                  if (_loginFormKey.currentState!.validate()) {
                                    _loginCubit.sendOTP(context, mobileNumber);
                                  }
                                },
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: AppTextStyle.ts12R(),
                            children: [
                              TextSpan(
                                text: "Contact us",
                                style: AppTextStyle.ts12M().copyWith(
                                  color: AppColor.info,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.info,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

