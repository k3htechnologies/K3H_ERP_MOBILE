import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/repository/brokerage.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'brokerage_state.dart';

class BrokerageCubit extends Cubit<BrokerageState> {
  BrokerageCubit() : super(BrokerageState.initial());

  // REPOSITORIES
  final BrokerageRepository _brokerageRepository =
      serviceLocator<BrokerageRepository>();

  // <---- SEARCH DEPARTMENT ---->
  Future searchBrokerage(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, brokerageList: []));
    await getBrokerageBookingList(context, 1, projectId);
  }

  // <---- GET BROKERAGE BOOKING LIST ---->
  Future getBrokerageBookingList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ApplicantName": state.searchText,
      "ProjectId": projectId,
    };
    var result = await _brokerageRepository.getBrokerageBookingList(
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
        final List<BrokerageModel> newData = List<BrokerageModel>.from(
          response['data'] ?? [],
        );

        final List<BrokerageModel> updatedList =
            pageNumber == 1 ? newData : [...state.brokerageList, ...newData];
        emit(
          state.copyWith(
            brokerageList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _brokerageRepository.exportBrokerageBooking(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
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
              ? "Brokerage Booking ${DateTime.now()}.pdf"
              : "Brokerage Booking ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
