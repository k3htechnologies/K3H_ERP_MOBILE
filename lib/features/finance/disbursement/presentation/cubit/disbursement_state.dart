part of 'disbursement_cubit.dart';

class DisbursementState extends BaseState {
  final List<TermSheetDisbursedAmountDetailsData>
  termSheetDisbursedAmountDetailsData;
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  const DisbursementState({
    super.isLoading,
    required this.termSheetDisbursedAmountDetailsData,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
    required this.totalNumberOfRecord,
  });

  factory DisbursementState.inital() => DisbursementState(
    termSheetDisbursedAmountDetailsData: [],
    termSheetViewList: [],
    termSheetDetailsViewModel: null,
    totalNumberOfRecord: 0,
  );
  DisbursementState copywith({
    bool? isLoading,
    List<TermSheetDisbursedAmountDetailsData>?
    termSheetDisbursedAmountDetailsData,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
    int? totalNumberOfRecord,
  }) {
    return DisbursementState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDisbursedAmountDetailsData:
          termSheetDisbursedAmountDetailsData ??
          this.termSheetDisbursedAmountDetailsData,
      termSheetViewList: termSheetViewList ?? this.termSheetViewList,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDisbursedAmountDetailsData,
    termSheetViewList,
    termSheetDetailsViewModel,
    totalNumberOfRecord,
  ];
}
