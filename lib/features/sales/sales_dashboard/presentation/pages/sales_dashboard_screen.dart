// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/model/sales.dashboard.model.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/charts/custom_radial_chart.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  // PROJECT MODEL
  late ProjectModel _selectedProject;

  // USER MODEL
  late UserModel? _user;
  int _selectedFilterIndex = 0;
  final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier =
      ValueNotifier([]);
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  @override
  void initState() {
    super.initState();
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    getCurrentUser();
    _selectedProject = getProject();
    _salesDashboardCubit.getSalesDashboardList(
      context,
      _selectedProject.projectId,
    );
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    _user = UserModel.fromJson(userJson);
  }

  Future<void> _showMarkAsTimeOutPopup(
    BuildContext context,
    Table0 item,
  ) async {
    final shouldRemove = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are you sure you want to mark Time Out?',
      message: '',
      confirmText: "Time Out",
    );
    if (shouldRemove == true) {
      _salesDashboardCubit.markTimeOutEnquiry(
        context: context,
        enquiryId: item.enquiryId,
        projectId: item.projectId,
      );
    }
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "EmployeeId": _user!.employeeId}
              : {"EmployeeId": _user!.employeeId},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _salesDashboardCubit.getSalesDashboardList(
          context,
          _selectedProject.projectId,
        );
      },
      child: BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
        builder: (context, state) {
          if (state.isLoading!) {
            return Center(child: loader());
          }
          return Scaffold(
            appBar: CustomAppBarWithBackButton(
              screenTitle: "Sales Dashboard",
              isMenuButton: true,
              authorization: AuthorizationModel(),
              onProjectChangeCallback: (value) {
                _selectedProject = value;
                _salesDashboardCubit.getSalesDashboardList(
                  context,
                  _selectedProject.projectId,
                );
              },
              showNotification: true,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _selectedProjectNotifier,
                      builder: (context, value, child) {
                        return CustomMultipleSelectPopup(
                          isMultiSelect: false,
                          hintText: "All Project",
                          initialValue: value,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedProjectNotifier.value = value;
                            _salesDashboardCubit.getSalesDashboardList(
                              context,
                              (_selectedProjectNotifier.value.isNotEmpty)
                                  ? _selectedProjectNotifier
                                      .value
                                      .first['zAttributesId']
                                  : 0,
                            );
                          },
                          dataFetchCallBack: _fetchProjects,
                        );
                      },
                    ),
                    DashboardFilterTabs(
                      selectedIndex: _selectedFilterIndex,
                      onChanged: (index) async {
                        setState(() {
                          _selectedFilterIndex = index;
                        });

                        final filterType = filterTypes[index];

                        if (filterType == "DATEWISE") {
                        } else {
                          await _salesDashboardCubit.applyDashboardFilter(
                            filterType: filterType,
                          );

                          await _salesDashboardCubit.getSalesDashboardList(
                            context,
                            _selectedProject.projectId,
                          );
                        }
                      },
                    ),
                    verticalSpacing(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.totalRevenueIcon,
                                      width: 32,
                                      height: 32,
                                    ),
                                    horizontalSpacing(width: 20.0),
                                    Expanded(
                                      child: Text(
                                        "Total Revenue",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    10.toString(),
                                    style: AppTextStyle.ts20SB(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        horizontalSpacing(width: 16.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.newLeadIcon,
                                      width: 32,
                                      height: 32,
                                    ),
                                    horizontalSpacing(width: 20.0),
                                    Expanded(
                                      child: Text(
                                        "New Lead",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    10.toString(),
                                    style: AppTextStyle.ts20SB(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.overdueIcon,
                                      width: 32,
                                      height: 32,
                                    ),
                                    horizontalSpacing(width: 20.0),
                                    Expanded(
                                      child: Text(
                                        "Overdue",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    10.toString(),
                                    style: AppTextStyle.ts20SB(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        horizontalSpacing(width: 16.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.conversionIcon,
                                      width: 32,
                                      height: 32,
                                    ),
                                    horizontalSpacing(width: 16.0),
                                    Expanded(
                                      child: Text(
                                        "Conversion",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black.withValues(
                                            alpha: 0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    10.toString(),
                                    style: AppTextStyle.ts20SB(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 16.0),
                    _buildSaleAttendanceSummary(context),
                    verticalSpacing(height: 16.0),
                    _buildEnquiriesWidget(context),
                    verticalSpacing(height: 16),
                    _buildActiveFollowUpsWidget(context),
                    verticalSpacing(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaleAttendanceSummary(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table4
                : <Table4>[];
        final presentCount = data.first.presentCount;
        final absentCount = data.first.absentCount;
        final onLeaveCount = data.first.onLeaveCount;

        final totalEmployees = presentCount + absentCount + onLeaveCount;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance Summary",
                style: AppTextStyle.ts14M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              verticalSpacing(height: 16.0),
              if (data != null && data.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CommonRadialChart(
                        items: [
                          RadialChartItem(
                            title: "Present",
                            value: data.first.presentCount,
                            color: AppColor.primary,
                            onValueTap: () async {
                              debugPrint("the present count is");
                              goRouter.pushNamed(
                                AppRoutes.salesAttendanceScreen,
                                queryParameters: {
                                  'title': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "Present Employees",
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                          RadialChartItem(
                            title: "Absent",
                            value: data.first.absentCount,
                            color: Color(0xff7A98A5),
                            onValueTap: () {
                              debugPrint("the absent count is");
                              goRouter.pushNamed(
                                AppRoutes.salesAttendanceScreen,
                                queryParameters: {
                                  'title': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "Absent Employees",
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                          RadialChartItem(
                            title: "On Leave",
                            value: data.first.onLeaveCount,
                            color: AppColor.blueBgColor,
                            onValueTap: () {
                              debugPrint("the on leave count is");
                              goRouter.pushNamed(
                                AppRoutes.salesAttendanceScreen,
                                queryParameters: {
                                  'title': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "On Leave Employees",
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Color(0xffF1F5F9), thickness: 0.8),
                    verticalSpacing(height: 12),
                    _buildTotalEmployeesRow(
                      "Total Employees",
                      totalEmployees.toString(),
                      () {
                        print("thehjwehdbjhbjhfdbhjds");
                      },
                    ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnquiriesWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table0
                : <Table0>[];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enquiries  (Today's)",
                style: AppTextStyle.ts14M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              verticalSpacing(height: 10.0),
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: data.length > 1 ? 0.4.sh : null,
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          List.generate(data.length, (index) {
                            final item = data[index];
                            final isLast = index == data.length - 1;
                            return Container(
                              margin:
                                  !isLast
                                      ? EdgeInsets.only(bottom: 10)
                                      : EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.lightGreyBackground,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Project Name",
                                          item.projectName,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Enquiry Code",
                                          item.systemGeneratedCode,
                                          customWidget: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.systemGeneratedCode,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 2),
                                              InkWell(
                                                onTap: () {
                                                  copy(
                                                    context: context,
                                                    text:
                                                        item.systemGeneratedCode,
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 2,
                                                      ),
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Client Name",
                                          item.name,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Mobile Number",
                                          item.mobileNumber,
                                          customWidget: CustomClickToContactText(
                                            countryCode:
                                                item.mobileNumberCountryCode,
                                            value: item.mobileNumber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Date",
                                          formatDateTimeAsDDMMMYYYY(
                                            item.enquiryDate,
                                          ),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Customer Time-in",
                                          item.enquiryTimeIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _infoColumn(
                                          "Sales Advisor",
                                          item.salesAdvisor,
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: _infoColumn(
                                          "Sourcing Manager",
                                          item.sourcingManager.isEmpty
                                              ? "-"
                                              : item.sourcingManager,
                                        ),
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  CustomButton(
                                    text: "Time Out",
                                    backgroundColor:
                                        item.canTimeOut == 0
                                            ? AppColor.grey2
                                            : AppColor.primary,
                                    onPressed:
                                        item.canTimeOut == 0
                                            ? null
                                            : () {
                                              _showMarkAsTimeOutPopup(
                                                context,
                                                item,
                                              );
                                            },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFollowUpsWidget(BuildContext context) {
    return BlocBuilder<SalesDashboardCubit, SalesDashboardState>(
      builder: (context, state) {
        if (state.isLoading == true) {
          return Center(child: loader());
        }

        final data =
            (state.salesDashboardList.isNotEmpty)
                ? state.salesDashboardList.first.table1
                : <Table1>[];
        return Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 8.0,
          ),
          decoration: commonCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Follow Up",
                style: AppTextStyle.ts14M(
                  color: AppColor.greyTitleAndValueColor.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
              verticalSpacing(height: 10.0),
              if (data.isNotEmpty) ...[
                SizedBox(
                  height: data.length > 1 ? 300 : null,
                  child: ListView.separated(
                    itemCount: data.length,
                    shrinkWrap: true,
                    physics:
                        data.length > 1
                            ? AlwaysScrollableScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, int index) {
                      final activeFollowUps = data[index];
                      final bool isLast = index == data.length - 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: AppColor.lightGreyBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Project Name",
                                    activeFollowUps.projectName,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Enquiry Code",
                                    activeFollowUps.systemGeneratedCode,
                                    customWidget: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            activeFollowUps.systemGeneratedCode,
                                            style: AppTextStyle.ts14M(),
                                          ),
                                        ),
                                        horizontalSpacing(width: 2),
                                        InkWell(
                                          onTap: () {
                                            copy(
                                              context: context,
                                              text:
                                                  activeFollowUps
                                                      .systemGeneratedCode,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Icon(
                                              Icons.copy,
                                              size: 16,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Client Name",
                                    activeFollowUps.name,
                                    customWidget: InkWell(
                                      onTap: () async {
                                        await loadAndSelectProjectById(
                                          activeFollowUps.projectId,
                                        );
                                        goRouter.pushNamed(
                                          AppRoutes.enquiry,
                                          queryParameters: {
                                            "enquiryName":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    activeFollowUps.name,
                                                  ),
                                                ),
                                            "enquiryCode":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    activeFollowUps
                                                        .systemGeneratedCode,
                                                  ),
                                                ),
                                          },
                                        );
                                      },
                                      child: Text(
                                        activeFollowUps.name,
                                        style:
                                            activeFollowUps.isAction == 1
                                                ? AppTextStyle.ts14M().copyWith(
                                                  color: AppColor.primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColor.primary,
                                                )
                                                : AppTextStyle.ts14M(),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Mobile Number",
                                    activeFollowUps.mobileNumber,
                                    customWidget: CustomClickToContactText(
                                      countryCode:
                                          activeFollowUps
                                              .mobileNumberCountryCode,
                                      value: activeFollowUps.mobileNumber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Due Day(s)",
                                    activeFollowUps.nextFollowUpDate
                                            ?.toIso8601String() ??
                                        "-",
                                    customWidget: followUpStatusTextWidget(
                                      activeFollowUps.nextFollowUpDate,
                                    ),
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Next FollowUp Date",
                                    activeFollowUps.nextFollowUpDate == null
                                        ? '-'
                                        : formatDateTimeAsDDMMMYYYY(
                                          activeFollowUps.nextFollowUpDate!,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Sales Advisor",
                                    activeFollowUps.salesAdvisor,
                                  ),
                                ),
                                horizontalSpacing(),
                                Expanded(
                                  child: _infoColumn(
                                    "Sourcing Manager",
                                    activeFollowUps.sourcingManager.isEmpty
                                        ? '-'
                                        : activeFollowUps.sourcingManager,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _infoColumn(
                                    "Created Date",
                                    formatDateTimeAsDDMMMYYYY(
                                      activeFollowUps.createdDate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    "Status",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                  child: Center(
                                    child: Text(
                                      ":",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.black.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpacing(width: 20),
                                Expanded(
                                  child:
                                      activeFollowUps.finalStage.isEmpty
                                          ? Text(
                                            "-",
                                            style: AppTextStyle.ts12M(),
                                          )
                                          : enquiryStatusWidget(
                                            activeFollowUps.finalStage,
                                          ),
                                ),
                                !isLast ? SizedBox.shrink() : SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    "No Data Found",
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoColumn(String title, String value, {Widget? customWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        customWidget ??
            Text(value, style: AppTextStyle.ts14M(color: AppColor.black)),
      ],
    );
  }

  Widget summaryOverallWidget({String? title, String? subTitle, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subTitle!, style: AppTextStyle.ts16SB(color: color)),
        Text(
          title!,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalEmployeesRow(
    String title,
    String value,
    VoidCallback? onValueTaps,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyle.ts14M(color: const Color(0xff64748B)),
            ),
            Text(
              ":",
              style: AppTextStyle.ts14M(color: const Color(0xff64748B)),
            ),
            GestureDetector(
              onTap: onValueTaps,
              child: Text(
                value,
                style: AppTextStyle.ts14SB(color: AppColor.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? titleColor;
  final Color? valueColor;
  final Widget? footer;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  final double borderRadius;
  final Widget? leadingStripe;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.titleColor,
    this.valueColor,
    this.footer,
    this.decoration,
    this.padding = const EdgeInsets.all(12),
    this.trailing,
    this.borderRadius = 16,
    this.leadingStripe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          decoration ??
          BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Row(
        children: [
          if (leadingStripe != null) leadingStripe!,
          Expanded(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyle.ts14M(color: titleColor)),
                  Text(value, style: AppTextStyle.ts20B(color: valueColor)),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SourceProgressBar extends StatelessWidget {
  final String title;
  final num percentage;

  const SourceProgressBar({
    super.key,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.ts16M(
                    color: AppColor.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const DashboardFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Today", "Weekly", "Monthly", "Datewise", "Overall"];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xffEDEDF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffC3C6D5), width: 0.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10.0,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.0,
                  horizontal: 9,
                ),
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style:
                        selected
                            ? AppTextStyle.ts14SB(color: AppColor.white)
                            : AppTextStyle.ts12R(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
