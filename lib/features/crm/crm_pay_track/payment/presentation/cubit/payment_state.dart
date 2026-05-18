import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule.model.dart';

class PaymentState extends BaseState {
  final List<PayTrackPaymentLedgerModel> paymentLedger;
  final List<PayTrackPaymentScheduleModel> payTrackPaymentScheduleList;
  final List<PayTrackPaymentLedgerSummaryModel>
  payTrackPaymentLedgerSummaryList;

  const PaymentState({
    super.isLoading,
    required this.paymentLedger,
    required this.payTrackPaymentScheduleList,
    required this.payTrackPaymentLedgerSummaryList,
  });

  factory PaymentState.initial() => PaymentState(
    isLoading: true,
    paymentLedger: [],
    payTrackPaymentScheduleList: [],
    payTrackPaymentLedgerSummaryList: [],
  );

  PaymentState copyWith({
    bool? isLoading,
    List<PayTrackPaymentLedgerModel>? paymentLedger,
    List<PayTrackPaymentScheduleModel>? payTrackPaymentScheduleList,
    List<PayTrackPaymentLedgerSummaryModel>? payTrackPaymentLedgerSummaryList,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      paymentLedger: paymentLedger ?? this.paymentLedger,
      payTrackPaymentScheduleList:
          payTrackPaymentScheduleList ?? this.payTrackPaymentScheduleList,
      payTrackPaymentLedgerSummaryList:
          payTrackPaymentLedgerSummaryList ??
          this.payTrackPaymentLedgerSummaryList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedger,
    payTrackPaymentScheduleList,
    payTrackPaymentLedgerSummaryList,
  ];
}
