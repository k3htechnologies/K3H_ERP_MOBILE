import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryState.initial());

  // REPOSITORY
  final InventoryRepository _inventoryRepository = serviceLocator<InventoryRepository>();


  // GET ENTIRE INVENTORY
  Future getInventory(BuildContext context, int projectId) async {
    emit(state.copyWith(isLoading: true));
    final result = await _inventoryRepository.getInventory(
      projectId: projectId,
    );
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
          (result) {
        emit(
          state.copyWith(
            isLoading: false,
            buildingList: result["data"] as List<BuildingModel>,
          ),
        );
        if (result["data"].isEmpty) {
          goRouter.go(AppRoutes.addInventory);
        }
      },
    );
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

}
