import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';

class RegisterState extends BaseState {
  final UserModel? user;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isCheckedTerms;
  final String phoneOtp;
  final String emailOtp;

  const RegisterState({
    super.isLoading,
    super.stateType,
    this.user,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.isCheckedTerms,
    required this.phoneOtp,
    required this.emailOtp,
  });

  factory RegisterState.initial() => const RegisterState(
    isPhoneVerified: false,
    isEmailVerified: false,
    isCheckedTerms: false,
    phoneOtp: "",
    emailOtp: "",
  );

  RegisterState copyWith({
    bool? isLoading,
    StateType? stateType,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isCheckedTerms,
    String? phoneOtp,
    String? emailOtp,
    UserModel? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isCheckedTerms: isCheckedTerms ?? this.isCheckedTerms,
      phoneOtp: phoneOtp ?? this.phoneOtp,
      emailOtp: emailOtp ?? this.emailOtp,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isPhoneVerified,
    isEmailVerified,
    isCheckedTerms,
    phoneOtp,
    emailOtp,
  ];
}
