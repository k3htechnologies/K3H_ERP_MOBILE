// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/model/dcr.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/presentation/cubit/dcr_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DCRScreen extends StatefulWidget {
  const DCRScreen({super.key});

  @override
  State<DCRScreen> createState() => _DCRScreenState();
}

class _DCRScreenState extends State<DCRScreen> with TickerProviderStateMixin {
  // TAB CONTROLLERS
  late TabController _tabController;
  late ProjectModel _selectedProject;
  late DcrCubit _dcrCubit;
  late TextEditingController _searchTextC;
  final ValueNotifier<DateTime?> fromDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> toDateNotifier = ValueNotifier(null);
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  late AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _dcrCubit = context.read<DcrCubit>();
    _selectedProject = getProject();
    _searchTextC = TextEditingController();
    _onScroll();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.dailyCollectionReport]!;
    _dcrCubit.getDailyCollectionReportList(
      context,
      filterType: "TODAY",
      projectId: _selectedProject.projectId,
      pageNumber: 1,
    );
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    String filterType = "TODAY";

    switch (_tabController.index) {
      case 0:
        filterType = "TODAY";
        break;
      case 1:
        filterType = "WEEKLY";
        break;
      case 2:
        filterType = "MONTHLY";
        break;
      case 3:
        filterType = "DATEWISE";
        break;
      case 4:
        filterType = "OVERALL";
        break;
    }

    // User switched away from Datewise
    if (filterType != "DATEWISE") {
      fromDateNotifier.value = null;
      toDateNotifier.value = null;
    }

    if (filterType == "DATEWISE") {
      fromDateNotifier.value = null;
      toDateNotifier.value = null;

      _dcrCubit.emit(
        _dcrCubit.state.copyWith(
          selectedFilterType: "DATEWISE",
          dcrReportList: [],
          dcrModel: null,
        ),
      );
      return;
    }
  }

  @override
  void dispose() {
    _searchTextC.dispose();
    _tabController.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_dcrCubit.state.isLoading ?? false) &&
          _dcrCubit.state.dcrReportList.length <
              _dcrCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _dcrCubit.getDailyCollectionReportList(
            context,
            pageNumber: _dcrCubit.state.currentPage + 1,
            filterType: _dcrCubit.state.selectedFilterType,
            projectId: _selectedProject.projectId,
            fromDate:
                fromDateNotifier.value != null
                    ? formatDateTimeForApi(fromDateNotifier.value!)
                    : null,
            toDate:
                toDateNotifier.value != null
                    ? formatDateTimeForApi(toDateNotifier.value!)
                    : null,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Daily Collection Report",
        onSearchSubmit: (value) {
          _dcrCubit.searchDCR(
            context,
            value,
            filterType: _dcrCubit.state.selectedFilterType,
          );
        },
        textController: _searchTextC,
        searchHintText: "Search By Project Name",
        onExportCallback: (value) {
          if (_dcrCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _dcrCubit.exportExcelPdf(context, value);
        },
        onProjectChangeCallback: (value) {
          _selectedProject = value;
          _dcrCubit.getDailyCollectionReportList(
            context,
            filterType: _dcrCubit.state.selectedFilterType,
            projectId: _selectedProject.projectId,
            pageNumber: 1,
          );
        },
        authorization: _routeAuthorizationModel,
      ),
      body: BlocBuilder<DcrCubit, DcrState>(
        builder: (context, state) {
          if ((state.isLoading ?? false) && state.dcrReportList.isEmpty) {
            return Center(child: loader());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipStyleTabBar(
                isSecondaryStyle: false,
                controller: _tabController,
                tabs: ["Today", "Weekly", "Monthly", "Datewise", "Overall"],
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      if (state.selectedFilterType == "DATEWISE") ...[
                        verticalSpacing(),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: fromDateNotifier,
                          builder: (context, fromDate, _) {
                            return ValueListenableBuilder<DateTime?>(
                              valueListenable: toDateNotifier,
                              builder: (context, toDate, _) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomDatePicker(
                                          hint: "Select From Date",
                                          title: "From Date",
                                          initialDate: fromDate,
                                          setValue: (value) {
                                            fromDateNotifier.value = value;
                                            toDateNotifier.value = null;
                                          },
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: CustomDatePicker(
                                          hint: "Select To Date",
                                          title: "To Date",
                                          initialDate: toDate,
                                          startDate: fromDate,
                                          setValue: (value) async {
                                            toDateNotifier.value = value;

                                            if (fromDateNotifier.value !=
                                                    null &&
                                                toDateNotifier.value != null) {
                                              await _dcrCubit
                                                  .getDailyCollectionReportList(
                                                    context,
                                                    filterType: "DATEWISE",
                                                    projectId:
                                                        _selectedProject
                                                            .projectId,
                                                    fromDate:
                                                        formatDateTimeForApi(
                                                          fromDateNotifier
                                                              .value!,
                                                        ),
                                                    toDate:
                                                        formatDateTimeForApi(
                                                          toDateNotifier.value!,
                                                        ),
                                                    pageNumber: 1,
                                                  );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      verticalSpacing(height: 16.0),
                      state.dcrReportList.isEmpty
                          ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: noDataWidget(
                                message: "No Daily Collection Report Found",
                                iconSize: 180.0,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount:
                                state.dcrReportList.length +
                                (state.dcrReportList.length <
                                        state.totalNumberOfRecord
                                    ? 1
                                    : 0),
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index >= state.dcrReportList.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final item = state.dcrReportList[index];
                              return DcrReportCard(item: item);
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DcrReportCard extends StatefulWidget {
  final DcrModel item;

  const DcrReportCard({super.key, required this.item});

  @override
  State<DcrReportCard> createState() => _DcrReportCardState();
}

class _DcrReportCardState extends State<DcrReportCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xff0058BE),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              horizontalSpacing(width: 12),
              Expanded(
                child: Text(
                  widget.item.projectName,
                  style: AppTextStyle.ts16M(
                    color: AppColor.greyTitleAndValueColor,
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 13),
          Row(
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Month Collection",
                  value: widget.item.target.toString(),
                ),
              ),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "FTD Collection",
                  value: widget.item.ftd.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "New Booking",
                  value: widget.item.newBooking.toString(),
                ),
              ),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "FTM Collection",
                  value: widget.item.ftm.toString(),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 14),
          Divider(
            thickness: 0.25,
            color: AppColor.black.withValues(alpha: 0.5),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
            childrenPadding: EdgeInsets.zero,
            backgroundColor: AppColor.white,
            collapsedBackgroundColor: AppColor.white,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            iconColor: Color(0xff0058BE),
            collapsedIconColor: Color(0xff0058BE),
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              "View Registration Details",
              style: AppTextStyle.ts12R(color: Color(0xff0058BE)),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Reg Target",
                          value: widget.item.regTarget.toString(),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Reg Done (FTD)",
                          value: widget.item.regDoneFtd.toString(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Reg Done (MTD)",
                          value: widget.item.regDoneMtd.toString(),
                        ),
                      ),
                      horizontalSpacing(),
                      Expanded(
                        child: buildColumnTitleValueNormal(
                          title: "Balance Against Target",
                          value: widget.item.balanceAgainstTarget.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
