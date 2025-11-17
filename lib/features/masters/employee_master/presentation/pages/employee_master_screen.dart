import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_floating_action_button.dart';
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
          goRouter.pushNamed(AppRoutes.addUpdateEmployeeMobile);
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
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColor.grey30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name & Designation :',
                                style: AppTextStyle.ts12R(color: AppColor.grey),
                              ),
                              verticalSpacing(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${employee.firstName} ${employee.lastName} ',
                                      style: AppTextStyle.ts16R(),
                                    ),
                                    TextSpan(
                                      text: '(${employee.designation})',
                                      style: AppTextStyle.ts14R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              verticalSpacing(height: 10),

                              Text(
                                'Contact Details :',
                                style: AppTextStyle.ts12R(color: AppColor.grey),
                              ),
                              verticalSpacing(height: 2),
                              Text(
                                '${employee.personalMobileNumber} / ${employee.emailId}',
                                style: AppTextStyle.ts14R(),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: AppColor.grey30),
                        ColoredBox(
                          color: AppColor.grey5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 4,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: CustomButton.smallView(
                                  onPressed: () {
                                    goRouter.pushNamed(
                                      AppRoutes.employeeDetailsMobile,
                                      queryParameters: {
                                        'employee': Uri.encodeComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(employee.toJson()),
                                          ),
                                        ),
                                      },
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  goRouter.pushNamed(
                                    AppRoutes.addUpdateEmployeeMobile,
                                    queryParameters: {
                                      'employee': Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(employee.toJson()),
                                        ),
                                      ),

                                      'index': index.toString(),
                                    },
                                  );
                                },
                                child: SvgPicture.asset(
                                  AppAssets.editIcon,
                                  height: 24.0,
                                  width: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () async {
          goRouter.pushNamed(AppRoutes.addUpdateEmployeeMobile);
        },
      ),
    );
  }
}
