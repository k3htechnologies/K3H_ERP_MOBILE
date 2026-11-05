import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_timeline.model.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/repository/visitor_management_dashboard.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
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

  void _applyApprovalLocally({
    required int externalId,
    required String approvalStatus,
    required String approvalRemark,
  }) {
    if (state.gatePassDashboardList.isEmpty) return;

    final current = state.gatePassDashboardList.first;
    final isApproved = approvalStatus.toLowerCase() == 'approved';

    // Table1: the visitor card
    final newTable1 =
        current.table1.map((v) {
          if (v.externalId != externalId) return v;
          return v.copyWith(
            status: approvalStatus,
            approvalRemark: approvalRemark,
            isApproval: false, // approval buttons get disabled
            isCheckOutEnabled:
                isApproved, // matches the server response in your logs
          );
        }).toList();

    // Table2: the timeline entry
    final newTable2 =
        current.table2.map((v) {
          return v.externalId == externalId
              ? v.copyWith(status: approvalStatus)
              : v;
        }).toList();

    // Table0: Pending Approvals count
    final newTable0 =
        current.table0.map((c) {
          return c.copyWith(
            pendingApprovals: (c.pendingApprovals - 1).clamp(
              0,
              c.pendingApprovals,
            ),
          );
        }).toList();

    emit(
      state.copyWith(
        gatePassDashboardList: [
          current.copyWith(
            table0: newTable0,
            table1: newTable1,
            table2: newTable2,
          ),
        ],
      ),
    );
  }

  Future addApproval({
    required BuildContext context,
    required int externalId,
    required String uniquekey,
    required String type,
    required String approvalRemark,
    required String approvalStatus,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ExternalId": externalId,
      "Uniquekey": uniquekey,
      "ApprovalRemark": approvalRemark,
      "ApprovalStatus": approvalStatus,
    };
    var addResult = await _visitorManagementDashboardRepository.addApproval(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response["message"]);
        _applyApprovalLocally(
          externalId: externalId,
          approvalStatus: approvalStatus,
          approvalRemark: approvalRemark,
        );
      },
    );
  }

  Future<void> updateGatePassOut(
    BuildContext context, {
    required int externalId,
    required String type,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, dynamic> body = {
      "ExternalId": externalId,
      "Type": "Out",
      "Uniquekey": uniquekey,
    };

    final result = await _visitorManagementDashboardRepository
        .updateGatePassOut(body: body);

    if (context.mounted) {
      goRouter.pop();
    }

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
        await getGatePassDashboard(context: context, filterType: type);

        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }
}
