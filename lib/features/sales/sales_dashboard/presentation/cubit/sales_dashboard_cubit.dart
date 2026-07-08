import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/project_wise_sales.dashboard.model.dart'
    hide Table0;
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/repository/sales.dashboard.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'sales_dashboard_state.dart';

class SalesDashboardCubit extends Cubit<SalesDashboardState> {
  SalesDashboardCubit() : super(SalesDashboardState.initial());

  // REPOSITORY
  final SalesDashboardRepository _salesDashboardRepository =
      serviceLocator<SalesDashboardRepository>();

  Future clearSalesDashboardData() async {
    emit(
      state.copyWith(salesDashboardList: [], projectWiseSalesDashboardList: []),
    );
  }

  // GET Dashboard LIST
  Future getSalesDashboardList({
    required BuildContext context,
    required int projectId,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _salesDashboardRepository.getSalesDashboardList(
      projectId: projectId,
      queryParams: {
        "FilterType": filterType.toUpperCase(),
        "FromDate": fromDate?.apiDate,
        "ToDate": toDate?.apiDate,
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final SalesDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            salesDashboardList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }

  // MARK TIME OUT ENQUIRY
  Future<void> markTimeOutEnquiry({
    required BuildContext context,
    required int enquiryId,
    required int projectId,
    DateTime? toDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final requestBody = {"EnquiryId": enquiryId, "ProjectId": projectId};

    final addResult = await _salesDashboardRepository.markTimeOutEnquiry(
      body: requestBody,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        debugPrint("API Failed: ${failure.message}");
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dashboard = state.salesDashboardList.first;

        final updatedTable0 = List<Table0>.from(dashboard.table0)
          ..removeWhere((e) => e.enquiryId == enquiryId);

        final updatedDashboard = dashboard.copyWith(table0: updatedTable0);

        final updatedSalesDashboardList = [updatedDashboard];

        emit(state.copyWith(salesDashboardList: updatedSalesDashboardList));

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future<void> getProjectWiseSalesDashboard({
    required BuildContext context,
    required int projectId,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await _salesDashboardRepository.getProjectWiseSalesDashboard(
      projectId: projectId,
      queryParams: {
        "FilterType": filterType.toUpperCase(),
        "FromDate": fromDate?.apiDate,
        "ToDate": toDate?.apiDate,
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final ProjectWiseSalesDashboardModel? model = response['data'];

        emit(
          state.copyWith(
            projectWiseSalesDashboardList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }
}
