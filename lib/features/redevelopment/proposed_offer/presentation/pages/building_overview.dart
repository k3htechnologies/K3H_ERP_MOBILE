import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/widgets/building_overview.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';

class ProposedOfferBuildingOverview extends StatefulWidget {
  const ProposedOfferBuildingOverview({super.key});

  @override
  State<ProposedOfferBuildingOverview> createState() =>
      _ProposedOfferBuildingOverviewState();
}

class _ProposedOfferBuildingOverviewState
    extends State<ProposedOfferBuildingOverview> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
      builder: (context, state) {
        return Expanded(
          child: BuildingOverview(building: state.buildingDetails!),
        );
      },
    );
  }
}
