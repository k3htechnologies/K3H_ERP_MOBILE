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
  final String filterCpCompany;
  final String filterCpMobileNo;
  final String filterApplicantName;
  final String filterApplicantMobileNo;
  final String filterWing;
  final String filterFlat;
  final String filterFloor;
  final double filterAgreementValue;
  final String filterBookingType;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;

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
    required this.filterCpCompany,
    required this.filterCpMobileNo,
    required this.filterApplicantName,
    required this.filterApplicantMobileNo,
    required this.filterWing,
    required this.filterFlat,
    required this.filterFloor,
    required this.filterAgreementValue,
    required this.filterBookingType,
    required this.filterByFromDate,
    required this.filterByToDate,
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
    filterCpCompany: '',
    filterCpMobileNo: '',
    filterApplicantName: '',
    filterApplicantMobileNo: '',
    filterWing: '',
    filterFlat: '',
    filterFloor: '',
    filterAgreementValue: 0,
    filterBookingType: '',
    filterByFromDate: null,
    filterByToDate: null,
  );
  static const _noChange = Object();

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
    Object? filterCpCompany = _noChange,
    Object? filterCpMobileNo = _noChange,
    Object? filterApplicantName = _noChange,
    Object? filterApplicantMobileNo = _noChange,
    Object? filterWing = _noChange,
    Object? filterFlat = _noChange,
    Object? filterFloor = _noChange,
    Object? filterAgreementValue = _noChange,
    Object? filterBookingType = _noChange,
    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,
  }) {
    return BrokerageState(
      isLoading: isLoading ?? this.isLoading,
      brokerageList: brokerageList ?? this.brokerageList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,

      brokerageInvoiceList: brokerageInvoiceList ?? this.brokerageInvoiceList,

      totalNumberOfRecordInvoice:
          totalNumberOfRecordInvoice ?? this.totalNumberOfRecordInvoice,

      currentPageInvoice: currentPageInvoice ?? this.currentPageInvoice,

      brokeragePaidList: brokeragePaidList ?? this.brokeragePaidList,

      totalNumberOfRecordPaid:
          totalNumberOfRecordPaid ?? this.totalNumberOfRecordPaid,

      currentPagePaid: currentPagePaid ?? this.currentPagePaid,

      filterCpCompany:
          filterCpCompany == _noChange
              ? this.filterCpCompany
              : filterCpCompany as String,

      filterCpMobileNo:
          filterCpMobileNo == _noChange
              ? this.filterCpMobileNo
              : filterCpMobileNo as String,

      filterApplicantName:
          filterApplicantName == _noChange
              ? this.filterApplicantName
              : filterApplicantName as String,

      filterApplicantMobileNo:
          filterApplicantMobileNo == _noChange
              ? this.filterApplicantMobileNo
              : filterApplicantMobileNo as String,

      filterWing:
          filterWing == _noChange ? this.filterWing : filterWing as String,

      filterFlat:
          filterFlat == _noChange ? this.filterFlat : filterFlat as String,

      filterFloor:
          filterFloor == _noChange ? this.filterFloor : filterFloor as String,

      filterAgreementValue:
          filterAgreementValue == _noChange
              ? this.filterAgreementValue
              : filterAgreementValue as double,

      filterBookingType:
          filterBookingType == _noChange
              ? this.filterBookingType
              : filterBookingType as String,

      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,

      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
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
    currentPagePaid,
    filterCpCompany,
    filterCpMobileNo,
    filterApplicantName,
    filterApplicantMobileNo,
    filterWing,
    filterFlat,
    filterFloor,
    filterAgreementValue,
    filterBookingType,
    filterByFromDate,
    filterByToDate,
  ];
}
