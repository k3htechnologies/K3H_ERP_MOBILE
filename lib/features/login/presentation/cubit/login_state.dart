part of 'login_cubit.dart';

class LoginState extends BaseState {
  final UserModel? user;
  final bool isSendOtp;
  final String message;

  const LoginState({
    super.isLoading,
    super.stateType,
    this.user,
    required this.isSendOtp,
    required this.message
  });

  factory LoginState.initial() =>
      LoginState(isSendOtp: false,message: "");

  LoginState copyWith({
    bool? isLoading,
    StateType? stateType,
    UserModel? user,
    bool? isSendOtp,
    bool? isRemembered,
    String? message,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      user: user ?? this.user,
      isSendOtp: isSendOtp ?? this.isSendOtp,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, isSendOtp, message];
}
