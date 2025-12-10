import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/core/presentation/pages/no_authorised_screen.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:k3h_erp_app/features/calendar/presentation/pages/calendar_date_detail_screen.dart';
import 'package:k3h_erp_app/features/calendar/data/models/calendar_event.dart'
    as calendar_models;
import 'package:k3h_erp_app/features/dashboard/dashboard_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/otp_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/project_list_screen.dart';
import 'package:k3h_erp_app/features/login/presentation/pages/splash_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/add_company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/company_master_view.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/pages/department_master_screen.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/designation_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_form.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_view_details_screen.dart';
import 'package:k3h_erp_app/features/test_screen.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';

String? authenticateAndAuthorizeRoute(GoRouterState state) {
  // SPLASH || LOGIN
  if (state.uri.path == AppRoutes.splashScreen ||
      state.uri.path == AppRoutes.login ||
      state.uri.path == AppRoutes.otp ||
      state.uri.path == AppRoutes.projectList) {
    return null;
  }
  // AUTHENTICATION
  // final localStorage = LocalStorageManager();
  // final menuData = localStorage.getString(StorageKey.menu);
  // final bool isLoggedIn = menuData != null;
  // if (!isLoggedIn) {
  //   return AppRoutes.login;
  // }
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
        // return const LoginScreen();
        return const TestScreen();
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
                final CompanyModel? company = state.extra as CompanyModel?;
                return BlocProvider(
                  create: (context) => CompanyMasterAddCubit(),
                  child: AddCompanyMasterScreen(company: company),
                );
              },
            ),
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: AppRoutes.viewCompanyMobile,
              path: AppRoutes.viewCompanyMobile,
              builder: (context, state) {
                final queryParameterVendor =
                    state.uri.queryParameters['company_master'];
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
        ),
        // DEPARTMENT MASTER
        GoRoute(
          name: AppRoutes.designationMaster,
          path: AppRoutes.designationMaster,
          builder: (context, state) {
            return BlocProvider(
              create: (context) => DesignationMasterCubit(),
              child: DesignationMasterScreen(),
            );
          },
        ),
        // EMPLOYEE MASTER
        GoRoute(
          path: AppRoutes.employeeMaster,
          name: AppRoutes.employeeMaster,
          routes: [
            GoRoute(
              path: AppRoutes.addUpdateEmployeeMobile,
              name: AppRoutes.addUpdateEmployeeMobile,
              builder: (context, state) {
                final employee = state.uri.queryParameters['employee'];
                return BlocProvider(
                  create: (context) => EmployeeMasterCubit(),
                  child: EmployeeMasterFormScreen(
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
                    index:
                        int.tryParse(
                          state.uri.queryParameters['index'] ?? '',
                        ) ??
                        0,
                  ),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.employeeDetailsMobile,
              name: AppRoutes.employeeDetailsMobile,
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
          builder: (context, state) {
            return BlocProvider(
              create: (context) => EmployeeMasterCubit(),
              child: EmployeeMasterScreen(),
            );
          },
        ),
        // CALENDAR
        GoRoute(
          path: AppRoutes.calendar,
          name: AppRoutes.calendar,
          builder: (context, state) {
            return CalendarScreen();
          },
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
              final decrypted =
                  EncryptionManager.decryptData(Uri.decodeComponent(payload));
              final data = jsonDecode(decrypted) as Map<String, dynamic>;
              final dateString = data['date'] as String? ?? '';
              final date = DateTime.tryParse(dateString) ?? DateTime.now();

              final eventsJson = (data['events'] as List<dynamic>? ?? []);
              final events = eventsJson
                  .map(
                    (e) => calendar_models.CalendarEvent.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .toList();

              return CalendarDateDetailScreen(
                date: date,
                events: events,
              );
            } catch (_) {
              return CalendarDateDetailScreen(
                date: DateTime.now(),
                events: const [],
              );
            }
          },
        ),
      ],
    ),
  ],
);
