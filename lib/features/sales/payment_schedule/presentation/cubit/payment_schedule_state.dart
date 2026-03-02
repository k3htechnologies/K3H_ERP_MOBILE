import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_master.model.dart';

class PaymentScheduleMasterState extends BaseState {
  final List<PaymentScheduleMasterModel> paymentScheduleMasterList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;

  const PaymentScheduleMasterState({
    required super.isLoading,
    required this.paymentScheduleMasterList,
    required this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory PaymentScheduleMasterState.initial() => PaymentScheduleMasterState(
    isLoading: false,
    paymentScheduleMasterList: [],
    searchText: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: "CreatedDate",
    currentSortDirection: "DESC",
  );

  PaymentScheduleMasterState copyWith({
    bool? isLoading,
    List<PaymentScheduleMasterModel>? paymentScheduleMasterList,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return PaymentScheduleMasterState(
      isLoading: isLoading ?? this.isLoading,
      paymentScheduleMasterList:
          paymentScheduleMasterList ?? this.paymentScheduleMasterList,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentScheduleMasterList,
    searchText,
    totalNumberOfRecord,
    currentPage,
    currentSortColumn,
    currentSortDirection,
  ];
}
