import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/datasource/drawing_document_category.datasource.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/repository/drawing_document_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/presentation/cubit/drawing_document_category_cubit.dart';

void registerDrawingDocumentCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DrawingDocumentCategoryDatasource>(
    DrawingDocumentCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DrawingDocumentCategoryRepository>(
    DrawingDocumentCategoryRepositoryImpl(
      drawingDocumentCategoryDatasource:
          serviceLocator<DrawingDocumentCategoryDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DrawingDocumentCategoryCubit>(
    DrawingDocumentCategoryCubit(),
  );
}
