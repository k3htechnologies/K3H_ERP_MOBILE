import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_state.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/pages/widgets/inward_outward_document_view.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/pages/widgets/inward_outward_overview.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/pages/widgets/inward_outward_revert_view.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import '../../../../../widgets/app_bar/custom_app_bar_with_back_button.dart';

class InwardOutwardViewScreen extends StatefulWidget {
  final InwardOutwardModel inwardOutwardModel;
  const InwardOutwardViewScreen({super.key, required this.inwardOutwardModel});

  @override
  State<InwardOutwardViewScreen> createState() =>
      _InwardOutwardViewScreenState();
}

class _InwardOutwardViewScreenState extends State<InwardOutwardViewScreen>
    with SingleTickerProviderStateMixin {
  late InwardOutwardCubit _inwardOutwardCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TabController _tabController;
  List<String> inwardOutwardViewTabs = const ['Overview', 'Document', 'Revert'];

  @override
  void initState() {
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .inwardOutwardAdministrativeAccess] ??
        Authorization.routeAuthorizationMap[AppRoutes
            .inwardOutwardAcknowledgement] ??
        AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _inwardOutwardCubit.getInwardOutwardView(
      context,
      widget.inwardOutwardModel.inwardOutwardId,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inward Outward",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Text(
              widget.inwardOutwardModel.systemGeneratedCode,
              style: AppTextStyle.ts16M(),
            ),
          ),
          ChipStyleTabBar(
            style: ChipTabBarStyle.underline,
            controller: _tabController,
            tabs: inwardOutwardViewTabs,
          ),
          BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
            builder: (context, state) {
              if ((state.isLoading ?? false) ||
                  state.inwardOutwardDetails == null) {
                return Expanded(child: Center(child: loader()));
              }

              return Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    overviewSection(context, state.inwardOutwardDetails!),
                    documentSection(context, state.inwardOutwardDetails!),
                    RevertSection(
                      context: context,
                      inwardOutward: state.inwardOutwardDetails!,
                      routeAuthorizationModel: _routeAuthorizationModel,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
