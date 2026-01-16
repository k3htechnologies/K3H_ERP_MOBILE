import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/datasource/rera_document.datasource.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/repository/rera_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';

void registerRERADocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<RERADocumentDatasource>(
    RERADocumentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<RERADocumentRepository>(
    RERADocumentRepositoryImpl(
      reraDocumentDatasource: serviceLocator<RERADocumentDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<RERADocumentCubit>(RERADocumentCubit());
}
