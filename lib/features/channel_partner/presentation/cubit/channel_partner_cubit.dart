import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'channel_partner_state.dart';

class ChannelPartnerCubit extends Cubit<ChannelPartnerState> {
  ChannelPartnerCubit() : super(ChannelPartnerState.initial());

  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();

  // <---- SEARCH CHANNEL PARTNER ---->
  Future searchChannelPartner(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, channelPartnerList: []));
    await getChannelPartnerList(context, 1);
  }

  // <---- GET CHANNEL PARTNER LIST ---->
  Future getChannelPartnerList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerName": state.searchText,
      "CompanyName": state.filterByCompanyName,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _channelPartnerRepository.getChannelPartnerList(
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
        final List<ChannelPartnerModel> newData =
            List<ChannelPartnerModel>.from(response['data'] ?? []);

        final List<ChannelPartnerModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.channelPartnerList, ...newData];
        emit(
          state.copyWith(
            channelPartnerList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _channelPartnerRepository.exportChannelPartner(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {
                "ChannelPartnerName": state.searchText,
                "ExportType": exportType,
              }
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
              ? "channel_partner_${DateTime.now()}.pdf"
              : "channel_partner_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
