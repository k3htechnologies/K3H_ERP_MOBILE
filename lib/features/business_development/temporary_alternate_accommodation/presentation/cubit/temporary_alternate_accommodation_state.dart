part of 'temporary_alternate_accommodation_cubit.dart';

class TemporaryAlternateAccommodationState extends BaseState {
  final List<PaymentLedgerModel>? paymentLedgerList;
  final List<TemporaryAlternativeAccommodationModel> rentList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String selectedTenure;
  final String chargeType;
  final List<String> tenureList;
  final int selectedTenureIndex;
  final String searchText;
  final String filterByExistingUnitType;
  final String filterByApplicantName;
  final String filterByApplicantType;
  final String paymentLedgerSearchText;

  const TemporaryAlternateAccommodationState({
    super.isLoading,
    required this.paymentLedgerList,
    required this.rentList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.selectedTenure,
    required this.chargeType,
    required this.tenureList,
    required this.selectedTenureIndex,
    required this.searchText,
    required this.filterByExistingUnitType,
    required this.filterByApplicantName,
    required this.filterByApplicantType,
    required this.paymentLedgerSearchText,
  });

  factory TemporaryAlternateAccommodationState.initial() =>
      TemporaryAlternateAccommodationState(
        isLoading: true,
        paymentLedgerList: [],
        rentList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        selectedTenure: "",
        chargeType: "Additional TAA",
        tenureList: [],
        selectedTenureIndex: -1,
        searchText: '',
        filterByExistingUnitType: '',
        filterByApplicantName: '',
        filterByApplicantType: '',

        paymentLedgerSearchText: '',
      );

  TemporaryAlternateAccommodationState copyWith({
    bool? isLoading,
    List<PaymentLedgerModel>? paymentLedgerList,
    List<TemporaryAlternativeAccommodationDetailsModel>? rentDetails,
    List<TemporaryAlternativeAccommodationModel>? rentList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? selectedTenure,
    String? chargeType,
    List<String>? tenureList,
    int? selectedTenureIndex,
    String? searchText,
    String? filterByExistingUnitType,
    String? filterByApplicantName,
    String? filterByApplicantType,

    String? paymentLedgerSearchText,
  }) {
    return TemporaryAlternateAccommodationState(
      isLoading: isLoading ?? this.isLoading,
      paymentLedgerList: paymentLedgerList ?? this.paymentLedgerList,
      rentList: rentList ?? this.rentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      selectedTenure: selectedTenure ?? this.selectedTenure,
      chargeType: chargeType ?? this.chargeType,
      tenureList: tenureList ?? this.tenureList,
      selectedTenureIndex: selectedTenureIndex ?? this.selectedTenureIndex,
      searchText: searchText ?? this.searchText,
      filterByExistingUnitType:
          filterByExistingUnitType ?? this.filterByExistingUnitType,
      filterByApplicantName:
          filterByApplicantName ?? this.filterByApplicantName,
      filterByApplicantType:
          filterByApplicantType ?? this.filterByApplicantType,
      paymentLedgerSearchText:
          paymentLedgerSearchText ?? this.paymentLedgerSearchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    paymentLedgerList,
    rentList,
    totalNumberOfRecord,
    currentPage,
    selectedTenure,
    chargeType,
    tenureList,
    selectedTenureIndex,
    searchText,
    filterByExistingUnitType,
    filterByApplicantName,
    filterByApplicantType,
    paymentLedgerSearchText,
  ];
}
