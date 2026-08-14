part of 'crm_dashboard_cubit.dart';

class CrmDashboardState extends BaseState {
  final List<CrmDashboardModel> crmDashboardList;
  final CrmDashboardModel? crmDashboardModel;

  final String selectedFilterType;
  const CrmDashboardState({
    super.isLoading,
    required this.crmDashboardList,
    required this.selectedFilterType,
    this.crmDashboardModel,
  });

  factory CrmDashboardState.initial() => CrmDashboardState(
    isLoading: true,
    crmDashboardList: [],
    crmDashboardModel: null,
    selectedFilterType: "",
  );
  CrmDashboardState copyWith({
    bool? isLoading,
    List<CrmDashboardModel>? crmDashboardList,
    String? selectedFilterType,
    CrmDashboardModel? crmDashboardModel,
  }) {
    return CrmDashboardState(
      isLoading: isLoading ?? this.isLoading,
      crmDashboardList: crmDashboardList ?? this.crmDashboardList,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
      crmDashboardModel: crmDashboardModel ?? this.crmDashboardModel,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    crmDashboardList,
    selectedFilterType,
    crmDashboardModel,
  ];
}
