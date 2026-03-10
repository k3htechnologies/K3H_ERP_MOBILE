part of 'litigation_dashboard_cubit.dart';

final class LitigationDashboardState extends BaseState {
  final LitigationDashboardModel? litigationDashboardModel;
  final List<LitigationDashboardModel> litigationDashboardModelList;
  const LitigationDashboardState({
    super.isLoading,
    this.litigationDashboardModel,
    required this.litigationDashboardModelList,
  });

  factory LitigationDashboardState.initial() => LitigationDashboardState(
    isLoading: true,
    litigationDashboardModelList: [],
  );

  LitigationDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    LitigationDashboardModel? litigationDashboardModel,
    List<LitigationDashboardModel>? litigationDashboardModelList,
  }) {
    return LitigationDashboardState(
      isLoading: isLoading ?? this.isLoading,
      litigationDashboardModel:
          litigationDashboardModel ?? this.litigationDashboardModel,
      litigationDashboardModelList:
          litigationDashboardModelList ?? this.litigationDashboardModelList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    litigationDashboardModel,
    litigationDashboardModelList,
  ];
}
