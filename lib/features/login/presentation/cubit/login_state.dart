part of 'login_cubit.dart';

class LoginState extends BaseState {
  final UserModel? user;
  final bool isSendOtp;
  final String message;
  final int resendSeconds;
  final bool canResend;
  final bool isOtpFlow;

  const LoginState({
    super.isLoading,
    super.stateType,
    this.user,
    required this.isSendOtp,
    required this.message,
    required this.resendSeconds,
    required this.canResend,
    required this.isOtpFlow,
  });

  factory LoginState.initial() => LoginState(
    isSendOtp: false,
    message: "",
    resendSeconds: 0,
    canResend: false,
    isOtpFlow: false,
  );

  LoginState copyWith({
    bool? isLoading,
    StateType? stateType,
    UserModel? user,
    bool? isSendOtp,
    String? message,
    int? resendSeconds,
    bool? canResend,
    bool? isOtpFlow,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      user: user ?? this.user,
      isSendOtp: isSendOtp ?? this.isSendOtp,
      message: message ?? this.message,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
      isOtpFlow: isOtpFlow ?? this.isOtpFlow,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    user,
    isSendOtp,
    message,
    resendSeconds,
    canResend,
    isOtpFlow,
  ];
}