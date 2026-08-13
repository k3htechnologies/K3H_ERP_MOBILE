part of 'dcr_cubit.dart';

class DcrState extends BaseState {
  final List<DcrModel> dcrReportList;
  final DcrModel? dcrModel;
  final String selectedFilterType;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  const DcrState({
    super.isLoading,
    required this.dcrReportList,
    this.dcrModel,
    required this.selectedFilterType,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory DcrState.initial() => DcrState(
    isLoading: true,
    dcrReportList: [],
    selectedFilterType: '',
    totalNumberOfRecord: 0,
    currentPage: 0,
    searchText: '',
  );

  DcrState copyWith({
    bool? isLoading,
    List<DcrModel>? dcrReportList,
    String? selectedFilterType,
    DcrModel? dcrModel,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return DcrState(
      isLoading: isLoading ?? this.isLoading,
      dcrReportList: dcrReportList ?? this.dcrReportList,
      dcrModel: dcrModel ?? this.dcrModel,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dcrReportList,
    dcrModel,
    selectedFilterType,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}
