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
  final Function(String)? onSearchSubmit;
  final TextEditingController? textController;
  final Function? onAddCallback;
  final Function(String)? onExportCallback;
  final List<String>? sortOptionList;
  final String? initialSortType;
  final Future Function(String)? onSortOptionCallback;

  const CustomAppBar({
    super.key,
    required this.screenTitle,
    required this.authorization,
    this.onSearchSubmit,
    this.textController,
    this.onAddCallback,
    this.onExportCallback,
    this.sortOptionList,
    this.initialSortType,
    this.onSortOptionCallback,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarMobileState();

  @override
  Size get preferredSize => Size.fromHeight(110);
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
      toolbarHeight: widget.preferredSize.height,
      automaticallyImplyLeading: false,
      title: Column(
        spacing: 15.0,
        children: [
          Row(
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
                  size: 24.0,
                ),
              ),
              Expanded(
                child: Text(
                  widget.screenTitle,
                  style: AppTextStyle.ts16R().copyWith(
                    color: isDarkMode ? AppColor.white : AppColor.black,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                flex: 5,
                child:
                    widget.onSearchSubmit == null
                        ? Container()
                        : SearchWidget(
                          onSubmit: widget.onSearchSubmit!,
                          textController: widget.textController!,
                        ),
              ),
              Spacer(),
              Flexible(
                flex: 2,
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.authorization.isAction &&
                            widget.onAddCallback != null
                        ? CustomIconButton(
                          onPressed: () {
                            widget.onAddCallback!();
                          },
                          icon: Icons.add,
                          backgroundColor: AppColor.lightGreen,
                          iconColor: AppColor.darkGreen,
                        )
                        : Container(),
                    widget.authorization.isAction &&
                            widget.onExportCallback != null
                        ? CustomIconButton(
                          onPressed: () {
                            final RenderBox box =
                                context.findRenderObject() as RenderBox;
                            final Offset position = box.localToGlobal(
                              Offset.zero,
                            );
                            CustomOverlayMenu.show(
                              width: 180,
                              context: context,
                              position: Offset(
                                position.dx + 10,
                                position.dy + 100,
                              ),
                              items: [
                                AddImportExportOverlayMenuItem(
                                  icon: Icons.file_download_outlined,
                                  iconColor: AppColor.primary,
                                  label: 'Export Excel',
                                  value: 'EXCEL',
                                  onTap: (val) {
                                    widget.onExportCallback!(val);
                                  },
                                ),
                                AddImportExportOverlayMenuItem(
                                  icon: Icons.file_download_outlined,
                                  iconColor: AppColor.primary,
                                  label: 'Export PDF',
                                  value: 'PDF',
                                  onTap: (val) {
                                    widget.onExportCallback!(val);
                                  },
                                ),
                              ],
                            );
                          },
                          icon: Icons.file_download,
                          backgroundColor: AppColor.lightRed,
                          iconColor: AppColor.error,
                        )
                        : Container(),
                  ],
                ),
                /*widget.sortOptionList == null
                        ? Container()
                        : StatefulBuilder(
                          builder: (context, localSetState) {
                            return Container(
                              height: 35.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: Row(
                                children: [
                                  // Sort order toggle (ASC/DESC)
                                  GestureDetector(
                                    onTap: () async {
                                      isDescending = !isDescending;
                                      localSetState(() {});
                                      await widget.onSortOptionCallback!(
                                        "$selectedSortType ${isDescending ? "DESC" : "ASC"}",
                                      );
                                    },
                                    child:
                                        isDescending
                                            ? SvgPicture.asset(
                                              AppAssets.sortDESC,
                                              width: 24.0,
                                              height: 24.0,
                                              colorFilter: ColorFilter.mode(
                                                isDarkMode
                                                    ? AppColor.white
                                                    : AppColor.primary,
                                                BlendMode.srcIn,
                                              ),
                                            )
                                            : SvgPicture.asset(
                                              AppAssets.sortASC,
                                              width: 24.0,
                                              height: 24.0,
                                              colorFilter: ColorFilter.mode(
                                                isDarkMode
                                                    ? AppColor.white
                                                    : AppColor.primary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                  ),
                                  horizontalSpacing(width: 4.0),
                                  Container(
                                    width: 1.0,
                                    height: 35.0,
                                    color: AppColor.grey,
                                  ),
                                  horizontalSpacing(width: 4.0),
                                  // Sort option selector
                                  GestureDetector(
                                    onTap: () {
                                      final RenderBox box =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final Offset position = box.localToGlobal(
                                        Offset.zero,
                                      );

                                      SortOverlayMenu.show(
                                        context: context,
                                        position: Offset(
                                          position.dx + 10,
                                          position.dy + 40,
                                        ),
                                        items:
                                            widget.sortOptionList!
                                                .map(
                                                  (e) => SortOverlayMenuItem(
                                                    label: e,
                                                    value: e,
                                                    onTap: (val) async {
                                                      selectedSortType = val;
                                                      localSetState(() {});
                                                      await widget
                                                          .onSortOptionCallback!(
                                                        "$selectedSortType ${isDescending ? "DESC" : "ASC"}",
                                                      );
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                      );
                                    },
                                    child: Text(
                                      selectedSortType ?? "",
                                      style: AppTextStyle.ts12M(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),*/
              ),
            ],
          ),
        ],
      ),
      backgroundColor: isDarkMode ? AppColor.primary : AppColor.white,
      surfaceTintColor: Colors.transparent,
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
