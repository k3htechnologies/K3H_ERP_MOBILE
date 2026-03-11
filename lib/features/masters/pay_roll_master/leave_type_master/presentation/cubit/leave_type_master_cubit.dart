import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class LeaveTypeMasterCubit extends Cubit<LeaveTypeMasterState> {
  LeaveTypeMasterCubit() : super(LeaveTypeMasterState.initial());
  final LeaveTypeMasterRepository leaveTypeMasterRepository =
      serviceLocator<LeaveTypeMasterRepository>();

  // GET LEAVE TYPE
  Future getLeaveTypeList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "LeaveType": state.searchText.trim(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await leaveTypeMasterRepository.getLeaveTypeList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LeaveTypeModel> newData = List<LeaveTypeModel>.from(
          response['data'] ?? [],
        );

        final List<LeaveTypeModel> updatedList =
            pageNumber == 1 ? newData : [...state.leaveTypeList, ...newData];
        emit(
          state.copyWith(
            leaveTypeList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // DELETE LEAVE TYPE
  Future deleteLeaveType(
    int index,
    LeaveTypeModel leaveTypeModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await leaveTypeMasterRepository.deleteLeaveType(
      leaveTypeId: leaveTypeModel.leaveTypeMasterId,
      uniqueKey: leaveTypeModel.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<LeaveTypeModel>.from(state.leaveTypeList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            leaveTypeList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Leave Type Deleted Successfully",
        );
      },
    );
  }

  // ADD LEAVE TYPE
  Future addLeaveType({
    required BuildContext context,
    required String leaveType,
    required String leaveTypeCode,
    required bool isCarryForward,
    required int maxCarryForward,
    required bool isEncashable,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "LeaveTypeMasterId": 0,
      "LeaveType": leaveType,
      "LeaveTypeCode": leaveTypeCode,
      "IsCarryForward": isCarryForward,
      "MaxCarryForward": maxCarryForward,
      "IsEncashable": isEncashable,
    };
    var result = await leaveTypeMasterRepository.addUpdateLeaveType(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = LeaveTypeModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.leaveTypeList];
        emit(
          state.copyWith(
            isLoading: false,
            leaveTypeList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(context, subTitle: 'Leave Type Added Successfully');
      },
    );
  }

  // UPDATE LEAVE TYPE
  Future updateLeaveType({
    required int index,
    required BuildContext context,
    required int leaveTypeId,
    required String uniqueKey,
    required String leaveType,
    required String leaveTypeCode,
    required bool isCarryForward,
    required int maxCarryForward,
    required bool isEncashable,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "LeaveTypeMasterId": leaveTypeId,
      "Uniquekey": uniqueKey,
      "LeaveType": leaveType,
      "LeaveTypeCode": leaveTypeCode,
      "IsCarryForward": isCarryForward,
      "MaxCarryForward": maxCarryForward,
      "IsEncashable": isEncashable,
    };
    var result = await leaveTypeMasterRepository.addUpdateLeaveType(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedList = LeaveTypeModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.leaveTypeList.isNotEmpty &&
            index < state.leaveTypeList.length) {
          final updatedListModel = List<LeaveTypeModel>.from(
            state.leaveTypeList,
          );
          updatedListModel[index] = updatedList;
          emit(
            state.copyWith(
              isLoading: false,
              leaveTypeList: updatedListModel,
              currentPage: state.currentPage,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Leave Type Updated Successfully',
        );
      },
    );
  }

  // EXPORT LEAVE TYPE
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await leaveTypeMasterRepository.getLeaveTypeForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "ExportType": exportType,
        "LeaveType": state.searchText.trim(),
      },
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "leave_type_${DateTime.now()}.pdf"
              : "leave_type_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // SEARCH BASED ON LEAVE TYPE
  Future<void> searchLeaveType(String value, BuildContext context) async {
    emit(
      state.copyWith(
        leaveTypeList: [],
        searchText: value,
      ),
    );
    await getLeaveTypeList(context: context, pageNumber: 1);
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        leaveTypeList: [],
        currentPage: 1,
      ),
    );

    await getLeaveTypeList(context: context, pageNumber: 1);
  }
}
