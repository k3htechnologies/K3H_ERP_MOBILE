import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/datasource/approval_category.datasource.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/repository/approval_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/cubit/approval_category_cubit.dart';

void registerApprovalCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ApprovalCategoryDatasource>(
    ApprovalCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ApprovalCategoryRepository>(
    ApprovalCategoryRepositoryImpl(
      documentCategoryDatasource: serviceLocator<ApprovalCategoryDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ApprovalCategoryCubit>(
    ApprovalCategoryCubit(),
  );
}
