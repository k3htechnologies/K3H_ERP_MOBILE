import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/model/umo_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/repository/umo_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'umo_master_state.dart';

class UOMMasterCubit extends Cubit<UOMMasterState> {
  UOMMasterCubit() : super(UOMMasterState.initial());

  // REPOSITORY
  final UOMMasterRepository _uomMasterRepository =
      serviceLocator<UOMMasterRepository>();

  // <---- GET UOM MASTER ---->
  Future getUOMMasterList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"Uom": state.searchText};
    var result = await _uomMasterRepository.getUOMList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<UOMModel> updatedList =
            pageNumber == 1 ? [] : List.from(state.uomList);
        updatedList.addAll(
          (response['data'] as List).map((e) => UOMModel.fromJson(e)).toList(),
        );
        emit(
          state.copyWith(
            isLoading: false,
            uomList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- SEARCH UOM ---->
  Future searchUOM(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, uomList: []));
    await getUOMMasterList(context, 1);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _uomMasterRepository.exportUMO(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"Uom": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "uom_${DateTime.now()}.pdf"
              : "uom_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
