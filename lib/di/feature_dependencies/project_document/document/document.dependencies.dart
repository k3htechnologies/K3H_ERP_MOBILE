import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/document/data/datasource/document.datasource.dart';
import 'package:k3h_erp_app/features/project_document/document/data/repository/document.repository.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';

void registerDocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DocumentDatasource>(
    DocumentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DocumentRepository>(
    DocumentRepositoryImpl(
      documentDatasource: serviceLocator<DocumentDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DocumentCubit>(DocumentCubit());
}
