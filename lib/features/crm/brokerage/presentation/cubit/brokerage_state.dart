part of 'brokerage_cubit.dart';

class BrokerageState extends BaseState {
  final List<BrokerageModel> brokerageList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final List<BrokerageInvoiceModel> brokerageInvoiceList;
  final int totalNumberOfRecordInvoice;
  final int currentPageInvoice;
  final List<PaidBrokerageBookingModel> brokeragePaidList;
  final int totalNumberOfRecordPaid;
  final int currentPagePaid;

  const BrokerageState({
    super.isLoading,
    required this.brokerageList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.brokerageInvoiceList,
    required this.totalNumberOfRecordInvoice,
    required this.currentPageInvoice,
    required this.brokeragePaidList,
    required this.totalNumberOfRecordPaid,
    required this.currentPagePaid,
  });

  factory BrokerageState.initial() => BrokerageState(
    isLoading: true,
    brokerageList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    brokerageInvoiceList: [],
    totalNumberOfRecordInvoice: 0,
    currentPageInvoice: 1,
    brokeragePaidList: [],
    totalNumberOfRecordPaid: 0,
    currentPagePaid: 1,
  );

  BrokerageState copyWith({
    bool? isLoading,
    List<BrokerageModel>? brokerageList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    List<BrokerageInvoiceModel>? brokerageInvoiceList,
    int? totalNumberOfRecordInvoice,
    int? currentPageInvoice,
    List<PaidBrokerageBookingModel>? brokeragePaidList,
    int? totalNumberOfRecordPaid,
    int? currentPagePaid,
  }) {
    return BrokerageState(
      isLoading: isLoading ?? this.isLoading,
      brokerageList: brokerageList ?? this.brokerageList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      brokerageInvoiceList: brokerageInvoiceList ?? this.brokerageInvoiceList,
      totalNumberOfRecordInvoice: totalNumberOfRecordInvoice ?? this.totalNumberOfRecordInvoice,
      currentPageInvoice: currentPageInvoice ?? this.currentPageInvoice,
      brokeragePaidList: brokeragePaidList ?? this.brokeragePaidList,
      totalNumberOfRecordPaid: totalNumberOfRecordPaid ?? this.totalNumberOfRecordPaid,
      currentPagePaid: currentPagePaid ?? this.currentPagePaid
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    brokerageList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    brokerageInvoiceList,
    totalNumberOfRecordInvoice,
    currentPageInvoice,
    brokeragePaidList,
    totalNumberOfRecordPaid,
    currentPagePaid
  ];

}

