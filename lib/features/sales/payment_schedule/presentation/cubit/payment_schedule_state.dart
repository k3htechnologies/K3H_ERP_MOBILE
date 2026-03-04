import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/data/model/payment_schedule.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';

class PaymentScheduleMasterState extends BaseState {
  final List<PaymentScheduleMasterModel> paymentScheduleMasterList;
  final String searchText;
  final int totalNumberOfRecord;
  final int currentPage;
  final String currentSortColumn;
  final String currentSortDirection;

  final PaymentScheduleSchemeModel? selectedScheme;

  final double totalCumulativePercentage;

  const PaymentScheduleMasterState({
    required super.isLoading,
    required this.paymentScheduleMasterList,
    required this.searchText,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.selectedScheme,
    required this.totalCumulativePercentage,
  });

  factory PaymentScheduleMasterState.initial() => PaymentScheduleMasterState(
    isLoading: false,
    paymentScheduleMasterList: [],
    searchText: "",
    totalNumberOfRecord: 0,
    currentPage: 1,
    currentSortColumn: "CreatedDate",
    currentSortDirection: "DESC",
    selectedScheme: null,
    totalCumulativePercentage: 0.0,
  );

  PaymentScheduleMasterState copyWith({
    bool? isLoading,
    List<PaymentScheduleMasterModel>? paymentScheduleMasterList,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    PaymentScheduleSchemeModel? selectedScheme,
    double? totalCumulativePercentage,
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
      selectedScheme: selectedScheme ?? this.selectedScheme,
      totalCumulativePercentage:
          totalCumulativePercentage ?? this.totalCumulativePercentage,
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
    selectedScheme,
    totalCumulativePercentage,
  ];
}
