import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

Widget buildBottomNavigationBar(BuildContext context) {
  final currentPath = GoRouterState.of(context).uri.toString();
  
  return Container(
    decoration: BoxDecoration(
      color: AppColor.white,
      boxShadow: [
        BoxShadow(
          color: AppColor.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home,
              label: 'Home',
              route: AppRoutes.dashboardScreen,
              isActive: currentPath == AppRoutes.dashboardScreen,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.menu,
              label: 'Menu',
              route: AppRoutes.menu,
              isActive: currentPath == AppRoutes.menu,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person,
              label: 'Profile',
              route: AppRoutes.profile,
              isActive: currentPath == AppRoutes.profile,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required String route,
  required bool isActive,
}) {
  return SizedBox(
    width: 80,
    height: 90,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => goRouter.go(route),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Label (space always reserved)
            Positioned(
              bottom: 8,
              child: Opacity(
                opacity: isActive ? 0 : 1, // 👈 hide, don’t remove
                child: Text(
                  label,
                  style: AppTextStyle.ts12R(
                    color: isActive
                        ? AppColor.primary
                        : AppColor.grey,
                  ),
                ),
              ),
            ),

            // Icon (lift when selected)
            Transform.translate(
              offset: isActive
                  ? const Offset(0, -12) // 👈 lift ALL items
                  : Offset.zero,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: isActive
                    ? BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
                    : null,
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive
                      ? AppColor.white
                      : AppColor.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

