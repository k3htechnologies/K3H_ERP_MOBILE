import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/marketing/content/data/datasource/content_datasource.dart';
import 'package:k3h_erp_app/features/marketing/content/data/repository/content_repository.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_document/content_document_cubit.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_folder/content_folder_cubit.dart';

void registerContentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ContentDataSource>(ContentDataSourceImpl());
  serviceLocator.registerSingleton<ContentRepository>(
    ContentRepositoryImpl(
      contentDatasource: serviceLocator<ContentDataSource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ContentFolderCubit>(ContentFolderCubit());

  serviceLocator.registerSingleton<ContentDocumentCubit>(
    ContentDocumentCubit(),
  );
}
