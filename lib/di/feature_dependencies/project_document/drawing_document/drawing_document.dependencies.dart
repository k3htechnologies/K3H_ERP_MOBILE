import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/datasource/drawing_document.datasource.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/repository/drawing_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/cubit/drawing_document_cubit.dart';

void registerDrawingDocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DrawingDocumentDatasource>(
    DrawingDocumentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DrawingDocumentRepository>(
    DrawingDocumentRepositoryImpl(
      drawingDocumentDatasource: serviceLocator<DrawingDocumentDatasource>(),
    ),
  );
  // CUBITS
  serviceLocator.registerSingleton<DrawingDocumentCubit>(
    DrawingDocumentCubit(),
  );
}
