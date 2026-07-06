import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off_dates.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/repository/comp_off.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'comp_off_state.dart';

class CompOffCubit extends Cubit<CompOffState> {
  CompOffCubit() : super(CompOffState.initial());

  // REPOSITORIES
  final CompOffRepository _compOffRepository =
      serviceLocator<CompOffRepository>();

  // GET COMP OFF LIST
  Future getCompOffList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {};
    if (state.filterStartDate != null) {
      queryParams["StartDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterStartDate!);
    }
    if (state.filterEndDate != null) {
      queryParams["EndDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterEndDate!);
    }
    var result = await _compOffRepository.getCompOffList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CompOffModel> newData = List<CompOffModel>.from(
          response['data'] ?? [],
        );

        final List<CompOffModel> updatedList =
            pageNumber == 1 ? newData : [...state.compOffList, ...newData];
        emit(
          state.copyWith(
            compOffList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ADD COMP OFF
  Future addCompOff({
    required BuildContext context,
    required DateTime compOffDate,
    required DateTime workingDate,
    required String reason,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "CompOffId": 0,
      "CompOffDate": compOffDate.toIso8601String(),
      "WorkingDate": workingDate.toIso8601String(),
      "Reason": reason,
    };
    var addResult = await _compOffRepository.addUpdateCompOff(
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
        showSuccessMessage(context, subTitle: 'Comp Off Added Successfully!!!');
      },
    );
  }

  // UPDATE COMP OFF
  Future updateCompOff({
    required BuildContext context,
    required int compOffId,
    required String uniqueKey,
    required DateTime compOffDate,
    required DateTime workingDate,
    required String reason,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "CompOffId": compOffId,
      "Uniquekey": uniqueKey,
      "CompOffDate": compOffDate.toIso8601String(),
      "WorkingDate": workingDate.toIso8601String(),
      "Reason": reason,
    };
    var addResult = await _compOffRepository.addUpdateCompOff(
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
        final updatedCompOff = response['data'][0] as CompOffModel;

        if (state.compOffList.isNotEmpty && index < state.compOffList.length) {
          final updatedList = List<CompOffModel>.from(state.compOffList);
          updatedList[index] = updatedCompOff;
          emit(state.copyWith(compOffList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Comp Off Updated Successfully!!!',
        );
      },
    );
  }

  // DELETE COMP OFF
  Future deleteCompOff({
    required BuildContext context,
    required int compOffId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _compOffRepository.deleteCompOff(
      compOffId: compOffId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Comp Off Deleted Successfully!!!',
        );
        if (index != null) {
          final updatedList = List<CompOffModel>.from(state.compOffList);
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              compOffList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getCompOffList(context, state.currentPage);
        }
      },
    );
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> queryParams = {};
    if (state.filterStartDate != null) {
      queryParams["StartDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterStartDate!);
    }
    if (state.filterEndDate != null) {
      queryParams["EndDate"] = DateFormat(
        'yyyy-MM-dd',
      ).format(state.filterEndDate!);
    }
    var result = await _compOffRepository.exportCompOff(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "comp_off_${DateTime.now()}.pdf"
              : "comp_off_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // GET COMP OFF DATES LIST
  Future getCompOffDatesList(
    BuildContext context,
    int pageNumber,
    DateTime startDate,
    DateTime endDate,
  ) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "StartDate": startDate.toIso8601String(),
      "EndDate": endDate.toIso8601String(),
    };
    var result = await _compOffRepository.getCompOffDatesList(
      pageNumber: pageNumber,
      pageSize: 50,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CompOffDatesModel> newData = List<CompOffDatesModel>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(compOffDatesList: newData, isLoading: false));
      },
    );
  }

  // SET WORKED DATE
  void setWorkedDate(DateTime? date) {
    emit(state.copyWith(workedDate: date, clearWorkedDate: false));
  }

  // SET COMP OFF DATE
  void setCompOffDate(DateTime? date) {
    emit(state.copyWith(compOffDate: date, clearCompOffDate: false));
  }

  // CLEAR WORKED DATE
  void clearWorkedDate() {
    // When worked date is cleared, also clear comp-off date
    emit(state.copyWith(clearWorkedDate: true, clearCompOffDate: true));
  }

  // CLEAR COMP OFF DATE
  void clearCompOffDate() {
    emit(state.copyWith(clearCompOffDate: true));
  }

  // SET REASON
  void setReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  // APPLY FILTER ON COMP OFF
  void applyFilterOnCompOff({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    emit(
      state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
        compOffList: [],
        currentPage: 1,
      ),
    );
    getCompOffList(context, 1);
  }

  int updateFilterCount(CompOffState state) {
    return getActiveFilterCount([
      state.filterStartDate != null,
      state.filterEndDate != null,
    ]);
  }
}
