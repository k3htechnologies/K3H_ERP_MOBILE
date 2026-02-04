import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/presentation/cubit/main_screen_cubit.dart';
import 'package:k3h_erp_app/features/menu/presentation/widgets/menu_drawer_content.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/widgets/bottom_navigation/bottom_navigation_bar_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    // Only show bottom navigation bar on these screens (Home and Profile only)
    final screensWithBottomBar = [AppRoutes.dashboardScreen, AppRoutes.profile];
    final showBottomBar = screensWithBottomBar.contains(currentPath);

    return Scaffold(
      key: mobileScreenGlobalScaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1),
              Expanded(child: MenuDrawerContent()),
            ],
          ),
        ),
      ),
      body: BlocBuilder<MainScreenCubit, Key>(
        builder: (context, key) {
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
