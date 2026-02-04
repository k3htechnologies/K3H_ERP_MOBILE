import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
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

  for (final module in menuList) {
    final moduleName = module.moduleName.toLowerCase();

    if (moduleName == "redevelopment") {
      final exists = module.subModuleData.any(
        (e) => e.subModuleName == "Re-Development Dashboard",
      );

      if (!exists) {
        module.subModuleData.insert(0, _redevelopmentDashboardSubModule());
      }
    }
  }

  return menuList;
}

SubModuleModel _redevelopmentDashboardSubModule() {
  return SubModuleModel(
    subModuleName: "Re-Development Dashboard",
    path: AppRoutes.redevelopmentDashboard,
    icon: "",
    subSubModuleData: [],
    subModulesMasterId: 0,
  );
}

UserModel? getUser() {
  String? userString = LocalStorageManager().getString(StorageKey.currentUser);
  if (userString == null) {
    return null;
  }
  return UserModel.fromJson(jsonDecode(userString));
}

/// Reusable menu list content for Drawer or full Menu screen.
/// [onNavigate] is called before navigation (e.g. to close the drawer).
class MenuDrawerContent extends StatefulWidget {
  final VoidCallback? onNavigate;

  const MenuDrawerContent({super.key, this.onNavigate});

  @override
  State<MenuDrawerContent> createState() => _MenuDrawerContentState();
}

class _MenuDrawerContentState extends State<MenuDrawerContent> {
  @override
  void initState() {
    super.initState();
    goRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    goRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      final config = goRouter.routerDelegate.currentConfiguration;
      if (config.isNotEmpty) {
        final currentPath = config.uri.path;
        if (currentPath != '/menu') {
          LocalStorageManager().setString(
            StorageKey.lastActiveRoute,
            currentPath,
          );
        }
      }
      setState(() {});
    }
  }

  void _onItemTap() {
    widget.onNavigate?.call();
    // Close drawer if we're inside one (e.g. main screen side drawer)
    try {
      Scaffold.maybeOf(context)?.closeDrawer();
    } catch (_) {}
    CustomOverlayMenu.close();
    SortOverlayMenu.close();
  }

  @override
  Widget build(BuildContext context) {
    final List<ModuleModel> menuList = getMenuList();
    final UserModel? user = getUser();

    if (user == null) {
      return const Center(child: Text("No user found"));
    }

    return SingleChildScrollView(
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
      return CustomModuleTile(
        title: menu.moduleName,
        imagePath: menu.icon,
        isExpanded: false,
      );
    }

    bool isCurrentModuleActive = menu.subModuleData.any(
      (sub) => _isActiveModule(sub),
    );
    return CustomModuleTile(
      title: menu.moduleName,
      imagePath: menu.icon,
      isActive: isCurrentModuleActive,
      isExpanded: isCurrentModuleActive,
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
  }

  String _getCurrentPath() {
    try {
      final config = goRouter.routerDelegate.currentConfiguration;
      if (config.isNotEmpty) {
        final uri = config.uri;
        String currentPath = uri.path;

        if (currentPath == '/menu') {
          final lastRoute = LocalStorageManager().getString(
            StorageKey.lastActiveRoute,
          );
          if (lastRoute != null && lastRoute.isNotEmpty) {
            return lastRoute;
          }
        } else {
          LocalStorageManager().setString(
            StorageKey.lastActiveRoute,
            currentPath,
          );
        }

        return currentPath;
      }
    } catch (e) {
      // Error getting current path
    }
    return '';
  }

  Widget _buildSubModuleTile(
    BuildContext context,
    SubModuleModel sub, {
    bool isLast = false,
  }) {
    final currentPath = _getCurrentPath();
    final isActive = _isRouteActive(currentPath, sub.path);

    if (sub.subSubModuleData.isEmpty) {
      return CustomSubModuleTile(
        title: sub.subModuleName,
        imagePath: sub.icon,
        onTapCallback: () {
          _onItemTap();
          goRouter.pushNamed(sub.path);
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
    final currentPath = _getCurrentPath();
    final isActive = _isRouteActive(currentPath, subSub.path);

    return CustomSubSubModuleTile(
      title: subSub.subSubModuleName,
      iconData: subSub.icon,
      onTapFunction: () {
        _onItemTap();
        goRouter.pushNamed(subSub.path);
      },
      isLast: isLast,
      isActive: isActive,
    );
  }

  bool _isActiveModule(SubModuleModel sub) {
    final currentPath = _getCurrentPath();
    return _isRouteActive(currentPath, sub.path) ||
        sub.subSubModuleData.any(
          (subSub) => _isRouteActive(currentPath, subSub.path),
        );
  }

  bool _isRouteActive(String currentPath, String routePath) {
    return currentPath == routePath;
  }
}
