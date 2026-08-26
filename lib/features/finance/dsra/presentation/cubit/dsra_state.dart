part of 'dsra_cubit.dart';

class DsraState extends BaseState {
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const DsraState({
    super.isLoading,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });

  factory DsraState.inital() => DsraState(
    termSheetViewList: [],
    termSheetDetailsViewModel: null,
    totalNumberOfRecord: 0,
  );

  DsraState copywith({
    bool? isLoading,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return DsraState(
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
