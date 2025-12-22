part of 'designation_master_cubit.dart';

class DesignationMasterState extends BaseState {
  final List<DesignationMasterModel> designationList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final List<ModuleModel> modulesPermissionsList;
  final bool isAllSelected;
  final int updateCounter; // Add counter to force state changes

  const DesignationMasterState({
    super.isLoading,
    super.stateType,
    required this.designationList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.modulesPermissionsList,
    this.isAllSelected = false,
    this.updateCounter = 0,
  });

  factory DesignationMasterState.initial() => DesignationMasterState(
    designationList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
    modulesPermissionsList: [],
    updateCounter: 0,
  );

  DesignationMasterState copyWith({
    String? errorMessage,
    bool? isLoading,
    List<DesignationMasterModel>? designationList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    StateType? stateType,
    List<ModuleModel>? modulesPermissionsList,
    bool? isAllSelected,
    int? updateCounter,
  }) {
    return DesignationMasterState(
      isLoading: isLoading ?? this.isLoading,
      designationList: designationList ?? this.designationList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      modulesPermissionsList:
      modulesPermissionsList ?? this.modulesPermissionsList,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      stateType: stateType ?? this.stateType,
      updateCounter: updateCounter ?? this.updateCounter,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    designationList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    stateType,
    isAllSelected,
    modulesPermissionsList,
    updateCounter,
  ];
}
