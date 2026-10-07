import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';

class BudgetState extends BaseState {
  final List<BudgetModel> budgetList;
  final List<BudgetModel> originalBudgetList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  final String filterByLevelType;
  final String filterByUom;
  final String filterByFlatType;

  const BudgetState({
    super.isLoading,
    required this.budgetList,
    required this.originalBudgetList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.filterByLevelType,
    required this.filterByUom,
    required this.filterByFlatType,
  });

  factory BudgetState.initial() => BudgetState(
    budgetList: [],
    originalBudgetList:[],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    filterByLevelType: "",
    filterByUom: "",
    filterByFlatType: "",
    isLoading: true,
  );

  BudgetState copyWith({
    bool? isLoading,
    List<BudgetModel>? budgetList,
    List<BudgetModel>? originalBudgetList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? filterByLevelType,
    String? filterByCategoryName,
    String? filterByUom,
    String? filterByFlatLevelType,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budgetList: budgetList ?? this.budgetList,
      originalBudgetList: originalBudgetList ?? this.originalBudgetList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterByLevelType: filterByLevelType ?? this.filterByLevelType,
      filterByUom: filterByUom ?? this.filterByUom,
      filterByFlatType:
          filterByFlatLevelType ?? this.filterByFlatType,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    budgetList,
    originalBudgetList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByLevelType,
    filterByUom,
    filterByFlatType,
  ];
}
