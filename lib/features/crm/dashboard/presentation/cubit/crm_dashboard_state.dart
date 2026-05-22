part of 'crm_dashboard_cubit.dart';

class CrmDashboardState extends BaseState {
  final List<CrmDashboardModel> crmDashboardList;
  final String selectedFilterType;
  const CrmDashboardState({
    super.isLoading,
    required this.crmDashboardList,
    required this.selectedFilterType,
  });

  factory CrmDashboardState.initial() => CrmDashboardState(
    isLoading: true,
    crmDashboardList: [],
    selectedFilterType: "",
  );
  CrmDashboardState copyWith({
    bool? isLoading,
    List<CrmDashboardModel>? crmDashboardList,
    String? selectedFilterType,
  }) {
    return CrmDashboardState(
      isLoading: isLoading ?? this.isLoading,
      crmDashboardList: crmDashboardList ?? this.crmDashboardList,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
    );
  }

  @override
  List<Object?> get props => [isLoading, crmDashboardList, selectedFilterType];
}
