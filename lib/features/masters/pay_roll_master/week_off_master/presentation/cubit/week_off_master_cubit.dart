import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/repository/week_off_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/presentation/cubit/week_off_master_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class WeekOffMasterCubit extends Cubit<WeekOffMasterState> {
  WeekOffMasterCubit() : super(WeekOffMasterState.initial());
  final WeekOffMasterRepository weekOffMasterRepository =
      serviceLocator<WeekOffMasterRepository>();

  // GET WEEK OFF
  Future getWeekOffList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {"WeekOffPolicyName": state.searchText.trim()};
    var result = await weekOffMasterRepository.getWeekOffList(
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
        final List<WeekOffMasterModel> newData = List<WeekOffMasterModel>.from(
          response['data'] ?? [],
        );

        final List<WeekOffMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.weekOffMasterList, ...newData];
        emit(
          state.copyWith(
            weekOffMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // DELETE WEEK OFF
  Future deleteWeekOff(
    int index,
    WeekOffMasterModel weekOffMasterModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await weekOffMasterRepository.deleteWeekOff(
      weekOffId: weekOffMasterModel.weekOffPolicyMasterId,
      uniqueKey: weekOffMasterModel.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        showSuccessMessage(context, subTitle: "WEEK OFF Deleted Successfully");
        getWeekOffList(context: context, pageNumber: state.currentPage);
      },
    );
  }

  // ADD WEEK OFF
  Future addWeekOff({
    required BuildContext context,
    required String weekOffPolicyCode,
    required String weekOffPolicyName,
    required int weekDays,
    required String weekDaysStartsOn,
    required String weeklyOff,
    required String weeklyOff2,
    required String weeklyOff2Type,
    required String notApplicableForMonths,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "WeekOffPolicyMasterId": 0,
      "WeekOffPolicyCode": weekOffPolicyCode,
      "WeekOffPolicyName": weekOffPolicyName,
      "WeekDays": weekDays,
      "WeekDaysStartsOn": weekDaysStartsOn,
      "WeeklyOff": weeklyOff,
      "WeeklyOff2": weeklyOff2,
      "WeeklyOff2Type": weeklyOff2Type,
      "NotApplicableForMonths": notApplicableForMonths,
    };
    var result = await weekOffMasterRepository.addUpdateWeekOff(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = WeekOffMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.weekOffMasterList];
        emit(
          state.copyWith(
            isLoading: false,
            weekOffMasterList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(context, subTitle: 'WEEK OFF Added Successfully');
      },
    );
  }

  // UPDATE WEEK OFF
  Future updateWeekOff({
    required int index,
    required BuildContext context,
    required int weekOffPolicyMasterId,
    required String uniqueKey,
    required String weekOffPolicyCode,
    required String weekOffPolicyName,
    required int weekDays,
    required String weekDaysStartsOn,
    required String weeklyOff,
    required String weeklyOff2,
    required String weeklyOff2Type,
    required String notApplicableForMonths,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "WeekOffPolicyMasterId": weekOffPolicyMasterId,
      "Uniquekey": uniqueKey,
      "WeekOffPolicyCode": weekOffPolicyCode,
      "WeekOffPolicyName": weekOffPolicyName,
      "WeekDays": weekDays,
      "WeekDaysStartsOn": weekDaysStartsOn,
      "WeeklyOff": weeklyOff,
      "WeeklyOff2": weeklyOff2,
      "WeeklyOff2Type": weeklyOff2Type,
      "NotApplicableForMonths": notApplicableForMonths,
    };
    var result = await weekOffMasterRepository.addUpdateWeekOff(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = WeekOffMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.weekOffMasterList.isNotEmpty &&
            index < state.weekOffMasterList.length) {
          final updatedListModel = List<WeekOffMasterModel>.from(
            state.weekOffMasterList,
          );
          updatedListModel[index] = updatedList;
          emit(
            state.copyWith(
              isLoading: false,
              weekOffMasterList: updatedListModel,
              currentPage: state.currentPage,
            ),
          );
        }

        showSuccessMessage(context, subTitle: 'WEEK OFF Updateds Successfully');
      },
    );
  }

  // EXPORT WEEK OFF
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await weekOffMasterRepository.getWeekOffForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "ExportType": exportType,
        "WeekOffPolicyName": state.searchText.trim(),
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
              ? "weekOff_${DateTime.now()}.pdf"
              : "weekOff_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // SEARCH BASED ON WEEK OFF
  void searchWeekOff(String value, BuildContext context) {
    emit(
      state.copyWith(
        weekOffMasterList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getWeekOffList(context: context, pageNumber: 1);
  }
}
