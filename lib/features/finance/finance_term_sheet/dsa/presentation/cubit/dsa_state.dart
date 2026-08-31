part of 'dsa_cubit.dart';

class DsaState extends BaseState {
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const DsaState({
    super.isLoading,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });

  factory DsaState.inital() => DsaState(
    termSheetViewList: [],
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
