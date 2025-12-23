import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
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
import 'package:k3h_erp_app/features/menu/presentation/pages/menu_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/add_event_details_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_date_detail_screen.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/pages/calendar_screen.dart';
import 'package:k3h_erp_app/features/more/events/task/presentation/pages/task_transfer_history_screen.dart';
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
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_form.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_screen.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/pages/employee_master_view_details_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_file/approved_bank_file_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_file_screen.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/pages/approved_bank_folder_screen.dart';
import 'package:k3h_erp_app/features/test_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor_add/vendor_add_cubit.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/add_vendor_screen.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/pages/document_view_company_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/documents_view_vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/vendor_screen.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/pages/view_details_vendor_screen.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

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
                                Uri.decodeQueryComponent(
                                  queryParameterCompany,
                                ),
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
            return const ProfileScreen();
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
