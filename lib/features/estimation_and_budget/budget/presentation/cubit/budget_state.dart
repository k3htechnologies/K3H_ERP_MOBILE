import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';

class BudgetState extends BaseState {
  final List<BudgetModel> budgetList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  const BudgetState({
    super.isLoading,
    required this.budgetList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory BudgetState.initial() => BudgetState(
    budgetList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    isLoading: true,
  );

  BudgetState copyWith({
    bool? isLoading,
    List<BudgetModel>? budgetList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budgetList: budgetList ?? this.budgetList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    budgetList,
    totalNumberOfRecord,
    currentPage,
    searchText,
  ];
}
