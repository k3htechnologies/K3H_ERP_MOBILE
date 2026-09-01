part of 'sweep_ratio_cubit.dart';

class SweepRatioState extends BaseState {
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const SweepRatioState({
    super.isLoading,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });
  factory SweepRatioState.inital() => SweepRatioState(
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
