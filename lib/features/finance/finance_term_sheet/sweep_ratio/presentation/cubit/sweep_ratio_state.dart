part of 'sweep_ratio_cubit.dart';

class SweepRatioState extends BaseState {
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const SweepRatioState({
    super.isLoading,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });
  factory SweepRatioState.inital() => SweepRatioState(
    termSheetViewList: [],
    termSheetDetailsViewModel: null,
    totalNumberOfRecord: 0,
  );
  SweepRatioState copywith({
    bool? isLoading,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return SweepRatioState(
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
