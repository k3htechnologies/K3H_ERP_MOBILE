part of 'temporary_alternate_accommodation_cubit.dart';

class TemporaryAlternateAccommodationState extends BaseState {
  final List<PaymentLedgerModel>? paymentLedgerList;
  final List<BusinessDevelopmentBuildingModel> buildingList;
  final int bankTotalCount;
  final List<BankListMasterModel> bankList;
  final int buildingTotalCount;
  final List<TemporaryAlternativeAccommodationDetailsModel> rentDetails;
  final List<TemporaryAlternativeAccommodationModel> rentList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String selectedTenure;
  final String currentTabName;
  final List<String> tenureList;
  final int selectedTenureIndex;
  final String searchText;
  final String paymentLedgerSearchText;

  const TemporaryAlternateAccommodationState({
    super.isLoading,
    required this.paymentLedgerList,
    required this.bankList,
    required this.bankTotalCount,
    required this.buildingList,
    required this.buildingTotalCount,
    required this.rentDetails,
    required this.rentList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.selectedTenure,
    required this.currentTabName,
    required this.tenureList,
    required this.selectedTenureIndex,
    required this.searchText,
    required this.paymentLedgerSearchText,
  });

  factory TemporaryAlternateAccommodationState.initial() =>
      TemporaryAlternateAccommodationState(
        isLoading: true,
        paymentLedgerList: [],
        bankList: [],
        bankTotalCount: 0,
        buildingList: [],
        buildingTotalCount: 0,
        rentDetails: [],
        rentList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        selectedTenure: "",
        currentTabName: "Additional TAA",
        tenureList: [],
        selectedTenureIndex: -1,
        searchText: '',
        paymentLedgerSearchText: '',
      );

  TemporaryAlternateAccommodationState copyWith({
    bool? isLoading,
    List<PaymentLedgerModel>? paymentLedgerList,
    List<BankListMasterModel>? bankList,
    int? bankTotalCount,
    List<BusinessDevelopmentBuildingModel>? buildingList,
    int? buildingTotalCount,
    List<TemporaryAlternativeAccommodationDetailsModel>? rentDetails,
    List<TemporaryAlternativeAccommodationModel>? rentList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? selectedTenure,
    String? currentTabName,
    List<String>? tenureList,
    int? selectedTenureIndex,
    String? searchText,
    String? paymentLedgerSearchText,
  }) {
    return TemporaryAlternateAccommodationState(
      isLoading: isLoading ?? this.isLoading,
      paymentLedgerList: paymentLedgerList ?? this.paymentLedgerList,
      bankList: bankList ?? this.bankList,
      bankTotalCount: bankTotalCount ?? this.bankTotalCount,
      buildingList: buildingList ?? this.buildingList,
      buildingTotalCount: buildingTotalCount ?? this.buildingTotalCount,
      rentDetails: rentDetails ?? this.rentDetails,
      rentList: rentList ?? this.rentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      selectedTenure: selectedTenure ?? this.selectedTenure,
      currentTabName: currentTabName ?? this.currentTabName,
      tenureList: tenureList ?? this.tenureList,
      selectedTenureIndex: selectedTenureIndex ?? this.selectedTenureIndex,
      searchText: searchText ?? this.searchText,
      paymentLedgerSearchText:
          paymentLedgerSearchText ?? this.paymentLedgerSearchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedgerList,
    bankList,
    bankTotalCount,
    buildingList,
    buildingTotalCount,
    rentDetails,
    rentList,
    totalNumberOfRecord,
    currentPage,
    selectedTenure,
    currentTabName,
    tenureList,
    selectedTenureIndex,
    searchText,
    paymentLedgerSearchText,
  ];
}
