import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/presentation/cubit/redevlopment_dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RedevelopmentDashboardScreen extends StatefulWidget {
  const RedevelopmentDashboardScreen({super.key});

  @override
  State<RedevelopmentDashboardScreen> createState() =>
      _RedevelopmentDashboardScreenState();
}

class _RedevelopmentDashboardScreenState
    extends State<RedevelopmentDashboardScreen> {
  // REDEVELOPMENT  REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();

  // CUBIT
  late RedevlopmentDashboardCubit _redevlopmentDashboardCubit;
  late ProjectModel selectedProject;

  List<Map<String, dynamic>> selectedBuilding = [];

  @override
  void initState() {
    super.initState();
    _redevlopmentDashboardCubit = context.read<RedevlopmentDashboardCubit>();

    final project = getProject(); // from local storage
    _redevlopmentDashboardCubit.getRedevelopmentDashboardList(
      context,
      project.projectId,
    );
  }

  // FETCH BUILDING LIST
  Future<Map<String, dynamic>> _fetchBuildingList(
    int pageNumber, {
    String? value,
    int? projectId,
  }) async {
    try {
      final result = await _buildingRepository.pullBuilding(
        pageNumber: pageNumber,
        pageSize: 15,
        projectId: getProject().projectId,
        queryParams:
            value != null && value.isNotEmpty ? {"BuildingName": value} : null,
      );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final buildings =
              response['data'] as List<RedevelopmentBuildingModel>;
          final itemList =
              buildings
                  .map(
                    (c) => {
                      'zAttributesId': c.buildingId,
                      'DisplayName': c.buildingName,
                    },
                  )
                  .toList();

          return {
            'itemList': itemList,
            'totalNumberOfRecord':
                response['totalNumberOfRecord'] ?? itemList.length,
          };
        },
      );
    } catch (error) {
      return {'itemList': [], 'totalNumberOfRecord': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Redevelopment",
        isMenuButton: true,
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (value) {
          _redevlopmentDashboardCubit.getRedevelopmentDashboardList(
            context,
            getProject().projectId,
          );
        },
        showNotification: true,
      ),
      body: BlocBuilder<RedevlopmentDashboardCubit, RedevlopmentDashboardState>(
        builder: (context, state) {
          if (state.isLoading == true) {
            return Center(child: loader());
          }
          final data = state.redevelopmentDashboardModel;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomMultipleSelectPopup(
                    isMultiSelect: false,
                    initialValue: selectedBuilding,
                    dataList: [],
                    dataFetchCallBack: _fetchBuildingList,
                    onSelected: (selectedValue) {
                      log("the value is:$selectedValue");
                      setState(() {
                        selectedBuilding = selectedValue;
                      });
                    },
                  ),
                  // GENERATE REPORT AND VIEW PROJECT BUTTONS
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.lightBlue,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.generateReportIcon,
                              width: 16,
                              height: 16,
                            ),
                            horizontalSpacing(),
                            Text(
                              "Generate Report",
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(width: 20.0),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: AppColor.green.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: AppColor.green,
                              size: 16,
                            ),
                            horizontalSpacing(),
                            Text(
                              "Project Plan",
                              style: AppTextStyle.ts14M(color: AppColor.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  ListView.builder(
                    itemCount: data!.table0.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, int index) {
                      var abc = data.table0;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: AppColor.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              AppAssets.buildingCountIcon,
                              width: 32,
                              height: 32,
                            ),
                            horizontalSpacing(width: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Building Count",
                                  style: AppTextStyle.ts14M(),
                                ),
                                verticalSpacing(height: 6.0),
                                Text(
                                  "Total Plot Area :${abc[index].totalPlotAreaSqFt} SqMt",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  abc[index].totalRecords.toString(),
                                  style: AppTextStyle.ts20SB(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
