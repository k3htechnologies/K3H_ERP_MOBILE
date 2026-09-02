import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/repository/gate_pass.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'gate_pass_state.dart';

class GatePassCubit extends Cubit<GatePassState> {
  GatePassCubit() : super(GatePassState.inital());

  // REPOSITORY
  final GatePassRepository _gatePassRepository =
      serviceLocator<GatePassRepository>();

  Future searchGatePass(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, gatePassList: []));
    await getGatePass(context, 1);
  }

  Future applyGatePassFilterAndSort({
    required BuildContext context,
    String? visitorName,
    String? mobileNumber,
    String? address,
    String? purpose,
    String? appointmentWith,
    DateTime? startDate,
    DateTime? endDate,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByMobileNumber: "",
          filterByAddress: "",
          filterByPurpose: "",
          filterByAppointmentWith: "",
          filterStartDate: null,
          filterEndDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: visitorName ?? state.searchText,
          filterByMobileNumber: mobileNumber ?? state.filterByMobileNumber,
          filterByAddress: address ?? state.filterByAddress,
          filterByPurpose: purpose ?? state.filterByPurpose,
          filterByAppointmentWith:
              appointmentWith ?? state.filterByAppointmentWith,
          filterStartDate: startDate ?? state.filterStartDate,
          filterEndDate: endDate ?? state.filterEndDate,
        ),
      );
    }
    await getGatePass(context, 1);
  }

  int updateGatePassFilterCount(GatePassState state) {
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByMobileNumber.trim().isNotEmpty,
      state.filterByAddress.trim().isNotEmpty,
      state.filterByPurpose.trim().isNotEmpty,
      state.filterByAppointmentWith.trim().isNotEmpty,
      state.filterStartDate != null,
      state.filterEndDate != null,
    ]);
  }

  Future<void> getGatePass(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "IsCheckPermission": false,
      "FullName": state.searchText,
      "MobileNumber": state.filterByMobileNumber,
      "Address": state.filterByAddress,
      "Purpose": state.filterByPurpose,
      "EmployeeName": state.filterByAppointmentWith,
      "FromDate": state.filterStartDate,
      "ToDate": state.filterEndDate,
    };

    final result = await _gatePassRepository.getGatePass(
      pageSize: 10,
      pageNumber: pageNumber,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final logs = response['data'] as List<GatePassModel>;
        final List<GatePassModel> updatedList =
            pageNumber == 1 ? logs : [...state.gatePassList, ...logs];
        emit(
          state.copyWith(
            gatePassList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future addGatePass({
    required BuildContext context,
    required String fullName,
    required String mobileNumber,
    required String address,
    required String purpose,
    required String remark,
    required int employeeId,
    required DateTime passDateTime,
    required int noOfParticipants,
    required MultiFilePickerModel file,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> requestBody = {
      "FullName": fullName,
      "MobileNumber": mobileNumber,
      "Address": address,
      "Purpose": purpose,
      "Remark": remark,
      "EmployeeId": employeeId.toString(),
      "PassDateTime": passDateTime.apiDate!,
      "NoOfParticipants": noOfParticipants.toString(),
    };
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < file.fileNameList.length; i++) {
      if (file.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PhotoURL",
        "value": file.fileBytesList[i],
        "fileName": file.fileNameList[i],
      });
    }
    var updateResult = await _gatePassRepository.addUpdateGatePass(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getGatePass(context, 1);
      },
    );
  }

  Future<void> updateGatePassOut({
    required BuildContext context,
    required int externalId,
    required String uniquekey,
    required String type,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final Map<String, dynamic> requestBody = {
      "ExternalId": externalId,
      "Uniquekey": uniquekey,
      "Type": type,
    };

    final result = await _gatePassRepository.updateGatePassOut(
      body: requestBody,
    );
    if (context.mounted) {
      goRouter.pop();
    }
    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, 'Error', failure.message);
        }
      },
      (response) async {
        final newData = (response['data'] as List<GatePassModel>?) ?? [];
        showSuccessMessage(context, subTitle: response["message"]);
        emit(state.copyWith(gatePassList: newData));
        getGatePass(context, 1);
      },
    );
  }

  Future deleteTermSheet({
    required BuildContext context,
    required GatePassModel gatePass,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _gatePassRepository.deleteGatePass(
      externalId: gatePass.externalId,
      uniquekey: gatePass.uniquekey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);
        final updatedList = List<GatePassModel>.from(state.gatePassList);
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            gatePassList: updatedList,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, "Error", "No Data Found");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _gatePassRepository.exportGatePass(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"FullName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
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
              ? "Gate Pass ${DateTime.now()}.pdf"
              : "Gate Pass ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
