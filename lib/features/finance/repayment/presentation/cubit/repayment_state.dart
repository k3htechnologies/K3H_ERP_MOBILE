part of 'repayment_cubit.dart';

class RepaymentState extends BaseState {
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const RepaymentState({
    super.isLoading,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });
  factory RepaymentState.inital() => RepaymentState(
    termSheetViewList: [],
    termSheetDetailsViewModel: null,
    totalNumberOfRecord: 0,
  );

  RepaymentState copywith({
    bool? isLoading,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return RepaymentState(
      isLoading: isLoading ?? this.isLoading,
      termSheetViewList: termSheetViewList ?? this.termSheetViewList,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetViewList,
    termSheetDetailsViewModel,
    totalNumberOfRecord,
  ];
}
