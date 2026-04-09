import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule.model.dart';

class PaymentState extends BaseState {
  final List<PayTrackPaymentLedgerModel> paymentLedger;
  final List<PayTrackPaymentScheduleModel> payTrackPaymentScheduleList;

  const PaymentState({
    super.isLoading,
    required this.paymentLedger,
    required this.payTrackPaymentScheduleList,
  });

  factory PaymentState.initial() => PaymentState(
    isLoading: true,
    paymentLedger: [],
    payTrackPaymentScheduleList: [],
  );

  PaymentState copyWith({
    bool? isLoading,
    List<PayTrackPaymentLedgerModel>? paymentLedger,
    List<PayTrackPaymentScheduleModel>? payTrackPaymentScheduleList,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      paymentLedger: paymentLedger ?? this.paymentLedger,
      payTrackPaymentScheduleList:
          payTrackPaymentScheduleList ?? this.payTrackPaymentScheduleList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedger,
    payTrackPaymentScheduleList,
  ];
}
