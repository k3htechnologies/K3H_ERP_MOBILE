part of 'other_charges_cubit.dart';

class OtherChargesState extends BaseState {
  final List<OtherChargeModel> otherChargesList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  const OtherChargesState({
    super.isLoading,
    required this.otherChargesList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory OtherChargesState.initial() => OtherChargesState(
    isLoading: true,
    otherChargesList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );

  OtherChargesState copyWith({
    bool? isLoading,
    List<OtherChargeModel>? otherChargesList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return OtherChargesState(
      isLoading: isLoading ?? this.isLoading,
      otherChargesList: otherChargesList ?? this.otherChargesList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    otherChargesList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
  ];
}
