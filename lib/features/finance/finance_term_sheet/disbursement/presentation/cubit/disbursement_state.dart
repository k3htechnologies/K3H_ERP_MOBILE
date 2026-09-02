part of 'disbursement_cubit.dart';

class DisbursementState extends BaseState {
  final List<TermSheetDisbursedAmountDetailsData>
  termSheetDisbursedAmountDetailsData;
  final TermSheetDetailsView? termSheetDetailsViewModel;

  const DisbursementState({
    super.isLoading,
    required this.termSheetDisbursedAmountDetailsData,
    this.termSheetDetailsViewModel,
  });

  factory DisbursementState.inital() => DisbursementState(
    termSheetDisbursedAmountDetailsData: [],
    termSheetDetailsViewModel: null,
  );
  DisbursementState copywith({
    bool? isLoading,
    List<TermSheetDisbursedAmountDetailsData>?
    termSheetDisbursedAmountDetailsData,
    TermSheetDetailsView? termSheetDetailsViewModel,
  }) {
    return DisbursementState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDisbursedAmountDetailsData:
          termSheetDisbursedAmountDetailsData ??
          this.termSheetDisbursedAmountDetailsData,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDisbursedAmountDetailsData,
    termSheetDetailsViewModel,
  ];
}
