import 'package:get_it/get_it.dart';

import '../../../../features/sales/sales_reports/achievement/data/datasource/achievement_report.datasource.dart';
import '../../../../features/sales/sales_reports/achievement/data/repository/achievement_report.repository.dart';
import '../../../../features/sales/sales_reports/achievement/presentation/cubit/achievement_report_cubit.dart';

void registerAchievementReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AchievementReportDatasource>(
    AchievementReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<AchievementReportRepository>(
    AchievementReportRepositoryImpl(
      achievementReportDatasource:
          serviceLocator<AchievementReportDatasource>(),
    ),
  );
  serviceLocator.registerSingleton<AchievementReportCubit>(
    AchievementReportCubit(),
  );
}
