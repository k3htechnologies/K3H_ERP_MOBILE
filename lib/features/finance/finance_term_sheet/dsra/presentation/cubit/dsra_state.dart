part of 'dsra_cubit.dart';

class DsraState extends BaseState {
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const DsraState({
    super.isLoading,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });

  factory DsraState.inital() =>
      DsraState(termSheetDetailsViewModel: null, totalNumberOfRecord: 0);

  DsraState copywith({
    bool? isLoading,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return DsraState(
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
