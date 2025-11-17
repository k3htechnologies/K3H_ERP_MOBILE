part of 'login_cubit.dart';

class LoginState extends BaseState {
  final UserModel? user;
  final bool isSendOtp;

  const LoginState({
    super.isLoading,
    super.stateType,
    this.user,
    required this.isSendOtp,
  });

  factory LoginState.initial() =>
      LoginState(isSendOtp: false);

  LoginState copyWith({
    bool? isLoading,
    StateType? stateType,
    UserModel? user,
    bool? isSendOtp,
    bool? isRemembered,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      user: user ?? this.user,
      isSendOtp: isSendOtp ?? this.isSendOtp,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, isSendOtp];
}
