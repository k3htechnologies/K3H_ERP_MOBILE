part of 'parking_cubit.dart';

class ParkingState extends BaseState {
  final List<ParkingModel> parkingList;
  final String searchText;
  final Map<String, List<ParkingModel>>? groupedData;
  final Map<String, List<ParkingModel>>? wingGroupedData;
  final String? buildingCurrentPageKey;
  final int buildingCurrentPage;
  final String? wingCurrentPageKey;
  final int wingCurrentPage;
  final int availableParking;
  final int bookedParking;
  final int blockedParking;
  final int holdParking;
  final int memberParking;

  const ParkingState({
    super.isLoading,
    required this.parkingList,
    this.searchText = "",
    this.groupedData,
    this.wingGroupedData,
    this.buildingCurrentPageKey,
    this.buildingCurrentPage = 0,
    this.wingCurrentPageKey,
    this.wingCurrentPage = 0,
    this.availableParking = 0,
    this.bookedParking = 0,
    this.blockedParking = 0,
    this.holdParking = 0,
    this.memberParking = 0,
  });

  factory ParkingState.initial() => ParkingState(
        isLoading: true,
        parkingList: [],
        searchText: "",
        buildingCurrentPage: 0,
        wingCurrentPage: 0,
      );

  ParkingState copyWith({
    bool? isLoading,
    List<ParkingModel>? parkingList,
    String? searchText,
    Map<String, List<ParkingModel>>? groupedData,
    Map<String, List<ParkingModel>>? wingGroupedData,
    String? buildingCurrentPageKey,
    int? buildingCurrentPage,
    String? wingCurrentPageKey,
    int? wingCurrentPage,
    int? availableParking,
    int? bookedParking,
    int? blockedParking,
    int? holdParking,
    int? memberParking,
  }) =>
      ParkingState(
        isLoading: isLoading ?? this.isLoading,
        parkingList: parkingList ?? this.parkingList,
        searchText: searchText ?? this.searchText,
        groupedData: groupedData ?? this.groupedData,
        wingGroupedData: wingGroupedData ?? this.wingGroupedData,
        buildingCurrentPageKey:
            buildingCurrentPageKey ?? this.buildingCurrentPageKey,
        buildingCurrentPage:
            buildingCurrentPage ?? this.buildingCurrentPage,
        wingCurrentPageKey: wingCurrentPageKey ?? this.wingCurrentPageKey,
        wingCurrentPage: wingCurrentPage ?? this.wingCurrentPage,
        availableParking: availableParking ?? this.availableParking,
        bookedParking: bookedParking ?? this.bookedParking,
        blockedParking: blockedParking ?? this.blockedParking,
        holdParking: holdParking ?? this.holdParking,
        memberParking: memberParking ?? this.memberParking,
      );

  @override
  List<Object?> get props => [
        isLoading,
        parkingList,
        searchText,
        groupedData,
        wingGroupedData,
        buildingCurrentPageKey,
        buildingCurrentPage,
        wingCurrentPageKey,
        wingCurrentPage,
        availableParking,
        bookedParking,
        blockedParking,
        holdParking,
        memberParking,
      ];
}
