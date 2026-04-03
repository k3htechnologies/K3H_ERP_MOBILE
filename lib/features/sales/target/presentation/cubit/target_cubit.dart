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

  // SET MONTH FILTER
  void setMonthFilter(String? month) {
    emit(state.copyWith(selectedMonth: month));
  }

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
        sourcingPage: 1,
        closingPage: 1,
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

  // ON TAB CHANGE
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        salesTargetClosing: [],
        salesTargetSourcing: [],
        searchText: "",
        closingTotalNumberOfRecordSalesTarget: 1,
        sourcingTotalNumberOfRecordSalesTarget: 1,
        sourcingPage: 1,
        closingPage: 1,
        selectedMonth: null,
      ),
    );
  }

  // <---- GET SOURCING TARGET LIST ---->
  Future getSalesTargetSourcingList({
    required BuildContext context,
    required int projectId,
    int pageNumber = 1,
  }) async {
    emit(state.copyWith(isSourcingLoading: true));

    Map<String, dynamic> queryParams = {};

    if (state.searchText.trim().isNotEmpty) {
      queryParams["EmployeeName"] = state.searchText.trim();
    }

    if (state.selectedMonth != null) {
      queryParams["MonthYear"] = state.selectedMonth;
    }

    var result = await _salesTargetRepository.getSalesTargetSourcing(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isSourcingLoading: false));
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
            isSourcingLoading: false,
            salesTargetSourcing: updatedList,
            sourcingTotalNumberOfRecordSalesTarget:
                response['totalNumberOfRecord'] ?? 0,
            sourcingPage: pageNumber,
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
  }) async {
    emit(state.copyWith(isClosingLoading: true));

    Map<String, dynamic> queryParams = {};

    if (state.searchText.trim().isNotEmpty) {
      queryParams["EmployeeName"] = state.searchText.trim();
    }

    if (state.selectedMonth != null) {
      queryParams["MonthYear"] = state.selectedMonth;
    }

    var result = await _salesTargetRepository.getSalesTargetClosing(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isClosingLoading: false));
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
            isClosingLoading: false,
            salesTargetClosing: updatedList,
            closingTotalNumberOfRecordSalesTarget:
                response['totalNumberOfRecord'] ?? 0,
            closingPage: pageNumber,
          ),
        );
      },
    );
  }
}
