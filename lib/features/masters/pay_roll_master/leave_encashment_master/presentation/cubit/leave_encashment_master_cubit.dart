import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/repository/leave_encashment_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class LeaveEncashmentMasterCubit extends Cubit<LeaveEncashmentMasterState> {
  LeaveEncashmentMasterCubit() : super(LeaveEncashmentMasterState.initial());

  final LeaveEncashmentMasterRepository leaveEncashmentMasterRepository =
      serviceLocator<LeaveEncashmentMasterRepository>();

  // SEARCH LEAVE ENCASHMENT
  Future searchLeaveEnhancement(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, leaveEncashmentList: []));
    await getLeaveEncashmentList(context: context, pageNumber: 1);
  }

  // GET LEAVE ENCASHMENT
  Future getLeaveEncashmentList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {"EarningName": state.searchText};

    var result = await leaveEncashmentMasterRepository.getLeaveEncashmentList(
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
        final List<LeaveEncashmentMasterModel> newData =
            List<LeaveEncashmentMasterModel>.from(response['data'] ?? []);

        final List<LeaveEncashmentMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.leaveEncashmentList, ...newData];
        emit(
          state.copyWith(
            leaveEncashmentList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // DELETE LEAVE ENCASHMENT
  Future deleteLeaveEncashment(
    int index,
    LeaveEncashmentMasterModel leaveEncashmentModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await leaveEncashmentMasterRepository.deleteLeaveEncashment(
      slabsId: leaveEncashmentModel.leaveEncashmentSlabId,
      uniqueKey: leaveEncashmentModel.uniqueKey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<LeaveEncashmentMasterModel>.from(
          state.leaveEncashmentList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            leaveEncashmentList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );

        showSuccessMessage(
          context,
          subTitle: "Leave Encashment Deleted Successfully",
        );
      },
    );
  }

  // ADD LEAVE ENCASHMENT
  Future addLeaveEncashment({
    required BuildContext context,
    required String earningMasterName,
    required double minSalary,
    required double maxSalary,
    required double encashmentRate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "LeaveEncashmentMasterSlabsId": 0,
      "EarningMasterName": earningMasterName,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
      "EncashmentRate": encashmentRate,
    };
    var result = await leaveEncashmentMasterRepository.addUpdateLeaveEncashment(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = LeaveEncashmentMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.leaveEncashmentList];
        emit(
          state.copyWith(
            isLoading: false,
            leaveEncashmentList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: 'Leave Encashment Added Successfully',
        );
      },
    );
  }

  // UPDATE LEAVE ENCASHMENT
  Future updateLeaveEncashment({
    required int index,
    required BuildContext context,
    required int leaveEncashmentSlabsId,
    required String uniqueKey,
    required String earningMasterName,
    required double minSalary,
    required double maxSalary,
    required double encashmentRate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "LeaveEncashmentMasterSlabsId": leaveEncashmentSlabsId,
      "Uniquekey": uniqueKey,
      "EarningMasterName": earningMasterName,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
      "EncashmentRate": encashmentRate,
    };
    var result = await leaveEncashmentMasterRepository.addUpdateLeaveEncashment(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = LeaveEncashmentMasterModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.leaveEncashmentList.isNotEmpty &&
            index < state.leaveEncashmentList.length) {
          final updatedListModel = List<LeaveEncashmentMasterModel>.from(
            state.leaveEncashmentList,
          );
          updatedListModel[index] = updatedList;
          emit(
            state.copyWith(
              isLoading: false,
              leaveEncashmentList: updatedListModel,
              currentPage: state.currentPage,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Leave Encashment Updateds Successfully',
        );
      },
    );
  }

  // EXPORT LEAVE ENCASHMENT
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await leaveEncashmentMasterRepository
        .getLeaveEncashmentForExport(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {"ExportType": exportType},
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "leave_encashment_${DateTime.now()}.pdf"
              : "leave_encashment_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
