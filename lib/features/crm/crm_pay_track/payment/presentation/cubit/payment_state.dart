import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule_demand_summary.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';

class PaymentState extends BaseState {
  final List<PayTrackPaymentLedgerModel> paymentLedger;
  final List<PayTrackPaymentScheduleModel> payTrackPaymentScheduleList;
  final List<PayTrackPaymentLedgerSummaryModel>
  payTrackPaymentLedgerSummaryList;
  final List<PayTrackPaymentScheduleDemandSummaryModel>
  payTrackPaymentScheduleDemandSummaryModel;
  final BookingModel? bookingData;
  final List<OtherChargeModel> otherChargesList;
  final String searchText;

  const PaymentState({
    super.isLoading,
    required this.paymentLedger,
    required this.payTrackPaymentScheduleList,
    required this.payTrackPaymentLedgerSummaryList,
    required this.searchText,
    required this.payTrackPaymentScheduleDemandSummaryModel,
    required this.bookingData,
    required this.otherChargesList,
  });

  factory PaymentState.initial() => PaymentState(
    isLoading: true,
    paymentLedger: [],
    payTrackPaymentScheduleList: [],
    payTrackPaymentLedgerSummaryList: [],
    searchText: "",
    payTrackPaymentScheduleDemandSummaryModel: [],
    bookingData: null,
    otherChargesList: [],
  );

  PaymentState copyWith({
    bool? isLoading,
    List<PayTrackPaymentLedgerModel>? paymentLedger,
    List<PayTrackPaymentScheduleModel>? payTrackPaymentScheduleList,
    List<PayTrackPaymentLedgerSummaryModel>? payTrackPaymentLedgerSummaryList,
    String? searchText,
    List<PayTrackPaymentScheduleDemandSummaryModel>?
    payTrackPaymentScheduleDemandSummaryModel,
    BookingModel? bookingData,
    List<OtherChargeModel>? otherChargesList,
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
      bookingData: bookingData ?? this.bookingData,
      searchText: searchText ?? this.searchText,
      otherChargesList: otherChargesList ?? this.otherChargesList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedger,
    payTrackPaymentScheduleList,
    payTrackPaymentLedgerSummaryList,
    payTrackPaymentScheduleDemandSummaryModel,
    bookingData,
    searchText,
    otherChargesList,
  ];
}
