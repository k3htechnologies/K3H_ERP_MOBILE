part of 'parking_cubit.dart';

class ParkingState extends BaseState {
  final List<ParkingModel> parkingList;
  final String searchText;
  final Map<String, List<ParkingModel>>? groupedData;
  final Map<String, List<ParkingModel>>? wingGroupedData;
  final Map<String, List<ParkingModel>>? originalWingGroupedData;
  final String? buildingCurrentPageKey;
  final int buildingCurrentPage;
  final String? wingCurrentPageKey;
  final int wingCurrentPage;
  final int availableParking;
  final int bookedParking;
  final int blockedParking;
  final int holdParking;
  final int allotedParking;

  const ParkingState({
    super.isLoading,
    required this.parkingList,

    this.searchText = "",
    this.groupedData,
    this.wingGroupedData,
    this.originalWingGroupedData,
    this.buildingCurrentPageKey,
    this.buildingCurrentPage = 0,
    this.wingCurrentPageKey,
    this.wingCurrentPage = 0,
    this.availableParking = 0,
    this.bookedParking = 0,
    this.blockedParking = 0,
    this.holdParking = 0,
    this.allotedParking = 0,
  });

  factory ParkingState.initial() => ParkingState(
    isLoading: false,
    parkingList: [],
    searchText: "",
    groupedData: null,
    wingGroupedData: null,
    originalWingGroupedData: null,
    buildingCurrentPageKey: null,
    buildingCurrentPage: 0,
    wingCurrentPageKey: null,
    wingCurrentPage: 0,
    availableParking: 0,
    bookedParking: 0,
    blockedParking: 0,
    holdParking: 0,
    allotedParking: 0,
  );
  ParkingState copyWith({
    bool? isLoading,
    List<ParkingModel>? parkingList,
    String? searchText,
    Map<String, List<ParkingModel>>? groupedData,
    Map<String, List<ParkingModel>>? wingGroupedData,
    Map<String, List<ParkingModel>>? originalWingGroupedData,
    String? buildingCurrentPageKey,
    int? buildingCurrentPage,
    String? wingCurrentPageKey,
    int? wingCurrentPage,
    int? availableParking,
    int? bookedParking,
    int? blockedParking,
    int? holdParking,
    int? allotedParking,
  }) => ParkingState(
    isLoading: isLoading ?? this.isLoading,
    parkingList: parkingList ?? this.parkingList,
    searchText: searchText ?? this.searchText,
    groupedData: groupedData ?? this.groupedData,
    wingGroupedData: wingGroupedData ?? this.wingGroupedData,
    originalWingGroupedData:
        originalWingGroupedData ?? this.originalWingGroupedData,
    buildingCurrentPageKey:
        buildingCurrentPageKey ?? this.buildingCurrentPageKey,
    buildingCurrentPage: buildingCurrentPage ?? this.buildingCurrentPage,
    wingCurrentPageKey: wingCurrentPageKey ?? this.wingCurrentPageKey,
    wingCurrentPage: wingCurrentPage ?? this.wingCurrentPage,
    availableParking: availableParking ?? this.availableParking,
    bookedParking: bookedParking ?? this.bookedParking,
    blockedParking: blockedParking ?? this.blockedParking,
    holdParking: holdParking ?? this.holdParking,
    allotedParking: allotedParking ?? this.allotedParking,
  );

  @override
  List<Object?> get props => [
    isLoading,
    parkingList,
    searchText,
    groupedData,
    wingGroupedData,
    originalWingGroupedData,
    buildingCurrentPageKey,
    buildingCurrentPage,
    wingCurrentPageKey,
    wingCurrentPage,
    availableParking,
    bookedParking,
    blockedParking,
    holdParking,
    allotedParking,
  ];
}
