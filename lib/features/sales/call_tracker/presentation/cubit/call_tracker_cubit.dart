import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/calling_data.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/repository/call_tracker.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'call_tracker_state.dart';

class CallTrackerCubit extends Cubit<CallTrackerState> {
  CallTrackerCubit() : super(CallTrackerState.initial());

  // REPOSITORIES
  final CallTrackerRepository _callTrackerRepository =
      serviceLocator<CallTrackerRepository>();

  // HELPER ON TAB CHANGED
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index, searchText: ""));
  }

  // SEARCH CALLING DATA
  Future<void> searchCallingData(
    BuildContext context,
    String searchText,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: searchText, callingDataList: []));
    await getCallingDataList(context, 1, projectId);
  }

  Future<void> searchCallingLog(
    BuildContext context,
    String searchText,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: searchText, callLogList: []));
    await getCallLogList(context, 1, projectId);
  }

  // <---- GET CALLING DATA LIST ---->
  Future getCallingDataList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    var queryParams = {"Name": state.searchText};

    emit(state.copyWith(isLoading: true));
    var result = await _callTrackerRepository.getCallingData(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CallingDataModel> newData = List<CallingDataModel>.from(
          response['data'] ?? [],
        );

        final List<CallingDataModel> updatedList =
            pageNumber == 1 ? newData : [...state.callingDataList, ...newData];
        emit(
          state.copyWith(
            callingDataList: updatedList,
            isLoading: false,
            totalNumberOfRecordCallingData: response["totalNumberOfRecord"],
            currentPageCallingData: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET CALLING DATA LIST ---->
  Future getCallLogList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    var queryParams = {"Name": state.searchText};
    emit(state.copyWith(isLoading: true));
    var result = await _callTrackerRepository.getCallLog(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CallLogModel> newData = List<CallLogModel>.from(
          response['data'] ?? [],
        );

        final List<CallLogModel> updatedList =
            pageNumber == 1 ? newData : [...state.callLogList, ...newData];
        emit(
          state.copyWith(
            callLogList: updatedList,
            isLoading: false,
            totalNumberOfRecordCallLog: response["totalNumberOfRecord"],
            currentPageCallLog: pageNumber,
          ),
        );
      },
    );
  }
}
