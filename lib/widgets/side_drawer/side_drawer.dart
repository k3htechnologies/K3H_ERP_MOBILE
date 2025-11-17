import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_module_tile.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_sub_module_tile.dart';
import 'package:k3h_erp_app/widgets/side_drawer/side_drawer_modules/custom_sub_sub_module_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

ProjectModel? _getSelectedProject() {
  String? projectString = LocalStorageManager().getString(
    StorageKey.selectedProject,
  );
  if (projectString == null) {
    return null;
  }
  return ProjectModel.fromJson(jsonDecode(projectString));
}

void closeAllOverlays(BuildContext context) {
    goRouter.pop();

  // CustomOverlayMenu.close();
}

Drawer sideDrawerWeb(BuildContext context, {Function? onOpenCloseCallback}) {
  final List<ModuleModel> menuList = _getMenuList();
  final UserModel? user = _getUser();
  final ProjectModel? project = _getSelectedProject();
  if (user == null) {
    return Drawer();
  }
  return Drawer(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    width: 280.0,
    clipBehavior: Clip.none,
    backgroundColor: AppColor.white,
    child: SafeArea(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          clipBehavior: Clip.none,
          width: 270,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildHeader(context, user, project, onOpenCloseCallback),
              Divider(color: AppColor.grey.withValues(alpha: 0.3)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomModuleTile(
                        title: 'Dashboard',
                        imagePath: AppAssets.dashboardModule,
                        onTapCallback: () {
                          goRouter.go(AppRoutes.dashboardScreen);
                          closeAllOverlays(context);
                        },
                        isActive:
                        GoRouterState.of(context).uri.toString() ==
                            "/dashboard",
                      ),
                      ...menuList.mapIndexed(
                            (index, menu) => _buildModuleTile(context, menu),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildHeader(
    BuildContext context,
    UserModel user,
    ProjectModel? project,
    Function? onOpenCloseCallback,
    ) {
  return
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    child:
    project == null
        ? Image.asset(AppAssets.appLogo, height: 25.0, width: 25.0)
        : Row(
      children: [
        CircleAvatar(radius: 25.0, backgroundColor: AppColor.grey),
        horizontalSpacing(),
        Expanded(
          child: Text(
            project.projectName,
            style: AppTextStyle.ts16SB(
              color: AppColor.slightDarkBlue,
            ),
            maxLines: 2,
          ),
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

Widget _buildFooter(BuildContext context) {
  return Column(
    children: [
      Divider(color: AppColor.grey.withValues(alpha: 0.3)),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async => await logOutUser(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 4),
                    color: AppColor.black.withValues(alpha: 0.12),
                    spreadRadius: 0,
                    blurRadius: 4,
                    inset: true,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(AppAssets.logoutImage),
                  SizedBox(width: 8),
                  Text("Log Out", style: AppTextStyle.ts16SB()),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          Text("V 1.9", style: AppTextStyle.ts14R()),
        ],
      ),
      SizedBox(height: 10),
    ],
  );
}

bool _isActiveModule(BuildContext context, SubModuleModel sub) {
  return sub.path == GoRouterState.of(context).uri.toString() ||
      sub.subSubModuleData.any(
            (subSub) => subSub.path == GoRouterState.of(context).uri.toString(),
      );
}