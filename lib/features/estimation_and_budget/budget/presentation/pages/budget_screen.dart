import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_cubit.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BudgetMasterScreen extends StatefulWidget {
  const BudgetMasterScreen({super.key});

  @override
  State<BudgetMasterScreen> createState() => _BudgetMasterScreenState();
}

class _BudgetMasterScreenState extends State<BudgetMasterScreen> {
  // CUBIT
  late BudgetCubit _budgetCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  late ProjectModel _selectedProject;

  @override
  void initState() {
    super.initState();
    _budgetCubit = context.read<BudgetCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.budget]!;
    _initializeTextEditingController();
    _onScroll();
    _selectedProject = getProject();
    _budgetCubit.getBudgetList(
      context,
      1,
      projectId: _selectedProject.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_budgetCubit.state.isLoading! &&
          _budgetCubit.state.budgetList.length <
              _budgetCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _budgetCubit.getBudgetList(
            context,
            _budgetCubit.state.currentPage + 1,
            projectId: _selectedProject.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Budget Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _budgetCubit.exportExcelPdf(context, value);
        },
        searchHintText: "Search by Budget Name",
        onSearchSubmit: (value) {
          _budgetCubit.searchBudget(context, value, _selectedProject.projectId);
        },
        onProjectChangeCallback: (project) {
          _selectedProject = project;
          _budgetCubit.searchBudget(context, "", _selectedProject.projectId);
          _searchC.clear();
        },
        textController: _searchC,
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if ((state.isLoading ?? false) && state.budgetList.isEmpty) {
            return Center(child: loader());
          } else if (state.budgetList.isEmpty) {
            return Center(child: noDataWidget(message: "No Budget Data Found"));
          } else {
            return ListView.separated(
              controller: scrollController,
              itemCount: state.budgetList.length + 1,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              separatorBuilder: (context, index) => verticalSpacing(),
              itemBuilder: (context, index) {
                if (index == state.budgetList.length) {
                  return state.budgetList.length < state.totalNumberOfRecord
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                final budget = state.budgetList[index];
                return estimatedWorkCard(budget);
              },
            );
          }
        },
      ),
    );
  }

  Widget estimatedWorkCard(BudgetModel budget) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8FF),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFD0D5E2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.r),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Text(
                  'WBS: 1',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          buildRowTitleValue(
            title: "Total Amount",
            value: budget.totalRate.toIndianCurrency(),
          ),
          buildRowTitleValue(
            title: "Budget Amount",
            value: budget.budgetAmount.toIndianCurrency(),
          ),

          SizedBox(height: 8.h),

          Divider(height: 1, thickness: 1, color: const Color(0xFFE5E7EB)),

          SizedBox(height: 7.h),

          Row(
            children: [
              Text(
                'L1 : 12',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF4B5563),
                ),
              ),
              SizedBox(width: 18.w),
              Text(
                'L2 : 12',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  // View details
                },
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF135BEC),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
