import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/datasource/invoice.datasource.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/repository/invoice.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';

void registerMaterialRequisitionInvoiceDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<InvoiceDatasource>(InvoiceDatasourceImpl());
  serviceLocator.registerSingleton<InvoiceRepository>(
    InvoiceRepositoryImpl(
      invoiceDatasource: serviceLocator<InvoiceDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<InvoiceCubit>(InvoiceCubit());
}
