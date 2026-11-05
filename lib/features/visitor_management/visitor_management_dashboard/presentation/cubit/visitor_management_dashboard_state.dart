part of 'visitor_management_dashboard_cubit.dart';

class VisitorManagementDashboardState extends BaseState {
  final List<GatePassDashboardModel> gatePassDashboardList;
  final String selectedFilter;
  const VisitorManagementDashboardState({
    super.isLoading,
    required this.gatePassDashboardList,
    required this.selectedFilter,
  });
  factory VisitorManagementDashboardState.initial() =>
      VisitorManagementDashboardState(
        gatePassDashboardList: [],
        selectedFilter: "ALL",
      );

  VisitorManagementDashboardState copyWith({
    bool? isLoading,
    List<GatePassDashboardModel>? gatePassDashboardList,
    String? selectedFilter,
  }) {
    return VisitorManagementDashboardState(
      isLoading: isLoading ?? this.isLoading,
      gatePassDashboardList:
          gatePassDashboardList ?? this.gatePassDashboardList,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [isLoading, gatePassDashboardList, selectedFilter];
}
