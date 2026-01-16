import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/datasource/rera_document_category.datasource.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/repository/rera_document_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_cubit.dart';

void registerRERADocumentCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<RERADocumentCategoryDatasource>(
    RERADocumentCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<RERADocumentCategoryRepository>(
    RERADocumentCategoryRepositoryImpl(
      reraDocumentCategoryDatasource:
          serviceLocator<RERADocumentCategoryDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<RERADocumentCategoryCubit>(
    RERADocumentCategoryCubit(),
  );
}
