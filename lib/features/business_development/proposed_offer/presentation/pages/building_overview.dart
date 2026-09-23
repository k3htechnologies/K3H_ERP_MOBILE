import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/pages/widgets/building_overview.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Building Overview',
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
              ),
              verticalSpacing(),
              Expanded(
                child: BuildingOverview(
                  building: state.buildingDetails!,
                  buildingCardTitle: "Basic Details",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
