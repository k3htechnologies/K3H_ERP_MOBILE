import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_module_tile.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_sub_module_tile.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_sub_sub_module_tile.dart';

void removeHiddenSubSubModules(List<ModuleModel> modules) {
  for (var module in modules) {
    for (var subModule in module.subModuleData) {
      subModule.subSubModuleData.removeWhere(
        (subSub) => subSub.isDisplay == false,
      );
    }
  }
}

List<ModuleModel> _getMenuList() {
  String? menuString = LocalStorageManager().getString(StorageKey.menu);
  if (menuString == null) {
    return [];
  }
  var menuList = List<ModuleModel>.from(
    jsonDecode(menuString).map((menu) => ModuleModel.fromJson(menu)),
  );
  removeHiddenSubSubModules(menuList);
  return menuList;
}

UserModel? _getUser() {
  String? userString = LocalStorageManager().getString(StorageKey.currentUser);
  if (userString == null) {
    return null;
  }
  return UserModel.fromJson(jsonDecode(userString));
}

void closeAllOverlays(BuildContext context) {
  goRouter.pop();
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ModuleModel> menuList = _getMenuList();
    final UserModel? user = _getUser();
    final ProjectModel? project = _getSelectedProject();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text("Menu", style: AppTextStyle.ts16R()),
      ),
      body:
          user == null
              ? const Center(child: Text("No user found"))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...menuList.mapIndexed(
                      (index, menu) => _buildModuleTile(context, menu),
                    ),
                  ],
                ),
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
      (sub) => _isActiveModule(context, sub),
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

  Widget _buildSubModuleTile(
    BuildContext context,
    SubModuleModel sub, {
    bool isLast = false,
  }) {
    if (sub.subSubModuleData.isEmpty) {
      return CustomSubModuleTile(
        title: sub.subModuleName,
        imagePath: sub.icon,
        onTapCallback: () {
          goRouter.goNamed(sub.path);
          closeAllOverlays(context);
        },
        isExpanded: false,
        isLast: isLast,
        isActive: GoRouterState.of(context).uri.toString() == sub.path,
      );
    }

    bool isCurrentSubmoduleActive = sub.subSubModuleData.any(
      (subSub) => GoRouterState.of(context).uri.toString() == subSub.path,
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
    return CustomSubSubModuleTile(
      title: subSub.subSubModuleName,
      iconData: subSub.icon,
      onTapFunction: () {
        goRouter.goNamed(subSub.path);
        closeAllOverlays(context);
      },
      isLast: isLast,
      isActive: GoRouterState.of(context).uri.toString() == subSub.path,
    );
  }

  bool _isActiveModule(BuildContext context, SubModuleModel sub) {
    return sub.path == GoRouterState.of(context).uri.toString() ||
        sub.subSubModuleData.any(
          (subSub) => subSub.path == GoRouterState.of(context).uri.toString(),
        );
  }
}

ProjectModel? _getSelectedProject() {
  String? projectString = LocalStorageManager().getString(
    StorageKey.selectedProject,
  );
  if (projectString == null) {
    return null;
  }
  return ProjectModel.fromJson(jsonDecode(projectString));
}
