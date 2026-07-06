import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/datasource/document_category.datasource.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/cubit/document_category_cubit.dart';

void registerDocumentCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DocumentCategoryDatasource>(
    DocumentCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DocumentCategoryRepository>(
    DocumentCategoryRepositoryImpl(
      documentCategoryDatasource: serviceLocator<DocumentCategoryDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DocumentCategoryCubit>(
    DocumentCategoryCubit(),
  );
}
