part of 'visitor_management_dashboard_cubit.dart';

class VisitorManagementDashboardState extends BaseState {
  final List<GatePassDashboardModel> gatePassDashboardList;
  const VisitorManagementDashboardState({
    super.isLoading,
    required this.gatePassDashboardList,
  });
  factory VisitorManagementDashboardState.initial() =>
      VisitorManagementDashboardState(gatePassDashboardList: []);

  VisitorManagementDashboardState copyWith({
    bool? isLoading,
    List<GatePassDashboardModel>? gatePassDashboardList,
  }) {
    return VisitorManagementDashboardState(
      isLoading: isLoading ?? this.isLoading,
      gatePassDashboardList:
          gatePassDashboardList ?? this.gatePassDashboardList,
    );
  }

  @override
  List<Object?> get props => [isLoading, gatePassDashboardList];
}
