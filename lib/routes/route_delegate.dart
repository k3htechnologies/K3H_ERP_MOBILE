import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/core/presentation/pages/no_authorised_screen.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/add_designation_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/asset_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/asset_mapping_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/pages/add_branch_association_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/pages/branch_association_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/cubit/branch_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/add_branch_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/branch_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/pages/branch_master_view_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/cubit/deduction_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/pages/add_deduction_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/presentation/pages/deduction_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/cubit/earning_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/pages/add_earning_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/presentation/pages/earning_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/cubit/holiday_mapping_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/pages/add_holiday_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/presentation/pages/holiday_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/pages/add_holiday_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/pages/holiday_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/pages/add_leave_encashment_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/pages/leave_encashment_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/cubit/material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/pages/add_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/presentation/pages/material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/cubit/sub_material_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/pages/add_sub_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/presentation/pages/sub_material_master_screen.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/cubit/umo_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/umo_master_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/add_bank_details_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/add_project_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/project_details_screen.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/project_master_screen.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/pages/add_terms_and_conditions_screen.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/pages/terms_and_conditions_screen.dart';
import 'package:k3h_erp_app/features/menu/presentation/pages/menu_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/add_event_details_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_date_detail_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_screen.dart';
import 'package:k3h_erp_app/features/more/events/task/presentation/pages/task_transfer_history_screen.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:k3h_erp_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:k3h_erp_app/features/dashboard/dashboard_screen.dart';
import 'package:k3h_erp_app/features/inventory/presentation/pages/inventory_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/login_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/otp_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/project_list_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/splash_screen.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_document/content_document_cubit.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_folder/content_folder_cubit.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/pages/content_document_screen.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/pages/content_folder_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/add_company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/add_company_partner_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_view.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/view_company_partner_screen.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/add_department_screen.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/department_master_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/designation_screen.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/cubit/bank_list_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/presentation/pages/bank_list_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/cubit/asset_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/add_asset_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/presentation/pages/asset_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/cubit/asset_mapping_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/add_asset_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/presentation/pages/asset_mapping_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/add_employee_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_view_details_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_file/approved_bank_file_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_file_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_folder_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/add_building_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/building_screen.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/pages/building_view_screen.dart';
import 'package:k3h_erp_app/features/test_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor_add/vendor_add_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/add_vendor_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/document_view_company_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/documents_view_vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/view_details_vendor_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:path/path.dart';

String? authenticateAndAuthorizeRoute(GoRouterState state) {
  // SPLASH || LOGIN
  if (state.uri.path == AppRoutes.splashScreen ||
      state.uri.path == AppRoutes.login ||
      state.uri.path == AppRoutes.otp ||
      state.uri.path == AppRoutes.projectList) {
    return null;
  }
  // AUTHENTICATION
  final localStorage = LocalStorageManager();
  final menuData = localStorage.getString(StorageKey.menu);
  final bool isLoggedIn = menuData != null;
  if (!isLoggedIn) {
    return AppRoutes.login;
  }
  // AUTHORIZATION
  AuthorizationModel? routeAuthorizationModel =
      Authorization.routeAuthorizationMap[state.uri.path];
  if (routeAuthorizationModel == null) {
    return null;
  }
  if (!routeAuthorizationModel.isAccess) {
    return AppRoutes.notAuthorized;
  }
  return null;
}

final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splashScreen,
  redirect: (context, state) {
    // Track the current route for menu highlighting
    final currentPath = state.uri.path;
    if (currentPath != AppRoutes.menu && currentPath.isNotEmpty) {
      LocalStorageManager().setString(StorageKey.lastActiveRoute, currentPath);
    }
    return authenticateAndAuthorizeRoute(state);
  },
  routes: [
    // SPLASH SCREEN
    GoRoute(
      path: AppRoutes.splashScreen,
      name: AppRoutes.splashScreen,
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    // NOT AUTHORIZED
    GoRoute(
      path: AppRoutes.notAuthorized,
      name: AppRoutes.notAuthorized,
      builder: (context, state) {
        return const NotAuthorizedScreen();
      },
    ),
    // LOGIN
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) {
        return const LoginScreen();
        // return const TestScreen();
      },
    ),
    // OTP SCREEN
    GoRoute(
      path: AppRoutes.otp,
      name: AppRoutes.otp,
      builder: (context, state) {
        final queryParameterMobileNumber =
            state.uri.queryParameters['mobileNumber'];
        if (queryParameterMobileNumber != null) {
          final mobileNumber = EncryptionManager.decryptData(
            Uri.decodeComponent(queryParameterMobileNumber),
          );
          return OTPMobileScreen(mobileNumber: mobileNumber);
        }
        return Scaffold();
      },
    ),
    // PROJECT LIST SCREEN
    GoRoute(
      path: AppRoutes.projectList,
      name: AppRoutes.projectList,
      pageBuilder: (context, state) {
        final queryParameter = state.uri.queryParameters['projects'];
        if (queryParameter == null) {
          // NAVIGATE TO DEFAULT SCREEN
          return MaterialPage(child: Scaffold());
        }

        final List<dynamic> projects = jsonDecode(
          EncryptionManager.decryptData(Uri.decodeComponent(queryParameter)),
        );

        return MaterialPage(
          child: ProjectListScreen(
            projectList: List.from(
              projects.map((e) => ProjectModel.fromJson(e)),
            ),
          ),
        );
      },
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return BlocProvider(
          create: (context) => MainScreenCubit(),
          child: MainScreen(child: child),
        );
      },
      routes: [
        // DASHBOARD
        GoRoute(
          path: AppRoutes.dashboardScreen,
          name: AppRoutes.dashboardScreen,
          builder: (context, state) {
            return const DashboardScreen();
          },
        ),
        // COMPANY MASTER
        GoRoute(
          name: AppRoutes.companyMaster,
          path: AppRoutes.companyMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => CompanyMasterCubit(),
              child: CompanyMasterScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addCompany,
              path: AppRoutes.addCompany,
              builder: (context, state) {
                final queryParameterCompany =
                    state.uri.queryParameters['company'];
                final CompanyModel? companyModel =
                    queryParameterCompany != null
                        ? CompanyModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeQueryComponent(queryParameterCompany),
                            ),
                          ),
                        )
                        : null;
                return BlocProvider(
                  create: (context) => CompanyMasterAddCubit(),
                  child: AddCompanyMasterScreen(company: companyModel),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addCompanyPartner,
              path: AppRoutes.addCompanyPartner,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                final partner = extra['partner'] as CompanyPartnerModel?;
                final index = extra['index'] as int?;
                final cubit = extra['cubit'] as CompanyMasterAddCubit?;
                return BlocProvider.value(
                  value: cubit ?? context.read<CompanyMasterAddCubit>(),
                  child: AddCompanyPartnerScreen(
                    companyPartner: partner,
                    index: index,
                  ),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyDetails,
              path: AppRoutes.viewCompanyDetails,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['company'];
                if (queryParameterVendor != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterVendor),
                    ),
                  );
                  final companyModel = CompanyModel.fromJson(decodedJson);
                  return CompanyMasterViewScreen(company: companyModel);
                } else {
                  return Scaffold();
                }
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyDocument,
              path: AppRoutes.viewVendorDocument,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['company'];
                if (queryParameterVendor != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterVendor),
                    ),
                  );
                  final companyModel = CompanyModel.fromJson(decodedJson);
                  return DocumentsViewCompanyScreen(companyModel: companyModel);
                } else {
                  return Scaffold();
                }
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyPartner,
              path: AppRoutes.viewCompanyPartner,
              builder: (context, state) {
                final queryParameterCompany =
                    state.uri.queryParameters['company'];
                if (queryParameterCompany != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(queryParameterCompany),
                    ),
                  );
                  final companyModel = CompanyModel.fromJson(decodedJson);
                  return ViewCompanyPartnerScreen(company: companyModel);
                }
                return Scaffold();
              },
            ),
          ],
        ),
        // DEPARTMENT MASTER
        GoRoute(
          name: AppRoutes.departmentMaster,
          path: AppRoutes.departmentMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => DepartmentMasterCubit(),
              child: DepartmentMasterScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addDepartment,
              path: AppRoutes.addDepartment,
              builder: (context, state) {
                final queryParameterDepartment =
                    state.uri.queryParameters['department'];
                final DepartmentModel? department =
                    queryParameterDepartment != null
                        ? DepartmentModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDepartment),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return BlocProvider(
                  create: (context) => DepartmentMasterCubit(),
                  child: AddDepartmentScreen(
                    department: department,
                    index: index,
                  ),
                );
              },
            ),
          ],
        ),
        // DESIGNATION MASTER
        GoRoute(
          name: AppRoutes.designationMaster,
          path: AppRoutes.designationMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => DesignationMasterCubit(),
              child: DesignationMasterScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addDesignation,
              path: AppRoutes.addDesignation,
              builder: (context, state) {
                final queryParameterDesignation =
                    state.uri.queryParameters['designation'];
                final DesignationMasterModel? designation =
                    queryParameterDesignation != null
                        ? DesignationMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterDesignation),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return BlocProvider(
                  create: (context) => DesignationMasterCubit(),
                  child: AddDesignationScreen(
                    designationMasterModel: designation,
                    index: index,
                  ),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              path: AppRoutes.employeeModuleAccess,
              name: AppRoutes.employeeModuleAccess,
              builder: (context, state) {
                final queryParameter = state.uri.queryParameters['designation'];
                if (queryParameter == null) {
                  return TestScreen();
                }
                final designationJson = jsonDecode(
                  EncryptionManager.decryptData(
                    Uri.decodeComponent(queryParameter),
                  ),
                );
                final designation = DesignationMasterModel.fromJson(
                  designationJson,
                );
                return BlocProvider(
                  create: (context) => DesignationMasterCubit(),
                  child: ModuleAccessScreen(designation: designation),
                );
              },
            ),
          ],
        ),
        // BANK LIST MASTER
        GoRoute(
          name: AppRoutes.bankListMaster,
          path: AppRoutes.bankListMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => BankListMasterCubit(),
              child: BankListScreen(),
            );
          },
        ),
        // TERMS AND CONDITIONS MASTER
        GoRoute(
          name: AppRoutes.termsAndConditions,
          path: AppRoutes.termsAndConditions,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => TermsAndConditionsCubit(),
              child: TermsAndConditionsScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.addTermsAndConditions,
          path: AppRoutes.addTermsAndConditions,
          builder: (context, state) {
            final queryParameterTnc =
                state.uri.queryParameters['termsAndCondition'];
            final TermsAndConditionsModel? termsAndCondition =
                queryParameterTnc != null
                    ? TermsAndConditionsModel.fromJson(
                      jsonDecode(
                        EncryptionManager.decryptData(
                          Uri.decodeComponent(queryParameterTnc),
                        ),
                      ),
                    )
                    : null;
            final index =
                int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
            final tabIndex =
                int.tryParse(state.uri.queryParameters['tabIndex'] ?? '0') ?? 0;
            // Use BlocProvider.value with service locator to get the singleton instance
            return BlocProvider.value(
              value: serviceLocator<TermsAndConditionsCubit>(),
              child: AddTermsAndConditionsScreen(
                termsAndConditions: termsAndCondition,
                index: index,
                tabIndex: tabIndex,
              ),
            );
          },
        ),
        // ASSET MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<AssetMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.assetMaster,
              path: AppRoutes.assetMaster,
              builder: (context, state) {
                return const AssetMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addAssetMaster,
              path: AppRoutes.addAssetMaster,
              builder: (context, state) {
                final queryParameterAsset = state.uri.queryParameters['asset'];

                final AssetMasterModel? asset =
                    queryParameterAsset != null
                        ? AssetMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAsset),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddAssetMasterScreen(asset: asset, index: index);
              },
            ),
            GoRoute(
              name: AppRoutes.viewAssetMaster,
              path: AppRoutes.viewAssetMaster,
              builder: (context, state) {
                final queryParameterAsset = state.uri.queryParameters['asset'];

                final AssetMasterModel? assetMaster =
                    queryParameterAsset != null
                        ? AssetMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAsset),
                            ),
                          ),
                        )
                        : null;
                return AssetMasterViewScreen(assetMaster: assetMaster!);
              },
            ),
          ],
        ),
        // ASSET MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<AssetMappingMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.assetMappingMaster,
              path: AppRoutes.assetMappingMaster,
              builder: (context, state) {
                return const AssetMappingMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addAssetMappingMaster,
              path: AppRoutes.addAssetMappingMaster,
              builder: (context, state) {
                final queryParameterAssetMapping =
                    state.uri.queryParameters['assetMapping'];

                final AssetMappingModel? assetMapping =
                    queryParameterAssetMapping != null
                        ? AssetMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAssetMapping),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddAssetMappingMasterScreen(
                  assetMapping: assetMapping,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewAssetMappingMaster,
              path: AppRoutes.viewAssetMappingMaster,
              builder: (context, state) {
                final queryParameterAssetMapping =
                    state.uri.queryParameters['assetMapping'];
                final AssetMappingModel? assetMapping =
                    queryParameterAssetMapping != null
                        ? AssetMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterAssetMapping),
                            ),
                          ),
                        )
                        : null;
                return AssetMappingMasterViewScreen(
                  assetMapping: assetMapping!,
                );
              },
            ),
          ],
        ),
        // BRANCH MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<BranchMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.branchMaster,
              path: AppRoutes.branchMaster,
              builder: (context, state) {
                return const BranchMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addBranchMaster,
              path: AppRoutes.addBranchMaster,
              builder: (context, state) {
                final queryParameterBranchMaster =
                    state.uri.queryParameters['branchMaster'];

                final BranchMasterModel? branchMaster =
                    queryParameterBranchMaster != null
                        ? BranchMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBranchMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddBranchMasterScreen(
                  branch: branchMaster,
                  index: index,
                );
              },
            ),
            GoRoute(
              name: AppRoutes.viewBranchMaster,
              path: AppRoutes.viewBranchMaster,
              builder: (context, state) {
                final queryParameterBranchMaster =
                    state.uri.queryParameters['branchMaster'];
                final BranchMasterModel? branchMaster =
                    queryParameterBranchMaster != null
                        ? BranchMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBranchMaster),
                            ),
                          ),
                        )
                        : null;
                return BranchMasterViewScreen(branch: branchMaster!);
              },
            ),
          ],
        ),
        // BRANCH ASSOCIATION MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<BranchAssociationMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.branchAssociation,
              path: AppRoutes.branchAssociation,
              builder: (context, state) {
                return const BranchAssociationMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addBranchAssociation,
              path: AppRoutes.addBranchAssociation,
              builder: (context, state) {
                final queryParameterBranchAssociationMaster =
                    state.uri.queryParameters['branchAssociation'];

                final BranchAssociationModel? branchAssociation =
                    queryParameterBranchAssociationMaster != null
                        ? BranchAssociationModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterBranchAssociationMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddBranchAssociationMasterScreen(
                  branchAssociation: branchAssociation,
                  index: index,
                );
              },
            ),
          ],
        ),
        // DEDUCTION MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<DeductionMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.deductionMaster,
              path: AppRoutes.deductionMaster,
              builder: (context, state) {
                return const DeductionMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addDeductionMaster,
              path: AppRoutes.addDeductionMaster,
              builder: (context, state) {
                final queryParameterDeductionMaster =
                    state.uri.queryParameters['deduction'];

                final DeductionMasterModel? deduction =
                    queryParameterDeductionMaster != null
                        ? DeductionMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterDeductionMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddDeductionMasterScreen(
                  deductionMasterModel: deduction,
                  index: index,
                );
              },
            ),
          ],
        ),
        // EARNING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<EarningMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.earningMaster,
              path: AppRoutes.earningMaster,
              builder: (context, state) {
                return const EarningMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addEarningMaster,
              path: AppRoutes.addEarningMaster,
              builder: (context, state) {
                final queryParameterEarningMaster =
                    state.uri.queryParameters['earning'];

                final EarningMasterModel? earning =
                    queryParameterEarningMaster != null
                        ? EarningMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterEarningMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddEarningMasterScreen(
                  earningMasterModel: earning,
                  index: index,
                );
              },
            ),
          ],
        ),
        // HOLIDAY MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<HolidayMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.holidayMaster,
              path: AppRoutes.holidayMaster,
              builder: (context, state) {
                return const HolidayMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addHolidayMaster,
              path: AppRoutes.addHolidayMaster,
              builder: (context, state) {
                final queryParameterHolidayMaster =
                    state.uri.queryParameters['holiday'];

                final HolidayMasterModel? holiday =
                    queryParameterHolidayMaster != null
                        ? HolidayMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterHolidayMaster),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddHolidayMasterScreen(
                  holidayMaster: holiday,
                  index: index,
                );
              },
            ),
          ],
        ),
        // HOLIDAY MAPPING MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<HolidayMappingMasterCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.holidayMappingMaster,
              path: AppRoutes.holidayMappingMaster,
              builder: (context, state) {
                return const HolidayMappingMasterScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addHolidayMappingMaster,
              path: AppRoutes.addHolidayMappingMaster,
              builder: (context, state) {
                final queryParameterHolidayMappingMaster =
                    state.uri.queryParameters['holidayMapping'];

                final HolidayMappingModel? holidayMapping =
                    queryParameterHolidayMappingMaster != null
                        ? HolidayMappingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterHolidayMappingMaster,
                              ),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddHolidayMappingMasterScreen(
                  holidayMapping: holidayMapping,
                  index: index,
                );
              },
            ),
          ],
        ),
        //LEAVE ENCASHMENT MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => LeaveEncashmentMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.leaveEncashmentMaster,
              name: AppRoutes.leaveEncashmentMaster,
              builder: (context, state) {
                return const LeaveEncashmentScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addLeaveEncashmentMaster,
              name: AppRoutes.addLeaveEncashmentMaster,
              builder: (context, state) {
                final queryParameterLeaveEncashment =
                    state.uri.queryParameters['leaveEncashment'];
                final LeaveEncashmentMasterModel? leaveEncashmentMasterModel =
                    queryParameterLeaveEncashment != null
                        ? LeaveEncashmentMasterModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(
                                queryParameterLeaveEncashment,
                              ),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddLeaveEncashmentMasterScreen(
                  leaveEncashmentMasterModel: leaveEncashmentMasterModel,
                  index: index,
                );
              },
            ),
          ],
        ),
        // EMPLOYEE MASTER
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => EmployeeMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.employeeMaster,
              name: AppRoutes.employeeMaster,
              builder: (context, state) {
                return const EmployeeMasterScreen();
              },
              routes: [
                GoRoute(
                  path: AppRoutes.addUpdateEmployee,
                  name: AppRoutes.addUpdateEmployee,
                  builder: (context, state) {
                    final employee = state.uri.queryParameters['employee'];
                    final index =
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0;

                    return AddEmployeeScreen(
                      employee:
                          employee != null
                              ? UserModel.fromJson(
                                jsonDecode(
                                  EncryptionManager.decryptData(
                                    Uri.decodeComponent(employee),
                                  ),
                                ),
                              )
                              : null,
                      index: index,
                    );
                  },
                ),
                GoRoute(
                  path: AppRoutes.employeeViewDetails,
                  name: AppRoutes.employeeViewDetails,
                  builder: (context, state) {
                    final employee = state.uri.queryParameters['employee'];

                    return EmployeeMasterViewDetailsScreen(
                      employee: UserModel.fromJson(
                        jsonDecode(
                          EncryptionManager.decryptData(
                            Uri.decodeComponent(employee!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // PROJECT MANAGEMENT
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => ProjectMasterCubit(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.projectMaster,
              name: AppRoutes.projectMaster,
              builder: (context, state) {
                return ProjectMasterScreen();
              },
            ),
            GoRoute(
              path: AppRoutes.addProjectMaster,
              name: AppRoutes.addProjectMaster,
              builder: (context, state) {
                final queryParameterProject =
                    state.uri.queryParameters['project'];
                final ProjectModel? project =
                    queryParameterProject != null
                        ? ProjectModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterProject),
                            ),
                          ),
                        )
                        : null;
                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
                return AddProjectScreen(project: project, index: index);
              },
            ),
            GoRoute(
              path: AppRoutes.projectDetails,
              name: AppRoutes.projectDetails,
              builder: (context, state) {
                final queryParameterProject =
                    state.uri.queryParameters['project'];
                final ProjectModel? project =
                    queryParameterProject != null
                        ? ProjectModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterProject),
                            ),
                          ),
                        )
                        : null;
                return ProjectDetailsScreen(project: project!);
              },
              routes: [
                GoRoute(
                  name: AppRoutes.addBankDetails,
                  path: AppRoutes.addBankDetails,
                  builder: (context, state) {
                    final queryParameterProject =
                        state.uri.queryParameters['project'];
                    final ProjectModel? project =
                        queryParameterProject != null
                            ? ProjectModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterProject),
                                ),
                              ),
                            )
                            : null;
                    final queryParameterBank =
                        state.uri.queryParameters['bank'];
                    final BankDetailsModel? bankDetailsModel =
                        queryParameterBank != null
                            ? BankDetailsModel.fromJson(
                              jsonDecode(
                                EncryptionManager.decryptData(
                                  Uri.decodeComponent(queryParameterBank),
                                ),
                              ),
                            )
                            : null;
                    return AddBankDetailsScreen(
                      bankDetailsModel: bankDetailsModel,
                      project: project!,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // MATERIAL MASTER
        GoRoute(
          name: AppRoutes.materialMaster,
          path: AppRoutes.materialMaster,
          builder: (context, state) {
            return BlocProvider.value(
              value: serviceLocator<MaterialMasterCubit>(),
              child: MaterialMasterScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.addMaterialMaster,
          path: AppRoutes.addMaterialMaster,
          builder: (context, state) {
            final queryParameterMaterial =
                state.uri.queryParameters['material'];
            final MaterialMasterModel? material =
                queryParameterMaterial != null
                    ? MaterialMasterModel.fromJson(
                      jsonDecode(
                        EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(queryParameterMaterial),
                        ),
                      ),
                    )
                    : null;
            final index =
                int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
            // Use BlocProvider.value with service locator to get the singleton instance
            return BlocProvider.value(
              value: serviceLocator<MaterialMasterCubit>(),
              child: AddMaterialMasterScreen(material: material, index: index),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.uomMaster,
          path: AppRoutes.uomMaster,
          builder: (context, state) {
            return BlocProvider.value(
              value: serviceLocator<UOMMasterCubit>(),
              child: UOMMasterScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.subMaterialMaster,
          path: AppRoutes.subMaterialMaster,
          builder: (context, state) {
            return BlocProvider.value(
              value: serviceLocator<SubMaterialMasterCubit>(),
              child: SubMaterialMasterScreen(),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.addSubMaterialMaster,
          path: AppRoutes.addSubMaterialMaster,
          builder: (context, state) {
            final queryParameterSubMaterial =
                state.uri.queryParameters['subMaterial'];
            final SubMaterialMasterModel? subMaterial =
                queryParameterSubMaterial != null
                    ? SubMaterialMasterModel.fromJson(
                      jsonDecode(
                        EncryptionManager.decryptData(
                          Uri.decodeQueryComponent(queryParameterSubMaterial),
                        ),
                      ),
                    )
                    : null;
            final index =
                int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
            return BlocProvider.value(
              value: serviceLocator<SubMaterialMasterCubit>(),
              child: AddSubMaterialMasterScreen(
                subMaterial: subMaterial,
                index: index,
              ),
            );
          },
        ),
        // BUILDING
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (_) => serviceLocator<BuildingCubit>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              name: AppRoutes.building,
              path: AppRoutes.building,
              builder: (context, state) {
                return const BuildingScreen();
              },
            ),
            GoRoute(
              name: AppRoutes.addBuilding,
              path: AppRoutes.addBuilding,
              builder: (context, state) {
                final queryParameterBuilding =
                    state.uri.queryParameters['building'];

                final RedevelopmentBuildingModel? building =
                    queryParameterBuilding != null
                        ? RedevelopmentBuildingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBuilding),
                            ),
                          ),
                        )
                        : null;

                final index =
                    int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;

                return AddBuildingScreen(building: building, index: index);
              },
            ),
            GoRoute(
              name: AppRoutes.viewBuilding,
              path: AppRoutes.viewBuilding,
              builder: (context, state) {
                final queryParameterBuilding =
                    state.uri.queryParameters['building'];

                final RedevelopmentBuildingModel? building =
                    queryParameterBuilding != null
                        ? RedevelopmentBuildingModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterBuilding),
                            ),
                          ),
                        )
                        : null;

                return BuildingViewScreen(building: building!);
              },
            ),
          ],
        ),
        // CALENDAR
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(create: (_) => CalendarCubit(), child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.calendar,
              name: AppRoutes.calendar,
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: AppRoutes.addDetailsCalendar,
              name: AppRoutes.addDetailsCalendar,
              builder: (context, state) => AddEventDetailsScreen(),
            ),
            GoRoute(
              path: AppRoutes.calendarDetail,
              name: AppRoutes.calendarDetail,
              builder: (context, state) {
                final payload = state.uri.queryParameters['data'];
                if (payload == null || payload.isEmpty) {
                  return CalendarDateDetailScreen(
                    date: DateTime.now(),
                    events: const [],
                  );
                }

                try {
                  final decrypted = EncryptionManager.decryptData(
                    Uri.decodeComponent(payload),
                  );
                  final data = jsonDecode(decrypted) as Map<String, dynamic>;
                  final dateString = data['date'] as String? ?? '';
                  final date = DateTime.tryParse(dateString) ?? DateTime.now();

                  final eventsJson = (data['events'] as List<dynamic>? ?? []);
                  final events = <CalendarEventModel>[];

                  for (var e in eventsJson) {
                    try {
                      final event = CalendarEventModel.fromJson(
                        Map<String, dynamic>.from(e as Map),
                      );
                      events.add(event);
                    } catch (error) {
                      log(error.toString());
                    }
                  }

                  return CalendarDateDetailScreen(date: date, events: events);
                } catch (error) {
                  return CalendarDateDetailScreen(
                    date: DateTime.now(),
                    events: const [],
                  );
                }
              },
            ),
          ],
        ),
        // TASK TRANSFER
        GoRoute(
          path: AppRoutes.taskTransferHistory,
          name: AppRoutes.taskTransferHistory,
          builder: (context, state) {
            return TaskTransferHistoryScreen();
          },
        ),
        // MENU
        GoRoute(
          path: AppRoutes.menu,
          name: AppRoutes.menu,
          builder: (context, state) {
            return const MenuScreen();
          },
        ),
        // PROFILE
        GoRoute(
          path: AppRoutes.profile,
          name: AppRoutes.profile,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => ProfileCubit(),
              child: ProfileScreen(),
            );
          },
        ),
        // MARKETING CONTENT DOCUMENT
        GoRoute(
          path: AppRoutes.content,
          name: AppRoutes.content,
          builder: (context, state) {
            return BlocProvider(
              create: (_) => ContentFolderCubit(),
              child: ContentFolderScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.contentDocument,
              path: AppRoutes.contentDocument,
              builder: (context, state) {
                final queryParameterMarketingContentFolderId =
                    state.uri.queryParameters['marketingContentFolderId'];

                if (queryParameterMarketingContentFolderId != null) {
                  final decodedJson = jsonDecode(
                    EncryptionManager.decryptData(
                      Uri.decodeQueryComponent(
                        queryParameterMarketingContentFolderId,
                      ),
                    ),
                  );

                  return BlocProvider(
                    create: (_) => ContentDocumentCubit(),
                    child: ContentDocumentScreen(
                      marketingContentFolderId: decodedJson,
                    ),
                  );
                }
                return TestScreen();
              },
            ),
          ],
        ),
        // PROJECT MANAGEMENT APPROVED BANK
        GoRoute(
          path: AppRoutes.approvedBank,
          name: AppRoutes.approvedBank,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => ApprovedBankFolderCubit(),
              child: ApprovedBankFolderMobileScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.approvedBankFile,
              path: AppRoutes.approvedBankFile,
              builder: (context, state) {
                final queryParameter =
                    state.uri.queryParameters['approvedBankFolderId'];
                if (queryParameter == null) {
                  return TestScreen();
                }

                final decodedJsonApprovedBankFolderId = jsonDecode(
                  EncryptionManager.decryptData(
                    Uri.decodeQueryComponent(queryParameter),
                  ),
                );
                return BlocProvider(
                  create: (context) => ApprovedBankFileCubit(),
                  child: ApprovedBankFieScreen(
                    approvedBankFolderId: decodedJsonApprovedBankFolderId,
                  ),
                );
              },
            ),
          ],
        ),
        // VENDOR
        GoRoute(
          path: AppRoutes.vendor,
          name: AppRoutes.vendor,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => VendorCubit(),
              child: VendorScreen(),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.addVendor,
              path: AppRoutes.addVendor,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];
                final VendorModel? vendor =
                    queryParameterVendor != null
                        ? VendorModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterVendor),
                            ),
                          ),
                        )
                        : null;
                return BlocProvider(
                  create: (context) => VendorAddCubit(),
                  child: AddVendorScreen(vendor: vendor),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.viewVendorDetails,
              name: AppRoutes.viewVendorDetails,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];
                final VendorModel? vendor =
                    queryParameterVendor != null
                        ? VendorModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterVendor),
                            ),
                          ),
                        )
                        : null;
                return ViewDetailsVendorScreen(vendor: vendor!);
              },
            ),
            GoRoute(
              path: AppRoutes.viewVendorDocument,
              name: AppRoutes.viewVendorDocument,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['vendor'];
                final VendorModel? vendor =
                    queryParameterVendor != null
                        ? VendorModel.fromJson(
                          jsonDecode(
                            EncryptionManager.decryptData(
                              Uri.decodeComponent(queryParameterVendor),
                            ),
                          ),
                        )
                        : null;
                return DocumentsViewVendorScreen(vendorModel: vendor!);
              },
            ),
          ],
        ),
        // INVENTORY
        GoRoute(
          path: AppRoutes.inventory,
          name: AppRoutes.inventory,
          builder: (context, state) {
            return InventoryScreen();
          },
        ),
      ],
    ),
  ],
);
