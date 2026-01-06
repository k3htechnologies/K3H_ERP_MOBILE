import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/repository/tenant.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:meta/meta.dart';

part 'tenant_state.dart';

class TenantCubit extends Cubit<TenantState> {
  TenantCubit() : super(TenantState.initial());

  final TenantRepository _tenantRepository = serviceLocator<TenantRepository>();

  // <---- SEARCH TENANT ---->
  void searchTenant(
    String value,
    BuildContext context,
    int projectId,
    int buildingId,
  ) {
    emit(
      state.copyWith(
        tenantList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );

    getTenantList(
      context: context,
      projectId: projectId,
      buildingId: buildingId,
      pageNumber: 1,
      pageSize: 10,
    );
  }

  // <---- GET ASSET LIST ---->
  Future getTenantList({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int pageNumber,
    required int pageSize,
  }) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "FlatNumber": state.searchText,
      "IsCheckPermission": false,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _tenantRepository.getTenantList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      buildingId: buildingId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<TenantModel> newData = List<TenantModel>.from(
          response['data'] ?? [],
        );

        final List<TenantModel> updatedList =
            pageNumber == 1 ? newData : [...state.tenantList, ...newData];

        emit(
          state.copyWith(
            tenantList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }
}
