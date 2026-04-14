import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BrokerageScreen extends StatefulWidget {
  const BrokerageScreen({super.key});

  @override
  State<BrokerageScreen> createState() => _BrokerageScreenState();
}

class _BrokerageScreenState extends State<BrokerageScreen> {
  // CUBIT
  late BrokerageCubit _brokerageCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PROJECT MODEL
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _brokerageCubit = context.read<BrokerageCubit>();
    _initializeTextEditingController();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.brokerage]!;
    _onScroll();
    _brokerageCubit.getBrokerageBookingList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_brokerageCubit.state.isLoading! &&
          _brokerageCubit.state.brokerageList.length <
              _brokerageCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _brokerageCubit.getBrokerageBookingList(
            context,
            _brokerageCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Brokerage",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search by Applicant Name",
        onSearchSubmit: (value) {
          _brokerageCubit.searchBrokerage(context, value, _project.projectId);
        },
        textController: _searchC,
        onExportCallback: (value) {
          _brokerageCubit.exportExcelPdf(context, value, _project.projectId);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _brokerageCubit.searchBrokerage(context, "", value.projectId);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          _brokerageCubit.searchBrokerage(context, "", _project.projectId);
        },
        child: BlocBuilder<BrokerageCubit, BrokerageState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.brokerageList.isEmpty) {
              return Center(child: loader());
            }
            if (state.brokerageList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(message: "No Brokerage Data Found"),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _brokerageCubit.state.brokerageList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.brokerageList.length) {
                  return state.brokerageList.length < state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var brokerage = state.brokerageList[index];
                return Container(
                  height: 70,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              brokerage.applicantName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
