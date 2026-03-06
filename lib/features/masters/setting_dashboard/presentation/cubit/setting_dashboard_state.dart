part of 'setting_dashboard_cubit.dart';

final class SettingDashboardState extends BaseState {
  final SettingDashboardModel? settingDashboardModel;
  final List<SettingDashboardModel> settingDashboardList;
  const SettingDashboardState({
    super.isLoading,
    this.settingDashboardModel,
    required this.settingDashboardList,
  });
  factory SettingDashboardState.initial() =>
      SettingDashboardState(settingDashboardList: []);

  SettingDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    SettingDashboardModel? settingDashboardModel,
    List<SettingDashboardModel>? settingDashboardList,
  }) {
    return SettingDashboardState(
      isLoading: isLoading ?? this.isLoading,
      settingDashboardModel:
          settingDashboardModel ?? this.settingDashboardModel,
      settingDashboardList: settingDashboardList ?? this.settingDashboardList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    settingDashboardModel,
    settingDashboardList,
  ];
}
