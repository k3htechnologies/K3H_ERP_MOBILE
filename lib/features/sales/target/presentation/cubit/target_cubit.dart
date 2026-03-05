import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_closing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/repository/target.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
part 'target_state.dart';

class TargetCubit extends Cubit<TargetState> {
  TargetCubit() : super(TargetState.initial());

  final TargetRepository _salesTargetRepository =
      serviceLocator<TargetRepository>();

  // <---- SEARCH SALES TARGET ---->
  Future<void> searchSalesTarget(
    BuildContext context,
    int projectId,
    int tabIndex,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchText: value.trim(),
        salesTargetClosing: [],
        salesTargetSourcing: [],
        currentPage: 1,
      ),
    );

    if (tabIndex == 0) {
      await getSalesTargetSourcingList(
        context: context,
        projectId: projectId,
        pageNumber: 1,
      );
    } else {
      await getSalesTargetClosingList(
        context: context,
        projectId: projectId,
        pageNumber: 1,
      );
    }
  }

  // <---- CLEAR FILTER ON SALES TARGET ---->
  void clearFilterOnSalesTarget(
    BuildContext context,
    int projectId,
    int tabIndex,
  ) {
    emit(
      state.copyWith(
        clearFilters: true,
        salesTargetClosing: [],
        salesTargetSourcing: [],
        filterStartDate: null,
        filterEndDate: null,
      ),
    );
    if (tabIndex == 0) {
      getSalesTargetSourcingList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
      );
    } else {
      getSalesTargetClosingList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
      );
    }
  }

  // <---- APPLY FILTER ON SALES TARGET ---->
  void applyFilterOnSalesTarget({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    required int projectId,
    required int tabIndex,
  }) {
    emit(
      state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
        salesTargetClosing: [],
        salesTargetSourcing: [],
      ),
    );
    if (tabIndex == 0) {
      getSalesTargetSourcingList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
      );
    } else {
      getSalesTargetClosingList(
        context: context,
        pageNumber: 1,
        projectId: projectId,
      );
    }
  }

  // ON TAB CHANGE
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        isLoading: true,
        filterStartDate: null,
        filterEndDate: null,
        salesTargetClosing: [],
        salesTargetSourcing: [],
        closingTotalNumberOfRecordSalesTarget: 1,
        sourcingTotalNumberOfRecordSalesTarget: 1,
        currentPage: 1,
      ),
    );
  }

  // <---- GET SOURCING TARGET LIST ---->
  Future getSalesTargetSourcingList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> searchQueryParams = queryParams ?? {};

    if (searchQueryParams.isEmpty) {
      if (state.filterStartDate != null) {
        searchQueryParams["FromDate"] = DateFormat(
          'yyyy-MM-dd',
        ).format(state.filterStartDate!);
      }

      if (state.filterEndDate != null) {
        searchQueryParams["ToDate"] = DateFormat(
          'yyyy-MM-dd',
        ).format(state.filterEndDate!);
      }
      if (state.searchText.trim().isNotEmpty) {
        searchQueryParams["EmployeeName"] = state.searchText.trim();
      }
    }
    var result = await _salesTargetRepository.getSalesTargetSourcing(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: searchQueryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SalesTargetSourcingModel> newData =
            List<SalesTargetSourcingModel>.from(response['data'] ?? []);

        final List<SalesTargetSourcingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.salesTargetSourcing, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            salesTargetSourcing: updatedList,
            sourcingTotalNumberOfRecordSalesTarget:
                response['totalNumberOfRecord'] == 0 &&
                        state.sourcingTotalNumberOfRecordSalesTarget != 1
                    ? state.sourcingTotalNumberOfRecordSalesTarget - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET CLOSING TARGET LIST ---->
  Future getSalesTargetClosingList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> searchQueryParams = queryParams ?? {};

    if (searchQueryParams.isEmpty) {
      if (state.filterStartDate != null) {
        searchQueryParams["FromDate"] = DateFormat(
          'yyyy-MM-dd',
        ).format(state.filterStartDate!);
      }

      if (state.filterEndDate != null) {
        searchQueryParams["ToDate"] = DateFormat(
          'yyyy-MM-dd',
        ).format(state.filterEndDate!);
      }

      if (state.searchText.trim().isNotEmpty) {
        searchQueryParams["EmployeeName"] = state.searchText.trim();
      }
    }
    var result = await _salesTargetRepository.getSalesTargetClosing(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: searchQueryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SaleTargetClosingModel> newData =
            List<SaleTargetClosingModel>.from(response['data'] ?? []);

        final List<SaleTargetClosingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.salesTargetClosing, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            salesTargetClosing: updatedList,
            closingTotalNumberOfRecordSalesTarget:
                response['totalNumberOfRecord'] == 0 &&
                        state.closingTotalNumberOfRecordSalesTarget != 1
                    ? state.closingTotalNumberOfRecordSalesTarget - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
