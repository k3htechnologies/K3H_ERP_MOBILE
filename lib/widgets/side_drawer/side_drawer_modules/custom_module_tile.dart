import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomModuleTile extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<Widget>? items;
  final bool isActive;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback? onTapCallback;

  const CustomModuleTile({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTapCallback,
    this.items,
    this.isExpanded = false,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  State<CustomModuleTile> createState() => _CustomModuleTileState();
}

class _CustomModuleTileState extends State<CustomModuleTile> {
  // Helper method to get the correct icon path
  String _getIconPath(String iconPath) {
    // If the path already includes "assets/", use it as is
    if (iconPath.startsWith('assets/')) {
      return iconPath;
    }
    // Otherwise, prepend the sideDrawer path
    return '${AppAssets.sideDrawerIconsPath}/$iconPath';
  }

  // Helper method to build the icon widget
  Widget _buildIcon(String iconPath) {
    final fullPath = _getIconPath(iconPath);
    
    // Check if it's an SVG file
    if (iconPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath,
        height: 20,
        width: 20,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          height: 20,
          width: 20,
          color: Colors.grey[300],
        ),
      );
    } else {
      // PNG or other image formats
      return Image.asset(
        fullPath,
        height: 20,
        width: 20,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 20,
          width: 20,
          color: Colors.grey[300],
          child: Icon(Icons.image_not_supported, size: 16, color: Colors.grey[600]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items != null && widget.items!.isNotEmpty;
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Column(
        children: [
          hasItems
              ? ExpansionTile(
                collapsedIconColor: AppColor.black,
                iconColor: AppColor.black,
                minTileHeight: 60,
                initiallyExpanded: widget.isExpanded,
                childrenPadding: const EdgeInsets.only(left: 15.0),

                // ✅ keep these
                shape: const Border(),
                collapsedShape: const Border(),

                title: Row(
                  children: [
                    _buildIcon(widget.imagePath),
                    horizontalSpacing(),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyle.ts16SB(
                          color:
                              widget.isActive
                                  ? AppColor.slightDarkBlue
                                  : AppColor.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                children: widget.items!,
              )
              : ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                minTileHeight: 30,
                title: Row(
                  children: [
                    _buildIcon(widget.imagePath),
                    horizontalSpacing(),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyle.ts16SB(
                          color:
                              widget.isActive
                                  ? AppColor.slightDarkBlue
                                  : AppColor.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                onTap: widget.onTapCallback,
              ),

          // ✅ YOUR divider (single, clean, controlled)
          if (!widget.isLast)
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColor.slightDarkBlue.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }
}
