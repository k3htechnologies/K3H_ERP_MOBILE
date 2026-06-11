import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/model/channel_partner_category.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/repository/channel_partner_category.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/presentation/cubit/channel_partner_category_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ChannelPartnerCategoryCubit extends Cubit<ChannelPartnerCategoryState> {
  ChannelPartnerCategoryCubit() : super(ChannelPartnerCategoryState.initial());

  // REPOSITORY
  final ChannelPartnerCategoryRepository _repository =
      serviceLocator<ChannelPartnerCategoryRepository>();

  // GET LIST
  Future getChannelPartnerCategoryList(
    BuildContext context,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }

    var result = await _repository.getChannelPartnerCategoryList(
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ChannelPartnerCategoryModel> newData =
            List<ChannelPartnerCategoryModel>.from(response['data'] ?? []);

        emit(
          state.copyWith(channelPartnerCategoryList: newData, isLoading: false),
        );
      },
    );
  }

  Future updateChannelPartnerCategory({
    required BuildContext context,
    required int projectId,
    required List<ChannelPartnerCategoryModel> channelPartnerCategoryJSON,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "ProjectId": projectId,
      "ChannelPartnerCategoryJSON": jsonEncode(
        channelPartnerCategoryJSON.map((c) => c.toJson()).toList(),
      ),
    };

    var result = await _repository.addUpdateChannelPartnerCategory(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);
        getChannelPartnerCategoryList(context, projectId);
      },
    );
  }

  // EXPORT PAYMENT SCHEDULE SCHEME

  Future exportExcelPdf(
    BuildContext context,
    String exportType, {
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _repository.exportChannelPartnerCategory(
      projectId: projectId,
      queryParams: {"ExportType": exportType},
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
              ? "Channel Partner Category ${DateTime.now()}.pdf"
              : "Channel Partner Category ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
