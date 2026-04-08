import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/datasource/purchase_order.datasource.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/repository/purchase_order.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';

void registerMaterialRequisitionPurchaseOrderDependencies(
  GetIt serviceLocator,
) {
  serviceLocator.registerSingleton<PurchaseOrderDatasource>(
    PurchaseOrderDatasourceImpl(),
  );
  serviceLocator.registerSingleton<PurchaseOrderRepository>(
    PurchaseOrderRepositoryImpl(
      purchaseOrderDatasource: serviceLocator<PurchaseOrderDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<PurchaseOrderCubit>(PurchaseOrderCubit());
}
