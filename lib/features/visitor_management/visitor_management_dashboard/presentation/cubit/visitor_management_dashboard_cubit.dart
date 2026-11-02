import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_timeline.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/repository/visitor_management_dashboard.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'visitor_management_dashboard_state.dart';

class VisitorManagementDashboardCubit
    extends Cubit<VisitorManagementDashboardState> {
  VisitorManagementDashboardCubit()
    : super(VisitorManagementDashboardState.initial());

  // REPOSITORY
  final VisitorManagementDashboardRepository
  _visitorManagementDashboardRepository =
      serviceLocator<VisitorManagementDashboardRepository>();

  Future clearGatePassDashboarddData() async {
    emit(state.copyWith(gatePassDashboardList: []));
  }

  Future<void> getGatePassDashboard({
    required BuildContext context,
    required String filterType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "FromDate": fromDate?.apiDate,
      "ToDate": toDate?.apiDate,
    };

    final result = await _visitorManagementDashboardRepository
        .getGatePassDashboard(
          filterType: filterType.toUpperCase(),
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        // final List<GatePassDashboardModel> newData =
        //     List<GatePassDashboardModel>.from(response['data'] ?? []);
        final GatePassDashboardModel? model = response['data'];
        emit(
          state.copyWith(
            gatePassDashboardList: model != null ? [model] : [],
            isLoading: false,
          ),
        );
      },
    );
  }

  List<TimelineGroup> buildTimelineGroups(List<Table2> table2) {
    final visitors =
        table2
            .map(
              (e) => Table2(
                externalId: e.externalId,
                visitorName: e.visitorName,
                noOfParticipants: e.noOfParticipants,
                visitTime: e.visitTime,
                outDateTime: e.outDateTime,
                purpose: e.purpose,
                status: e.status,
              ),
            )
            .toList()
          ..sort((a, b) => a.visitTime.compareTo(b.visitTime));

    final grouped = groupBy(visitors, (Table2 v) => formatDate(v.visitTime));

    return grouped.values
        .map((list) => TimelineGroup(list.first.visitTime, list))
        .toList();
  }
}
