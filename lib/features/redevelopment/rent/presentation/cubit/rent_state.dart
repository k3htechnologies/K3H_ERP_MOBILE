part of 'rent_cubit.dart';

class RentState extends BaseState {
  final List<RedevelopmentBuildingModel> buildingList;
  final List<RentDetailsModel> rentDetails;
  final List<RentModel> rentList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String selectedTenure;
  final int currentTabIndex;
  final List<String> tenureList;
  final int selectedTenureIndex;

  const RentState({
    super.isLoading,
    required this.buildingList,
    required this.rentDetails,
    required this.rentList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.selectedTenure,
    required this.currentTabIndex,
    required this.tenureList,
    required this.selectedTenureIndex,
  });

  factory RentState.initial() => RentState(
    isLoading: true,
    buildingList: [],
    rentDetails: [],
    rentList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    selectedTenure: "",
    currentTabIndex: 0,
    tenureList: [],
    selectedTenureIndex: -1,
  );

  RentState copyWith({
    bool? isLoading,
    List<RedevelopmentBuildingModel>? buildingList,
    List<RentDetailsModel>? rentDetails,
    List<RentModel>? rentList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? selectedTenure,
    int? currentTabIndex,
    List<String>? tenureList,
    int? selectedTenureIndex,
  }) {
    return RentState(
      isLoading: isLoading ?? this.isLoading,
      buildingList: buildingList ?? this.buildingList,
      rentDetails: rentDetails ?? this.rentDetails,
      rentList: rentList ?? this.rentList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      selectedTenure: selectedTenure ?? this.selectedTenure,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      tenureList: tenureList ?? this.tenureList,
      selectedTenureIndex: selectedTenureIndex ?? this.selectedTenureIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    buildingList,
    rentDetails,
    rentList,
    totalNumberOfRecord,
    currentPage,
    selectedTenure,
    currentTabIndex,
    tenureList,
    selectedTenureIndex,
  ];
}
