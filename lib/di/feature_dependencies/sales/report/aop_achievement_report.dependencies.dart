import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/datasource/aop_achievement_report.datasource.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/repository/aop_achievement_report.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/presentation/cubit/aop_achievement_report_cubit.dart';

void registerAopAchievementReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AopAchievementReportDatasource>(
    AopAchievementReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<AopAchievementReportRepository>(
    AopAchievementReportRepositoryImpl(
      aopAchievementReportDatasource:
          serviceLocator<AopAchievementReportDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<AopAchievementReportCubit>(
    AopAchievementReportCubit(),
  );
}
