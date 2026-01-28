import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';

class ResignationState extends BaseState {
  final List<ResignationModel> resignationList;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final int currentPage;

  const ResignationState({
    super.isLoading,
    required this.resignationList,
    required this.totalNumberOfRecord,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.currentPage,
  });

  factory ResignationState.initial() => ResignationState(
    resignationList: [],
    totalNumberOfRecord: 0,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    isLoading: true,
    currentPage: 1,
  );

  ResignationState copyWith({
    bool? isLoading,
    List<ResignationModel>? resignationList,
    int? totalNumberOfRecord,
    String? currentSortColumn,
    String? currentSortDirection,
    int? currentPage,
  }) {
    return ResignationState(
      isLoading: isLoading ?? this.isLoading,
      resignationList: resignationList ?? this.resignationList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    resignationList,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    currentPage,
  ];
}
