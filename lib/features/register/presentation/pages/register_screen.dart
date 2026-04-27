import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_cubit.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterCubit _registerCubit;
  late GlobalKey<FormState> _registerFormKey;
  late final TextEditingController _fullNameC, _mobileNumberC, _otpC;

  late FocusNode _mobileFocus;
  late FocusNode _otpFocus;

  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    _registerCubit = context.read<RegisterCubit>();
    _registerFormKey = GlobalKey<FormState>();
    _fullNameC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _otpC = TextEditingController();
    _mobileFocus = FocusNode();
    _otpFocus = FocusNode();
  }

  @override
  void dispose() {
    _fullNameC.dispose();
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
                        "Welcome To ERP 2.0",
                        style: AppTextStyle.ts24B(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Form(
                          key: _registerFormKey,
                          child: BlocBuilder<RegisterCubit, RegisterState>(
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    textController: _fullNameC,
                                    isRequired: true,
                                    hint: "Full Name",
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Full Name is required";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomTextField(
                                    textController: _mobileNumberC,
                                    hint: "Phone Number",
                                    suffixWidget: GestureDetector(
                                      onTap: () {
                                        _registerCubit.sendPhoneOtp(
                                          context,
                                          _mobileNumberC.text,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          state.isPhoneVerified
                                              ? "Verified"
                                              : "Verify Phone",
                                          style: AppTextStyle.ts12R().copyWith(
                                            color:
                                                state.isPhoneVerified
                                                    ? Colors.green
                                                    : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    inputFormatterList: InputValidator.digit(
                                      10,
                                    ),
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
                                          value.trim().isEmpty) {
                                        return "Phone Number is required";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomButton(
                                    text: "Register",
                                    onPressed: () {
                                      if (!_registerFormKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      _registerCubit.register(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            goRouter.goNamed(AppRoutes.login);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: AppTextStyle.ts14M(),
                                children: [
                                  TextSpan(
                                    text: " Sign In",
                                    style: AppTextStyle.ts16SB().copyWith(
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
