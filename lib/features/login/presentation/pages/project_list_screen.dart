import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';

class ProjectListScreen extends StatefulWidget {
  final List<ProjectModel> projectList;
  const ProjectListScreen({super.key, required this.projectList});

  @override
  State<ProjectListScreen> createState() =>
      _ProjectListMobileScreenState();
}

class _ProjectListMobileScreenState extends State<ProjectListScreen> {
  final UtilsRepository _utilsRepository = serviceLocator<UtilsRepository>();
  final LocalStorageManager _localStorageManager = LocalStorageManager();
  late UserModel userModel;

  // <---- MENU PROJECT WISE ---->
  Future getMenuForCurrentUser(int projectId) async {
    var result = await _utilsRepository.getMenu(
      employeeId:
      UserModel.fromJson(
        jsonDecode(
          LocalStorageManager().getString(StorageKey.currentUser) ?? '',
        ),
      ).employeeId,
      projectId: projectId,
    );
    return result.fold(
          (failure) {
        // Handle failure
        return false;
      },
          (data) async {
        _localStorageManager.setString(
          StorageKey.menu,
          jsonEncode(data["menuData"] as List<ModuleModel>),
        );
        // _localStorageManager.setString(
        //   StorageKey.moduleAction,
        //   jsonEncode(
        //     data["materialRequisitionModulesPermissionsData"]
        //         as List<ModuleActionPermissionModel>,
        //   ),
        // );
        await updateRouteAuthorization(data["menuData"] as List<ModuleModel>);
        return true;
      },
    );
  }

  Future<void> selectProject(int index) async {
    DialogHelper.showProcessingOverlay(context);
    _localStorageManager.setString(
      StorageKey.selectedProject,
      jsonEncode(widget.projectList[index]),
    );
    var result = await getMenuForCurrentUser(
      widget.projectList[index].projectId,
    );
    goRouter.pop();
    if (result) {
      // NAVIGATE TO DASHBAORD
      goRouter.go(AppRoutes.dashboardScreen);
    }
  }

  Future setProjectList() async {
    _localStorageManager.setString(
      StorageKey.projectList,
      jsonEncode(widget.projectList),
    );
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    userModel = UserModel.fromJson(userJson);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setProjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.grey5,
        title: Text('Project Dashboard', style: AppTextStyle.ts20M()),
        actionsPadding: EdgeInsets.all(10.0),
        actions: [
          CircleAvatar(
            radius: 22.4,
            child: SvgPicture.asset(AppAssets.userIcon, fit: BoxFit.fill),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        itemCount:
        widget.projectList.length + 4, // +4 for empty space at the end
        itemBuilder: (context, index) {
          if (index >= widget.projectList.length) {
            return SizedBox(height: 10); // Empty space at the end
          }
          var project = widget.projectList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                selectProject(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColor.grey30),
                ),
                padding: EdgeInsets.all(6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    project.projectPhotoUrl.isNotEmpty
                        ? Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: NetworkImageWidget(
                        imageUrl: project.projectPhotoUrl,
                        width: 84,
                        height: 69,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: Colors.grey[300],
                          width: 84,
                          height: 69,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    )
                        : Container(
                      width: 84,
                      height: 69,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.projectName,
                            style: AppTextStyle.ts14M(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            project.projectLocation,
                            style: AppTextStyle.ts12R(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      AppAssets.notificationActiveIcon,
                      height: 24,
                      width: 24,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}