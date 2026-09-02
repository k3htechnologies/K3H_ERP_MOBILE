part of 'disbursement_cubit.dart';

class DisbursementState extends BaseState {
  final TermSheetDetailsView? termSheetDetailsViewModel;

  const DisbursementState({super.isLoading, this.termSheetDetailsViewModel});

  factory DisbursementState.inital() =>
      DisbursementState(termSheetDetailsViewModel: null);
  DisbursementState copywith({
    bool? isLoading,
    List<TermSheetDisbursedAmountDetailsData>?
    termSheetDisbursedAmountDetailsData,
    TermSheetDetailsView? termSheetDetailsViewModel,
  }) {
    return DisbursementState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
    );
  }

  @override
  List<Object?> get props => [isLoading, termSheetDetailsViewModel];
}
