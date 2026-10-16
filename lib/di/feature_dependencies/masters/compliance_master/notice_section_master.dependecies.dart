import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/datasource/notice_section.datasource.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/repository/notice_section.repository.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/presentation/cubit/notice_section_cubit.dart';

void registerNoticeSectionMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<NoticeSectionMasterDatasource>(
    NoticeSectionMasterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<NoticeSectionMasterRepository>(
    NoticeSectionMasterRepositoryImpl(
      noticeSectionDatasource: serviceLocator<NoticeSectionMasterDatasource>(),
    ),
  );

  serviceLocator.registerSingleton<NoticeSectionMasterCubit>(
    NoticeSectionMasterCubit(),
  );
}
