import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/cubit/target_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  // CUBIT
  late TargetCubit _targetCubit;

  // PROJECT
  late ProjectModel _project;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _targetCubit = context.read<TargetCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.salesTarget]!;
    _initializeTextEditingController();
    _onScroll();
    _targetCubit.getSalesTargetList(
      context: context,
      projectId: _project.projectId,
    );
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_targetCubit.state.isLoading! &&
          _targetCubit.state.salesTargets.length <
              _targetCubit.state.totalNumberOfRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _targetCubit.getSalesTargetList(
            context: context,
            projectId: _project.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Target",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _targetCubit.searchSalesTarget(context, _project.projectId, value);
        },
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addSalesTarget);
        },
        onExportCallback: (value) {
          _targetCubit.exportExcelPdf(context, value);
        },
      ),
      body: BlocBuilder<TargetCubit, TargetState>(
        builder: (_, state) {
          if ((state.isLoading ?? true) && state.salesTargets.isEmpty) {
            return Center(child: loader());
          }
          if (state.salesTargets.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _targetCubit.state.salesTargets.length + 1,
            itemBuilder: (context, index) {
              if (index == state.salesTargets.length) {
                return state.salesTargets.length < state.totalNumberOfRecords
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var salesTarget = state.salesTargets[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salesTarget.employeeName,
                      style: AppTextStyle.ts14M(
                        color: AppColor.primary,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.primary,
                      ),
                    ),
                    verticalSpacing(),
                    buildRowTitleValue(
                      title: "No. Of Target Booking",
                      value: salesTarget.plannedTarget.toString(),
                      fixesWidth: 200,
                    ),
                    buildRowTitleValue(
                      title: "Achieved Target Booking",
                      value: salesTarget.achievedTarget.toString(),
                      fixesWidth: 200,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
