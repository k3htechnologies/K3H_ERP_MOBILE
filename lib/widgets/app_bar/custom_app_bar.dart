import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String screenTitle;
  final AuthorizationModel authorization;
  final Widget? widgets;
  final Function(String)? onSearchSubmit;
  final TextEditingController? textController;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;
  final List<String>? sortOptionList;
  final String? initialSortType;
  final Future Function(String)? onSortOptionCallback;
  final double extraHeight;

  const CustomAppBar({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.widgets,
    this.onSearchSubmit,
    this.textController,
    this.onAddCallback,
    this.onExportCallback,
    this.sortOptionList,
    this.initialSortType,
    this.onSortOptionCallback,
    this.extraHeight = 0,
  });

  static const double _baseHeight = 90;

  @override
  State<CustomAppBar> createState() => _CustomAppBarMobileState();

  @override
  Size get preferredSize =>
      Size.fromHeight(_baseHeight + extraHeight);

}

class _CustomAppBarMobileState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isDescending = true;
  String? selectedSortType;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    selectedSortType = widget.initialSortType;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.toString();

    final rootScreens = [
      AppRoutes.dashboardScreen,
      AppRoutes.menu,
      AppRoutes.profile,
    ];
    final isRootScreen = rootScreens.contains(currentPath);
    final showMenuIcon = isRootScreen;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
      isDarkMode ? AppColor.primary : AppColor.lightGreyBackground,
      surfaceTintColor: Colors.transparent,

      title: Row(
        spacing: 10,
        children: [
          InkWell(
            onTap: () {
              if (showMenuIcon) {
                if (currentPath != AppRoutes.menu) {
                  goRouter.pushNamed(AppRoutes.menu);
                }
              } else {
                if (goRouter.canPop()) {
                  goRouter.pop();
                } else {
                  goRouter.goNamed(AppRoutes.menu);
                }
              }
            },
            child: Icon(
              showMenuIcon ? Icons.menu : Icons.arrow_back,
              color: isDarkMode ? AppColor.white : AppColor.black,
            ),
          ),
          Expanded(
            child: Text(
              widget.screenTitle,
              style: AppTextStyle.ts16R().copyWith(
                color: isDarkMode ? AppColor.white : AppColor.black,
              ),
            ),
          ),
        ],
      ),

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          widget.extraHeight == 0 ? 54 : widget.extraHeight + 54,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.widgets != null && widget.extraHeight > 0)
                widget.widgets!,

              Row(
                spacing: 10,
                children: [
                  if (widget.onSearchSubmit != null)
                    Expanded(
                      child: SearchWidget(
                        onSubmit: widget.onSearchSubmit!,
                        textController: widget.textController!,
                      ),
                    ),

                  const SizedBox(width: 10),

                  if (widget.authorization.isAction &&
                      widget.onAddCallback != null)
                    CustomIconButton(
                      onPressed: () => widget.onAddCallback!(),
                      icon: Icon(Icons.add,
                          size: 16, color: AppColor.darkGreen),
                      backgroundColor: AppColor.lightGreen,
                    ),

                  if (widget.authorization.isAction &&
                      widget.onExportCallback != null)
                    CustomIconButton(
                      onPressed: () {
                        final box =
                        context.findRenderObject() as RenderBox;
                        final position = box.localToGlobal(Offset.zero);
                        CustomOverlayMenu.show(
                          width: 180,
                          context: context,
                          position:
                          Offset(position.dx + 10, position.dy + (145 + widget.extraHeight)),
                          items: [
                            AddImportExportOverlayMenuItem(
                              icon: Icons.file_download_outlined,
                              label: 'Export Excel',
                              value: 'EXCEL',
                              onTap: widget.onExportCallback!,
                              iconColor: AppColor.primary,
                            ),
                            AddImportExportOverlayMenuItem(
                              icon: Icons.file_download_outlined,
                              label: 'Export PDF',
                              value: 'PDF',
                              onTap: widget.onExportCallback!,
                              iconColor: AppColor.primary,
                            ),
                          ],
                        );
                      },
                      icon: Icon(Icons.file_download,
                          size: 16, color: AppColor.primary),
                      backgroundColor: AppColor.lightBlue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomOverlayMenu {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Offset position,
    required List<AddImportExportOverlayMenuItem> items,
    double width = 160,
  }) {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => close(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              top: position.dy,
              right: position.dx,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _buildItem(
                          icon: items[i].icon,
                          iconColor: items[i].iconColor,
                          label: items[i].label,
                          value: items[i].value,
                          onTap: items[i].onTap,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void close() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
      _entry = null;
    }
  }

  static Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required void Function(String) onTap,
  }) {
    return InkWell(
      onTap: () {
        close();
        onTap(value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            Text(label, style: AppTextStyle.ts14R(color: iconColor)),
          ],
        ),
      ),
    );
  }
}

class SortOverlayMenu {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Offset position,
    required List<SortOverlayMenuItem> items,
    double width = 120,
  }) {
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => close(),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              top: position.dy,
              left: position.dx,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        items
                            .map(
                              (item) => InkWell(
                                onTap: () {
                                  close();
                                  item.onTap(item.value);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    item.label,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void close() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
      _entry = null;
    }
  }
}

class AddImportExportOverlayMenuItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final void Function(String) onTap;

  AddImportExportOverlayMenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });
}

class SortOverlayMenuItem {
  final String label;
  final String value;
  final void Function(String) onTap;

  SortOverlayMenuItem({
    required this.label,
    required this.value,
    required this.onTap,
  });
}
