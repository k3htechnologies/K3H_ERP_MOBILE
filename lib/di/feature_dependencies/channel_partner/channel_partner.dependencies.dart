import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/channel_partner/data/datasource/channel_partner.datasource.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';

void registerChannelPartnerDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ChannelPartnerDatasource>(
    ChannelPartnerDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ChannelPartnerRepository>(
    ChannelPartnerRepositoryImpl(
      channelPartnerDatasource: serviceLocator<ChannelPartnerDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<ChannelPartnerCubit>(ChannelPartnerCubit());
}
