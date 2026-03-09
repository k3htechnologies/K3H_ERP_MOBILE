part of 'payroll_dashboard_cubit.dart';

class PayrollDashboardState extends BaseState {
  final PayrollDashboardModel? payrollDashboardModel;

  const PayrollDashboardState({super.isLoading, this.payrollDashboardModel});

  factory PayrollDashboardState.initial() =>
      const PayrollDashboardState(isLoading: true);

  PayrollDashboardState copyWith({
    bool? isLoading,
    PayrollDashboardModel? payrollDashboardModel,
  }) {
    return PayrollDashboardState(
      isLoading: isLoading ?? this.isLoading,
      payrollDashboardModel:
          payrollDashboardModel ?? this.payrollDashboardModel,
    );
  }

  @override
  List<Object?> get props => [isLoading, payrollDashboardModel];
}
