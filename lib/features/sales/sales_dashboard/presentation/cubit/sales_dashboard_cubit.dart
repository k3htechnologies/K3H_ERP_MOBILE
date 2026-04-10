import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/repository/sales.dashboard.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'sales_dashboard_state.dart';

class SalesDashboardCubit extends Cubit<SalesDashboardState> {
  SalesDashboardCubit() : super(SalesDashboardState.initial());

  // REPOSITORY
  final SalesDashboardRepository _salesDashboardRepository =
      serviceLocator<SalesDashboardRepository>();

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  // <---- GET Dashboard LIST ---->
  Future getSalesDashboardList(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true));

    var result = await _salesDashboardRepository.getSalesDashboardList(
      projectId: projectId,
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
            salesData: model,
            salesDashboardList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }

  // <---- MARK TIME OUT ENQUIRY ---->
  Future markTimeOutEnquiry({
    required BuildContext context,
    required int enquiryId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "EnquiryId": enquiryId,
      "ProjectId": projectId,
    };
    var addResult = await _salesDashboardRepository.markTimeOutEnquiry(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);
        getSalesDashboardList(context, projectId);
      },
    );
  }
}
