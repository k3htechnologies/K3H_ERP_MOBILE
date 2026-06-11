import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/datasource/channel_partner_category.datasource.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/repository/channel_partner_category.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/presentation/cubit/channel_partner_category_cubit.dart';

void registerChannelPartnerCategoryDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ChannelPartnerCategoryDatasource>(
    ChannelPartnerCategoryDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ChannelPartnerCategoryRepository>(
    ChannelPartnerCategoryRepositoryImpl(
      channelPartnerCategoryDatasource:
          serviceLocator<ChannelPartnerCategoryDatasource>(),
    ),
  );

  serviceLocator.registerSingleton<ChannelPartnerCategoryCubit>(
    ChannelPartnerCategoryCubit(),
  );
}
