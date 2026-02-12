import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/model/sourcing.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/repository/sourcing.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'sourcing_state.dart';

class SourcingCubit extends Cubit<SourcingState> {
  SourcingCubit() : super(SourcingState.initial());

  // REPOSITORIES
  final SourcingRepository _sourcingRepository =
      serviceLocator<SourcingRepository>();

  final ChannelPartnerRepository _channelPartnerRepository =
  serviceLocator<ChannelPartnerRepository>();


  // ON TAB CHANGE
  void onTabChanged(int index, BuildContext context,{required int channelPartnerId,required int projectId}) {
    emit(state.copyWith(currentTabIndex: index,isIBM: true));
    if(index==1){
      getSourcingList(context, 1, channelPartnerId, projectId);
    }
  }

  void onIBMTabChanged(String value, BuildContext context) {
    emit(state.copyWith(isIBM: value.toLowerCase()=="ibm"?true:false));
  }

  // <---- SEARCH CHANNEL PARTNER ---->
  Future searchChannelPartner(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, channelPartnerList: []));
    await getChannelPartnerList(context, 1);
  }

  // <---- GET SOURCING LIST ---->
  Future getSourcingList(BuildContext context, int pageNumber,int channelPartnerId,int projectId) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerId": channelPartnerId,
      "ProjectId": projectId,
    };
    var result = await _sourcingRepository.getSourcingList(
      pageNumber: pageNumber,
      pageSize: 500,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SourcingModel> newData = List<SourcingModel>.from(
          response['data'] ?? [],
        );

        final List<SourcingModel> updatedList =
            pageNumber == 1 ? newData : [...state.sourcingList, ...newData];
        emit(
          state.copyWith(
            sourcingList: updatedList,
            isLoading: false,
          ),
        );
      },
    );
  }

  // <---- GET CHANNEL PARTNER LIST ---->
  Future getChannelPartnerList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerName": state.searchText,
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
        final List<ChannelPartnerModel> newData = List<ChannelPartnerModel>.from(
          response['data'] ?? [],
        );

        final List<ChannelPartnerModel> updatedList =
        pageNumber == 1 ? newData : [...state.channelPartnerList, ...newData];
        emit(
          state.copyWith(
            channelPartnerList: updatedList,
            isLoading: false,
            totalNumberOfRecordCP: response["totalNumberOfRecord"],
            currentPageCp: pageNumber,
          ),
        );
      },
    );
  }

}
