part of 'project_lead_cubit.dart';

class ProjectLeadState extends BaseState {
  final List<RedevelopmentModel> redevelopmentList;
  final int redevelopmentCurrentPage;
  final int redevelopmentTotalNumberOfRecord;
  final String redevelopmentSearchText;
  final List<LandModel> landList;
  final int landCurrentPage;
  final int landTotalNumberOfRecord;
  const ProjectLeadState({
    super.isLoading,
    required this.redevelopmentList,
    required this.redevelopmentCurrentPage,
    required this.redevelopmentTotalNumberOfRecord,
    required this.redevelopmentSearchText,
    required this.landList,
    required this.landCurrentPage,
    required this.landTotalNumberOfRecord,
  });
  factory ProjectLeadState.initial() => ProjectLeadState(
    isLoading: false,
    redevelopmentList: [],
    redevelopmentCurrentPage: 1,
    redevelopmentTotalNumberOfRecord: 0,
    redevelopmentSearchText: '',
    landList: [],
    landCurrentPage: 1,
    landTotalNumberOfRecord: 0,
  );
  ProjectLeadState copyWith({
    bool? isLoading,
    List<RedevelopmentModel>? redevelopmentList,
    int? redevelopmentCurrentPage,
    int? redevelopmentTotalNumberOfRecord,
    String? redevelopmentSearchText,
    List<LandModel>? landList,
    int? landCurrentPage,
    int? landTotalNumberOfRecord,
  }) {
    return ProjectLeadState(
      isLoading: isLoading ?? this.isLoading,
      redevelopmentList: redevelopmentList ?? this.redevelopmentList,
      redevelopmentCurrentPage:
          redevelopmentCurrentPage ?? this.redevelopmentCurrentPage,
      redevelopmentTotalNumberOfRecord:
          redevelopmentTotalNumberOfRecord ??
          this.redevelopmentTotalNumberOfRecord,
      redevelopmentSearchText:
          redevelopmentSearchText ?? this.redevelopmentSearchText,
      landList: landList ?? this.landList,
      landCurrentPage: landCurrentPage ?? this.landCurrentPage,
      landTotalNumberOfRecord:
          landTotalNumberOfRecord ?? this.landTotalNumberOfRecord,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    redevelopmentList,
    redevelopmentCurrentPage,
    redevelopmentTotalNumberOfRecord,
    redevelopmentSearchText,
    landList,
    landCurrentPage,
    landTotalNumberOfRecord,
  ];
}
