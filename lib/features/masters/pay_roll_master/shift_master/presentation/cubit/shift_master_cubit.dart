import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/repository/shift_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ShiftMasterCubit extends Cubit<ShiftMasterState> {
  ShiftMasterCubit() : super(ShiftMasterState.initial());
  final ShiftMasterRepository shiftMasterRepository =
      serviceLocator<ShiftMasterRepository>();

  // GET SHIFT
  Future getShiftList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "ShiftName": state.searchText.trim(),
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await shiftMasterRepository.getShiftList(
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
        final List<ShiftMasterModel> newData = List<ShiftMasterModel>.from(
          response['data'] ?? [],
        );

        final List<ShiftMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.shiftMasterList, ...newData];
        emit(
          state.copyWith(
            shiftMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // DELETE SHIFT
  Future deleteShift(
    int index,
    ShiftMasterModel shiftMasterModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await shiftMasterRepository.deleteShift(
      shiftId: shiftMasterModel.shiftManagementMasterId,
      uniqueKey: shiftMasterModel.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<ShiftMasterModel>.from(state.shiftMasterList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            shiftMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: "Shift Deleted Successfully");
      },
    );
  }

  // ADD SHIFT
  Future addShift({
    required BuildContext context,

    required String shiftCode,
    required String shiftName,
    required String shiftBeginTime,
    required String shiftEndTime,
    required String shiftDurationTime,
    required String shiftWorkDurationTime,
    required String firstHalfUpTo,
    String? absentWorkingHours,
    String? halfDayWorkingHours,
    String? halfDayInTimeAfter,
    String? halfDayOutTimeBefore,
    required String breakBeginTime,
    required String breakEndTime,
    required String breakDurationTime,
    required String graceTime,
    String? lateArrivalAction,
    required double lateCount,
    required String remarks,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ShiftManagementMasterId": 0,
      "ShiftCode": shiftCode,
      "ShiftName": shiftName,
      "ShiftBeginTime": shiftBeginTime,
      "ShiftEndTime": shiftEndTime,
      "ShiftDurationTime": shiftDurationTime,
      "ShiftWorkDurationTime": shiftWorkDurationTime,
      "FirstHalfUpTo": firstHalfUpTo,
      "AbsentWorkingHours": absentWorkingHours,
      "HalfDayWorkingHours": halfDayWorkingHours,
      "HalfDayInTimeAfter": halfDayInTimeAfter,
      "HalfDayOutTimeBefore": halfDayOutTimeBefore,
      "BreakBeginTime": breakBeginTime,
      "BreakEndTime": breakEndTime,
      "BreakDurationTime": breakDurationTime,
      "GraceTime": graceTime,
      "LateArrivalAction": lateArrivalAction,
      "LateCount": lateCount,
      "Remarks": remarks,
    };
    print("the payload is : $body");
    var result = await shiftMasterRepository.addUpdateShift(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = ShiftMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.shiftMasterList];
        emit(
          state.copyWith(
            isLoading: false,
            shiftMasterList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(context, subTitle: 'Shift Added Successfully');
      },
    );
  }

  // UPDATE SHIFT
  Future updateShift({
    required int index,
    required BuildContext context,
    required int shiftId,
    required String uniqueKey,
    required String shiftCode,
    required String shiftName,
    required String shiftBeginTime,
    required String shiftEndTime,
    required String shiftDurationTime,
    required String shiftWorkDurationTime,
    required String firstHalfUpTo,
    String? absentWorkingHours,
    String? halfDayWorkingHours,
    String? halfDayInTimeAfter,
    String? halfDayOutTimeBefore,
    required String breakBeginTime,
    required String breakEndTime,
    required String breakDurationTime,
    required String graceTime,
    String? lateArrivalAction,
    required double lateCount,
    required String remarks,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ShiftManagementMasterId": shiftId,
      "Uniquekey": uniqueKey,
      "ShiftCode": shiftCode,
      "ShiftName": shiftName,
      "ShiftBeginTime": shiftBeginTime,
      "ShiftEndTime": shiftEndTime,
      "ShiftDurationTime": shiftDurationTime,
      "ShiftWorkDurationTime": shiftWorkDurationTime,
      "FirstHalfUpTo": firstHalfUpTo,
      "AbsentWorkingHours": absentWorkingHours,
      "HalfDayWorkingHours": halfDayWorkingHours,
      "HalfDayInTimeAfter": halfDayInTimeAfter,
      "HalfDayOutTimeBefore": halfDayOutTimeBefore,
      "BreakBeginTime": breakBeginTime,
      "BreakEndTime": breakEndTime,
      "BreakDurationTime": breakDurationTime,
      "GraceTime": graceTime,
      "LateArrivalAction": lateArrivalAction,
      "LateCount": lateCount,
      "Remarks": remarks,
    };
    print("the payload for update is :$body");
    var result = await shiftMasterRepository.addUpdateShift(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = ShiftMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.shiftMasterList.isNotEmpty &&
            index < state.shiftMasterList.length) {
          final updatedListModel = List<ShiftMasterModel>.from(
            state.shiftMasterList,
          );
          updatedListModel[index] = updatedList;
          emit(
            state.copyWith(isLoading: false, shiftMasterList: updatedListModel),
          );
        }

        showSuccessMessage(context, subTitle: 'Shift Updated Successfully');
      },
    );
  }

  // EXPORT SHIFT
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await shiftMasterRepository.getShiftForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType, "shift": state.searchText.trim()},
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
              ? "shift_${DateTime.now()}.pdf"
              : "shift_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // SEARCH BASED ON SHIFT
  void searchShift(String value, BuildContext context) {
    emit(
      state.copyWith(
        shiftMasterList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getShiftList(context: context, pageNumber: 1);
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
        shiftMasterList: [],
        currentPage: 1,
      ),
    );

    await getShiftList(context: context, pageNumber: 1);
  }
}
