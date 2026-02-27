part of 'redevlopment_dashboard_cubit.dart';

final class RedevlopmentDashboardState extends BaseState {
  final RedevelopmentDashboardModel? redevelopmentDashboardModel;
  final List<RedevelopmentDashboardModel> redevelopmentDashboardModelList;
  const RedevlopmentDashboardState({
    super.isLoading,
    this.redevelopmentDashboardModel,
    required this.redevelopmentDashboardModelList,
  });
  factory RedevlopmentDashboardState.initial() => RedevlopmentDashboardState(
    isLoading: true,
    redevelopmentDashboardModelList: [],
  );
  RedevlopmentDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    RedevelopmentDashboardModel? redevelopmentDashboardModel,
    List<RedevelopmentDashboardModel>? redevelopmentDashboardModelList,
  }) {
    return RedevlopmentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      redevelopmentDashboardModel:
          redevelopmentDashboardModel ?? this.redevelopmentDashboardModel,
      redevelopmentDashboardModelList:
          redevelopmentDashboardModelList ??
          this.redevelopmentDashboardModelList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    redevelopmentDashboardModel,
    redevelopmentDashboardModelList,
  ];
}
