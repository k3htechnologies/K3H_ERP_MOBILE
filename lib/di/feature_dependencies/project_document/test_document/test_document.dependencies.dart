import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/datasource/test_document.datasource.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/repository/test_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/test_document/presentation/cubit/test_document_cubit.dart';

void registerTestDocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TestDocumentDatasource>(
    TestDocumentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<TestDocumentRepository>(
    TestDocumentRepositoryImpl(
      testDocumentDatasource: serviceLocator<TestDocumentDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TestDocumentCubit>(TestDocumentCubit());
}
