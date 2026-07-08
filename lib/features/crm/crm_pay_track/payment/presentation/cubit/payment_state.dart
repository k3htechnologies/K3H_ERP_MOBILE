import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule_demand_summary.model.dart';

class PaymentState extends BaseState {
  final List<PayTrackPaymentLedgerModel> paymentLedger;
  final List<PayTrackPaymentScheduleModel> payTrackPaymentScheduleList;
  final List<PayTrackPaymentLedgerSummaryModel>
  payTrackPaymentLedgerSummaryList;
  final List<PayTrackPaymentScheduleDemandSummaryModel>
  payTrackPaymentScheduleDemandSummaryModel;
  final String searchText;
  

  const PaymentState({
    super.isLoading,
    required this.paymentLedger,
    required this.payTrackPaymentScheduleList,
    required this.payTrackPaymentLedgerSummaryList,
    required this.searchText,
    required this.payTrackPaymentScheduleDemandSummaryModel,
   
  });

  factory PaymentState.initial() => PaymentState(
    isLoading: true,
    paymentLedger: [],
    payTrackPaymentScheduleList: [],
    payTrackPaymentLedgerSummaryList: [],
    searchText: "",
    payTrackPaymentScheduleDemandSummaryModel: [],
  );

  PaymentState copyWith({
    bool? isLoading,
    List<PayTrackPaymentLedgerModel>? paymentLedger,
    List<PayTrackPaymentScheduleModel>? payTrackPaymentScheduleList,
    List<PayTrackPaymentLedgerSummaryModel>? payTrackPaymentLedgerSummaryList,
    String? searchText,
    List<PayTrackPaymentScheduleDemandSummaryModel>?
    payTrackPaymentScheduleDemandSummaryModel,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      paymentLedger: paymentLedger ?? this.paymentLedger,
      payTrackPaymentScheduleList:
          payTrackPaymentScheduleList ?? this.payTrackPaymentScheduleList,
      payTrackPaymentLedgerSummaryList:
          payTrackPaymentLedgerSummaryList ??
          this.payTrackPaymentLedgerSummaryList,
      payTrackPaymentScheduleDemandSummaryModel:
          payTrackPaymentScheduleDemandSummaryModel ??
          this.payTrackPaymentScheduleDemandSummaryModel,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedger,
    payTrackPaymentScheduleList,
    payTrackPaymentLedgerSummaryList,
    payTrackPaymentScheduleDemandSummaryModel,
    searchText,
  ];
}
