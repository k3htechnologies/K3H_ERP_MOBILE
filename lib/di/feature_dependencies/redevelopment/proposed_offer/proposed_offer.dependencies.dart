import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/datasource/proposed_offer.datasource.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/repository/proposed_offer.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';

void registerProposedOfferDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ProposedOfferDatasource>(
    ProposedOfferDatasourceImpl(),
  );

  serviceLocator.registerSingleton<ProposedOfferRepository>(
    ProposedOfferRepositoryImpl(
      proposedOfferDatasource: serviceLocator<ProposedOfferDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ProposedOfferCubit>(ProposedOfferCubit());
}
