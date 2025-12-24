import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeMasterScreen extends StatefulWidget {
  const EmployeeMasterScreen({super.key});

  @override
  State<EmployeeMasterScreen> createState() =>
      _EmployeeMasterMobileScreenState();
}

class _EmployeeMasterMobileScreenState extends State<EmployeeMasterScreen> {
  // CUBIT
  late EmployeeMasterCubit _employeeMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController _scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _employeeMasterCubit = BlocProvider.of<EmployeeMasterCubit>(context);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.employeeMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _employeeMasterCubit.getEmployeeMasterList(context, 1, 10);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_employeeMasterCubit.state.isLoading! &&
          _employeeMasterCubit.state.employeeMasterList.length <
              _employeeMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _employeeMasterCubit.getEmployeeMasterList(
            context,
            _employeeMasterCubit.state.currentPage + 1,
            10,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSearchSubmit: (value) {
          _employeeMasterCubit.searchEmployee(context, value);
        },
        textController: _searchC,
        screenTitle: 'Employee',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _employeeMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addUpdateEmployee);
        },
        onSortOptionCallback: (value) async {
          _employeeMasterCubit.sortEmployee(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Full Name", "Department"],
        initialSortType: "Created Date",
      ),
      body: SafeArea(
        child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.employeeMasterList.isEmpty) {
              return Center(child: loader());
            }
            if (state.employeeMasterList.isEmpty) {
              return Center(child: noDataWidget());
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              controller: _scrollController,
              itemCount: state.employeeMasterList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.employeeMasterList.length) {
                  return state.employeeMasterList.length <
                          state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var employee = state.employeeMasterList[index];
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 10),
                  clipBehavior: Clip.hardEdge,
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.employeeViewDetails,
                                  queryParameters: {
                                    "employee": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(employee),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: AppColor.primary
                                        )
                                    )
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        employee.fullName,
                                        style: AppTextStyle.ts16M(
                                          color: AppColor.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              CustomIconButton(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addUpdateEmployee,
                                    queryParameters: {
                                      "employee": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(employee),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                  debugPrint('Returned from Add/Update screen');
                                  if (context.mounted) {
                                    _employeeMasterCubit.getEmployeeMasterList(
                                      context,
                                      1,
                                      10,
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColor.grey,
                                ),
                                backgroundColor: AppColor.lightGrey,
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      Row(
                        children: [
                          // TITLE
                          SizedBox(
                            width: 130,
                            child: Text("Employee Code", style: AppTextStyle.ts14R(color: AppColor.grey)),
                          ),

                          // COLON
                          SizedBox(
                            width: 20,
                            child: Text(
                              ":",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColor.grey),
                            ),
                          ),

                          // VALUE
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.purple.withValues(alpha: .15),
                              ),
                              child: Text(
                                employee.employeeCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.ts14R(color: AppColor.purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpacing(),
                      _buildRowTitleVale(
                        title: "Designation",
                        value: employee.designation,
                      ),
                      _buildRowTitleVale(
                        title: "Department",
                        value: employee.department,
                      ),
                      _buildRowTitleVale(
                        title: "Contact Number",
                        value: employee.personalMobileNumber,
                      ),
                      _buildRowTitleVale(
                        title: "Reporting Person",
                        value: employee.reportPersonName,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      )
    );
  }

  Widget _buildRowTitleVale({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // TITLE
          SizedBox(
            width: 130,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }

}
