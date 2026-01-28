part of 'comp_off_cubit.dart';

class CompOffState extends BaseState {
  final List<CompOffModel> compOffList;
  final int totalNumberOfRecord;
  final int currentPage;
  final int currentTabIndex;

  const CompOffState({
    super.isLoading,
    required this.compOffList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.currentTabIndex,
  });

  factory CompOffState.initial() => CompOffState(
    compOffList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    isLoading: true,
    currentTabIndex: 0,
  );

  CompOffState copyWith({
    bool? isLoading,
    List<CompOffModel>? compOffList,
    int? totalNumberOfRecord,
    int? currentPage,
    int? currentTabIndex,
  }) {
    return CompOffState(
      isLoading: isLoading ?? this.isLoading,
      compOffList: compOffList ?? this.compOffList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    compOffList,
    totalNumberOfRecord,
    currentPage,
    currentTabIndex,
  ];
}
