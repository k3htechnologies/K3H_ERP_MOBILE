import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/datasource/approval_document.datasource.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/repository/approval_document.repository.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';

void registerApprovalDocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ApprovalDocumentDatasource>(
    ApprovalDocumentDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ApprovalDocumentRepository>(
    ApprovalDocumentRepositoryImpl(
      documentDatasource: serviceLocator<ApprovalDocumentDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ApprovalDocumentCubit>(
    ApprovalDocumentCubit(),
  );
}
