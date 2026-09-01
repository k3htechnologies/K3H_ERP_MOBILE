part of 'dsa_cubit.dart';

class DsaState extends BaseState {
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const DsaState({
    super.isLoading,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });

  factory DsaState.inital() => DsaState(
    termSheetDetailsViewModel: null,
    totalNumberOfRecord: 0,
  );
  DsaState copywith({
    bool? isLoading,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return DsaState(
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
