part of 'disbursement_cubit.dart';

class DisbursementState extends BaseState {
  final List<TermSheetDisbursedAmountDetailsData>
  termSheetDisbursedAmountDetailsData;
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;

  const DisbursementState({
    super.isLoading,
    required this.termSheetDisbursedAmountDetailsData,
    required this.termSheetViewList,
    this.termSheetDetailsViewModel,
  });

  factory DisbursementState.inital() => DisbursementState(
    termSheetDisbursedAmountDetailsData: [],
    termSheetViewList: [],
    termSheetDetailsViewModel: null,
  );
  DisbursementState copywith({
    bool? isLoading,
    List<TermSheetDisbursedAmountDetailsData>?
    termSheetDisbursedAmountDetailsData,
    List<TermSheetViewModel>? termSheetViewList,
    TermSheetDetailsView? termSheetDetailsViewModel,
  }) {
    return DisbursementState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDisbursedAmountDetailsData:
          termSheetDisbursedAmountDetailsData ??
          this.termSheetDisbursedAmountDetailsData,
      termSheetViewList: termSheetViewList ?? this.termSheetViewList,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDisbursedAmountDetailsData,
    termSheetViewList,
    termSheetDetailsViewModel,
  ];
}
