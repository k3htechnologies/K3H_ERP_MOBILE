import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DepartmentMasterScreen extends StatefulWidget {
  const DepartmentMasterScreen({super.key});

  @override
  State<DepartmentMasterScreen> createState() =>
      _DepartmentMasterMobileScreenState();
}

class _DepartmentMasterMobileScreenState extends State<DepartmentMasterScreen> {
  // CUBIT
  late DepartmentMasterCubit _departmentMasterCubit;

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
    _departmentMasterCubit = context.read<DepartmentMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.departmentMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _departmentMasterCubit.getDepartmentList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
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
          !_departmentMasterCubit.state.isLoading! &&
          _departmentMasterCubit.state.departmentList.length <
              _departmentMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _departmentMasterCubit.getDepartmentList(
            context,
            _departmentMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE DEPARTMENT ---->
  Future<void> _showPopupToDeleteDepartmentMaster(
    BuildContext context,
    DepartmentModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a department?',
      'Deleting this department will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _departmentMasterCubit.deleteDepartmentMaster(
        context: context,
        departmentMasterId: obj.departmentMasterId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        pageSize: 10,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Department',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _departmentMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addDepartment);
          // Refresh list when returning from add screen
          if (context.mounted) {
            _departmentMasterCubit.getDepartmentList(context, 1);
          }
        },
        onSearchSubmit: (value) {
          _departmentMasterCubit.searchDepartment(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _departmentMasterCubit.sortDepartment(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Department Name", "Modified Date"],
        initialSortType: "Created Date",
      ),
      body: BlocBuilder<DepartmentMasterCubit, DepartmentMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.departmentList.isEmpty) {
            return Center(child: loader());
          }
          if (state.departmentList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _departmentMasterCubit.state.departmentList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.departmentList.length) {
                return state.departmentList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var department = state.departmentList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            department.departmentName,
                            style: AppTextStyle.ts14R(),
                          ),
                        ),
                        horizontalSpacing(),
                        Row(
                          children: [
                            CustomIconButton(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addDepartment,
                                  queryParameters: {
                                    'department': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(department.toJson()),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColor.grey,
                              ),
                              backgroundColor: AppColor.grey10,
                            ),
                            horizontalSpacing(),
                            CustomIconButton(
                              onPressed: () {
                                _showPopupToDeleteDepartmentMaster(
                                  context,
                                  department,
                                  state.currentPage,
                                  index,
                                );
                              },
                              icon: SvgPicture.asset(
                                AppAssets.deleteIcon2,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColor.error,
                                  BlendMode.srcIn,
                                ),
                              ),
                              backgroundColor: AppColor.lightRed,
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.grey10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Code: ",
                            style: AppTextStyle.ts12R(color: AppColor.grey),
                          ),
                          Text(
                            department.departmentCode,
                            style: AppTextStyle.ts14R(),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: AppColor.primary.withValues(alpha: .5),
                      thickness: .5,
                      height: 25,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Employee Count: ",
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColor.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                department.numberOfEmployee.toString(),
                                style: AppTextStyle.ts14R(
                                  color: AppColor.purple,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
