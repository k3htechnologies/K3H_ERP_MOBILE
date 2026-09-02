part of 'gate_pass_cubit.dart';

class GatePassState extends BaseState {
  final List<GatePassModel> gatePassList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String filterByMobileNumber;
  final String filterByAddress;
  final String filterByPurpose;
  final String filterByAppointmentWith;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  const GatePassState({
    super.isLoading,
    required this.gatePassList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.filterByMobileNumber,
    required this.filterByAddress,
    required this.filterByPurpose,
    required this.filterByAppointmentWith,
    this.filterStartDate,
    this.filterEndDate,
  });

  factory GatePassState.inital() => GatePassState(
    gatePassList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: '',
    filterByMobileNumber: '',
    filterByAddress: '',
    filterByPurpose: '',
    filterByAppointmentWith: '',
    filterStartDate: null,
    filterEndDate: null,
  );
  static const _noChange = Object();
  GatePassState copyWith({
    bool? isLoading,
    List<GatePassModel>? gatePassList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? filterByMobileNumber,
    String? filterByAddress,
    String? filterByPurpose,
    String? filterByAppointmentWith,
    Object? filterStartDate = _noChange,
    Object? filterEndDate = _noChange,
  }) {
    return GatePassState(
      isLoading: isLoading ?? this.isLoading,
      gatePassList: gatePassList ?? this.gatePassList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByAddress: filterByAddress ?? this.filterByAddress,
      filterByPurpose: filterByPurpose ?? this.filterByPurpose,
      filterByAppointmentWith:
          filterByAppointmentWith ?? this.filterByAppointmentWith,
      filterStartDate:
          filterStartDate == _noChange
              ? this.filterStartDate
              : filterStartDate as DateTime?,

      filterEndDate:
          filterEndDate == _noChange
              ? this.filterEndDate
              : filterEndDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    gatePassList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByMobileNumber,
    filterByAddress,
    filterByPurpose,
    filterByAppointmentWith,
    filterStartDate,
    filterEndDate,
  ];
}
