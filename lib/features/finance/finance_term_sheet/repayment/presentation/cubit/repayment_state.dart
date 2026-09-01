part of 'repayment_cubit.dart';

class RepaymentState extends BaseState {
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const RepaymentState({
    super.isLoading,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });
  factory RepaymentState.inital() =>
      RepaymentState(termSheetDetailsViewModel: null, totalNumberOfRecord: 0);

  RepaymentState copywith({
    bool? isLoading,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return RepaymentState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDetailsViewModel,
    totalNumberOfRecord,
  ];
}
