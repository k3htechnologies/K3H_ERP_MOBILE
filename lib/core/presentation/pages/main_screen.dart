import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/features/menu/presentation/widgets/menu_drawer_content.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/bottom_navigation/bottom_navigation_bar_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

final GlobalKey<ScaffoldState> mobileScreenGlobalScaffoldKey =
    GlobalKey<ScaffoldState>();

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool drawerExpanded = true;
  late UserModel user;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    final screensWithBottomBar = [AppRoutes.dashboardScreen, AppRoutes.profile];
    final showBottomBar = screensWithBottomBar.contains(currentPath);

    return Scaffold(
      key: mobileScreenGlobalScaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: BlocBuilder<MainScreenCubit, Key>(
            builder: (context, key) {
              final userString = LocalStorageManager().getString(
                StorageKey.currentUser,
              );

              if (userString == null || userString.isEmpty) {
                return Center(child: Text("No User Found"));
              }

              final user = UserModel.fromJson(jsonDecode(userString));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            goRouter.pop();
                            goRouter.go(AppRoutes.profile);
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColor.primary,
                            child:
                                user.profilePhotoURL.isNotEmpty
                                    ? ClipOval(
                                      child: Image.network(
                                        user.profilePhotoURL,
                                        fit: BoxFit.fill,
                                        width: 70,
                                        height: 70,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : 'U',
                                      style: AppTextStyle.ts24B(
                                        color: AppColor.white,
                                      ),
                                    ),
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: AppTextStyle.ts16SB(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.department.isNotEmpty
                                    ? user.department
                                    : '-',
                                style: AppTextStyle.ts14M(color: AppColor.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.designation.isNotEmpty
                                    ? user.designation
                                    : '-',
                                style: AppTextStyle.ts12M(color: AppColor.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColor.grey50),
                  Expanded(child: MenuDrawerContent()),
                  Divider(height: 1, color: AppColor.grey50),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomButton(
                      leading: Icon(
                        Icons.logout_outlined,
                        size: 18,
                        color: AppColor.white,
                      ),
                      backgroundColor: AppColor.error,
                      text: "Logout",
                      onPressed: () async {
                        logOutUser(context);
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocBuilder<MainScreenCubit, Key>(
        builder: (context, key) {
          final userString = LocalStorageManager().getString(
            StorageKey.currentUser,
          );

          if (userString != null) {
            user = UserModel.fromJson(jsonDecode(userString));
          }

          return Row(
            children: [
              SizedBox.shrink(),
              Expanded(child: KeyedSubtree(key: key, child: widget.child)),
            ],
          );
        },
      ),
      bottomNavigationBar:
          showBottomBar ? buildBottomNavigationBar(context) : null,
    );
  }
}
