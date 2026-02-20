part of 'payment_schedule_summary_cubit.dart';

class PaymentScheduleSummaryState extends BaseState {
  final int currentTabIndex;

  const PaymentScheduleSummaryState({
    super.isLoading,
    required this.currentTabIndex,
  });

  factory PaymentScheduleSummaryState.initial() =>
      PaymentScheduleSummaryState(isLoading: true, currentTabIndex: 0);

  PaymentScheduleSummaryState copyWith({
    bool? isLoading,
    int? currentTabIndex,
  }) {
    return PaymentScheduleSummaryState(
      isLoading: isLoading ?? this.isLoading,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [isLoading, currentTabIndex];
}
