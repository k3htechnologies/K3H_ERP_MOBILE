import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/datasource/test_document_category.datasource.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/repository/test_document_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/presentation/cubit/test_document_category_cubit.dart';

void registerTestDocumentCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TestDocumentCategoryDatasource>(
    TestDocumentCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<TestDocumentCategoryRepository>(
    TestDocumentCategoryRepositoryImpl(
      testDocumentCategoryDatasource:
          serviceLocator<TestDocumentCategoryDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TestDocumentCategoryCubit>(
    TestDocumentCategoryCubit(),
  );
}
