import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/menu_list/menu_list_modules/custom_module_tile.dart';
import 'package:k3h_erp_app/widgets/menu_list/menu_list_modules/custom_sub_module_tile.dart';
import 'package:k3h_erp_app/widgets/menu_list/menu_list_modules/custom_sub_sub_module_tile.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

void removeHiddenSubSubModules(List<ModuleModel> modules) {
  for (var module in modules) {
    for (var subModule in module.subModuleData) {
      subModule.subSubModuleData.removeWhere(
        (subSub) => subSub.isDisplay == false,
      );

      if (module.moduleName.toLowerCase() == 'sale' &&
          subModule.subModuleName.toLowerCase() == 'reports') {
        subModule.subSubModuleData.removeWhere(
          (subSub) =>
              subSub.subSubModuleName == "Incentive" ||
              subSub.subSubModuleName == "Enquiry" ||
              subSub.subSubModuleName == "CP Enquiry" ||
              subSub.subSubModuleName == "Achievement",
        );
      }
    }
  }
}

List<ModuleModel> getMenuList() {
  String? menuString = LocalStorageManager().getString(StorageKey.menu);
  if (menuString == null) {
    return [];
  }
  var menuList = List<ModuleModel>.from(
    jsonDecode(menuString).map((menu) => ModuleModel.fromJson(menu)),
  );
  removeHiddenSubSubModules(menuList);

  // Add static \"Dashboard\" module (not stored in backend menu) if missing.
  final hasDashboard = menuList.any(
    (m) => m.moduleName.trim().toLowerCase() == 'dashboard',
  );
  if (!hasDashboard) {
    menuList.insert(
      0,
      ModuleModel(
        modulesMasterId: 0,
        moduleName: 'Dashboard',
        icon: AppAssets.crmModule,
        subModuleData: const [],
      ),
    );
  }

  return menuList;
}

UserModel? getUser() {
  String? userString = LocalStorageManager().getString(StorageKey.currentUser);
  if (userString == null) {
    return null;
  }
  return UserModel.fromJson(jsonDecode(userString));
}

class MenuDrawerContent extends StatefulWidget {
  final VoidCallback? onNavigate;

  const MenuDrawerContent({super.key, this.onNavigate});

  @override
  State<MenuDrawerContent> createState() => _MenuDrawerContentState();
}

class _MenuDrawerContentState extends State<MenuDrawerContent> {
  String _currentPathForBuild = '';

  late final ScrollController _scrollController;

  static double _cachedScrollOffset = 0.0;

  bool _navigationInProgress = false;

  @override
  void initState() {
    super.initState();
    final storedOffset = LocalStorageManager().getString(
      StorageKey.menuDrawerScrollOffset,
    );
    final initialOffset =
        _cachedScrollOffset > 0
            ? _cachedScrollOffset
            : (double.tryParse(storedOffset ?? '') ?? 0.0);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(() {
      _cachedScrollOffset = _scrollController.offset;
    });
    goRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    goRouter.routerDelegate.removeListener(_onRouteChanged);
    // Persist last known offset (helps if widget gets recreated).
    LocalStorageManager().setString(
      StorageKey.menuDrawerScrollOffset,
      _scrollController.hasClients
          ? _scrollController.offset.toStringAsFixed(1)
          : '0.0',
    );
    _scrollController.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      _navigationInProgress = false;
      _saveCurrentPathToStorage();
      setState(() {});
    }
  }

  // Persist current route so when drawer opens we know what to highlight/expand.
  void _saveCurrentPathToStorage() {
    try {
      final config = goRouter.routerDelegate.currentConfiguration;
      if (config.isNotEmpty) {
        final path = config.uri.path;
        if (path.isNotEmpty && path != '/menu') {
          LocalStorageManager().setString(StorageKey.lastActiveRoute, path);
        }
      }
    } catch (_) {}
  }

  Future<void> _onItemTap({String? navigateToPath}) async {
    if (_navigationInProgress) return;
    _navigationInProgress = true;
    // Persist current scroll position so reopening drawer feels seamless.
    final offset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    _cachedScrollOffset = offset;
    try {
      await LocalStorageManager().setString(
        StorageKey.menuDrawerScrollOffset,
        offset.toStringAsFixed(1),
      );
      if (navigateToPath != null && navigateToPath.isNotEmpty) {
        await LocalStorageManager().setString(
          StorageKey.lastActiveRoute,
          navigateToPath.startsWith('/') ? navigateToPath : '/$navigateToPath',
        );
      }
      widget.onNavigate?.call();
      try {
        if (mounted) {
          Scaffold.maybeOf(context)?.closeDrawer();
        }
      } catch (_) {}
      CustomOverlayMenu.close();
      SortOverlayMenu.close();

      // Navigate once (avoid stacking pages + duplicated keys).
      if (navigateToPath != null && navigateToPath.isNotEmpty) {
        final location =
            navigateToPath.startsWith('/')
                ? navigateToPath
                : '/$navigateToPath';
        goRouter.go(location);
      }
    } catch (_) {
      // If anything fails pre-navigation, allow retry.
      _navigationInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ModuleModel> menuList = getMenuList();
    final UserModel? user = getUser();

    if (user == null) {
      return const Center(child: Text("No user found"));
    }

    // Always use latest path when building (router or stored when drawer opens)
    _currentPathForBuild = _getCurrentPath(context);
    if (_currentPathForBuild.isNotEmpty) {
      LocalStorageManager().setString(
        StorageKey.lastActiveRoute,
        _currentPathForBuild,
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...menuList.mapIndexed(
            (index, menu) => _buildModuleTile(context, menu),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, ModuleModel menu) {
    if (menu.subModuleData.isEmpty) {
      final isDashboard = menu.moduleName.trim().toLowerCase() == 'dashboard';
      final isDashboardActive = _isRouteActive(
        _currentPathForBuild,
        AppRoutes.dashboardScreen,
      );

      return CustomModuleTile(
        key: ValueKey('module-${menu.moduleName}'),
        title: menu.moduleName,
        imagePath: menu.icon,
        isExpanded: false,
        isActive: isDashboardActive,
        onTapCallback:
            isDashboard
                ? () async {
                  await _onItemTap(navigateToPath: AppRoutes.dashboardScreen);
                }
                : null,
      );
    }

    final isRedevelopment =
        menu.moduleName.trim().toLowerCase() == 'redevelopment';

    final isSalesDashboard = menu.moduleName.trim().toLowerCase() == 'sale';
    final isPayrollDashboard =
        menu.moduleName.trim().toLowerCase() == 'payroll';
    final isInventoryDashboard =
        menu.moduleName.trim().toLowerCase() == 'inventory';
    final isSettingsDashboard =
        menu.moduleName.trim().toLowerCase() == 'setting';

    final isLitigationDashboard =
        menu.moduleName.trim().toLowerCase() == "legal";
    final isChannelPartnerDashboard =
        menu.moduleName.trim().toLowerCase() == "channel partner";

    final isCrmDashboard = menu.moduleName.trim().toLowerCase() == "crm";
    bool isCurrentModuleActive = menu.subModuleData.any(
      (sub) => _isActiveModule(sub),
    );
    if (isRedevelopment) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(
            _currentPathForBuild,
            AppRoutes.redevelopmentDashboard,
          );
    }
    if (isSalesDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.salesDashboard);
    }
    if (isPayrollDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.payrollDashboard);
    }
    if (isInventoryDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.inventoryDashboard);
    }
    if (isSettingsDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.settingDashboard);
    }
    if (isLitigationDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.litigationDashboard);
    }
    if (isChannelPartnerDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(
            _currentPathForBuild,
            AppRoutes.channelPartnerDashboard,
          );
    }
    if (isCrmDashboard) {
      isCurrentModuleActive =
          isCurrentModuleActive ||
          _isRouteActive(_currentPathForBuild, AppRoutes.crmDashbaord);
    }

    final tile = CustomModuleTile(
      key: ValueKey('module-${menu.moduleName}-$isCurrentModuleActive'),
      title: menu.moduleName,
      imagePath: menu.icon,
      isActive: isCurrentModuleActive,
      isExpanded: isCurrentModuleActive,
      onTapCallback: () async {
        if (isRedevelopment) {
          await _onItemTap(navigateToPath: AppRoutes.redevelopmentDashboard);
        } else if (isSalesDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.salesDashboard);
        } else if (isPayrollDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.payrollDashboard);
        } else if (isInventoryDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.inventoryDashboard);
        } else if (isSettingsDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.settingDashboard);
        } else if (isLitigationDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.litigationDashboard);
        } else if (isChannelPartnerDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.channelPartnerDashboard);
        } else if (isCrmDashboard) {
          await _onItemTap(navigateToPath: AppRoutes.crmDashbaord);
        }
      },
      items:
          menu.subModuleData
              .mapIndexed(
                (index, sub) =>
                    index == menu.subModuleData.length - 1
                        ? _buildSubModuleTile(context, sub, isLast: true)
                        : _buildSubModuleTile(context, sub),
              )
              .toList(),
    );
    return tile;
  }

  String _getCurrentPath(BuildContext context) {
    try {
      final state = GoRouterState.of(context);
      if (state.uri.path.isNotEmpty && state.uri.path != '/menu') {
        return state.uri.path;
      }
    } catch (_) {}

    try {
      final config = goRouter.routerDelegate.currentConfiguration;
      if (config.isNotEmpty) {
        final path = config.uri.path;
        if (path.isNotEmpty && path != '/menu') return path;
      }
    } catch (_) {}

    final stored = LocalStorageManager().getString(StorageKey.lastActiveRoute);
    return stored ?? '';
  }

  Widget _buildSubModuleTile(
    BuildContext context,
    SubModuleModel sub, {
    bool isLast = false,
  }) {
    final currentPath = _currentPathForBuild;
    final isActive = _isRouteActive(currentPath, sub.path);

    if (sub.subSubModuleData.isEmpty) {
      return CustomSubModuleTile(
        key: ValueKey('sub-${sub.subModulesMasterId}-$isActive'),
        title: sub.subModuleName,
        imagePath: sub.icon,
        onTapCallback: () async {
          await _onItemTap(navigateToPath: sub.path);
        },
        isExpanded: false,
        isLast: isLast,
        isActive: isActive,
      );
    }

    bool isCurrentSubmoduleActive = sub.subSubModuleData.any(
      (subSub) => _isRouteActive(currentPath, subSub.path),
    );
    return CustomSubModuleTile(
      key: ValueKey('sub-${sub.subModulesMasterId}-$isCurrentSubmoduleActive'),
      title: sub.subModuleName,
      imagePath: sub.icon,
      isActive: isCurrentSubmoduleActive,
      isExpanded: isCurrentSubmoduleActive,
      isLast: isLast,
      items:
          sub.subSubModuleData
              .mapIndexed(
                (index, subsub) =>
                    index == sub.subSubModuleData.length - 1
                        ? _buildSubSubModuleTile(context, subsub, isLast: true)
                        : _buildSubSubModuleTile(context, subsub),
              )
              .toList(),
    );
  }

  Widget _buildSubSubModuleTile(
    BuildContext context,
    SubSubModuleModel subSub, {
    bool isLast = false,
  }) {
    final currentPath = _currentPathForBuild;
    final isActive = _isRouteActive(currentPath, subSub.path);

    return CustomSubSubModuleTile(
      title: subSub.subSubModuleName,
      iconData: subSub.icon,
      onTapFunction: () async {
        await _onItemTap(navigateToPath: subSub.path);
      },
      isLast: isLast,
      isActive: isActive,
    );
  }

  bool _isActiveModule(SubModuleModel sub) {
    final currentPath = _currentPathForBuild;
    return _isRouteActive(currentPath, sub.path) ||
        sub.subSubModuleData.any(
          (subSub) => _isRouteActive(currentPath, subSub.path),
        );
  }

  bool _isRouteActive(String currentPath, String routePath) {
    final normalizedCurrent =
        currentPath.startsWith('/') ? currentPath : '/$currentPath';
    final normalizedRoute =
        routePath.startsWith('/') ? routePath : '/$routePath';
    return normalizedCurrent == normalizedRoute;
  }
}
