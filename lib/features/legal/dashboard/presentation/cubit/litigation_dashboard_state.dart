part of 'litigation_dashboard_cubit.dart';

final class LitigationDashboardState extends BaseState {
  final LitigationDashboardModel? litigationDashboardModel;
  final List<LitigationDashboardModel> litigationDashboardModelList;
  final int selectedRangeIndex;
  const LitigationDashboardState({
    super.isLoading,
    this.litigationDashboardModel,
    required this.litigationDashboardModelList,
    required this.selectedRangeIndex,
  });

  factory LitigationDashboardState.initial({ required int selectedRangeIndex}) =>
      LitigationDashboardState(
        isLoading: true,
        litigationDashboardModelList: [],
        selectedRangeIndex: selectedRangeIndex,
      );

  LitigationDashboardState copyWith({
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
    LitigationDashboardModel? litigationDashboardModel,
    List<LitigationDashboardModel>? litigationDashboardModelList,
    int? selectedRangeIndex,
  }) {
    return LitigationDashboardState(
      isLoading: isLoading ?? this.isLoading,
      litigationDashboardModel:
          litigationDashboardModel ?? this.litigationDashboardModel,
      litigationDashboardModelList:
          litigationDashboardModelList ?? this.litigationDashboardModelList,
      selectedRangeIndex: selectedRangeIndex ?? this.selectedRangeIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    litigationDashboardModel,
    litigationDashboardModelList,
    selectedRangeIndex,
  ];
}
